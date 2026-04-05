import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  String? get error => _error;

  AuthService() {
    _init();
  }

  void _init() {
    // Add timeout to prevent infinite loading
    Future.delayed(const Duration(seconds: 3), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });

    try {
      _auth.authStateChanges().listen((User? user) async {
        _firebaseUser = user;
        if (user != null) {
          await _loadUserProfile(user.uid);
        } else {
          _currentUser = null;
        }
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Auth state error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null; // User cancelled
      }

      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in');
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Create new user profile
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Creator',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        _currentUser = newUser;
      } else {
        // Update last login
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        _currentUser = UserModel.fromFirestore(userDoc);
      }

      _isLoading = false;
      notifyListeners();
      return _currentUser;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      _firebaseUser = null;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? walletAddress,
  }) async {
    if (_currentUser == null) return;

    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (walletAddress != null) updates['walletAddress'] = walletAddress;

      await _firestore.collection('users').doc(_currentUser!.uid).update(updates);

      _currentUser = _currentUser!.copyWith(
        walletAddress: walletAddress,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_firebaseUser != null) {
      await _loadUserProfile(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
