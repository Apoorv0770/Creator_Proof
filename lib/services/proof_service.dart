import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

import '../models/proof_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'hash_service.dart';
import 'wallet_service.dart';
import 'blockchain_service.dart';

class ProofService extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  AuthService? _authService;
  WalletService? _walletService;

  List<ProofModel> _userProofs = [];
  List<ProofModel> _publicProofs = [];
  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0;

  List<ProofModel> get userProofs => _userProofs;
  List<ProofModel> get publicProofs => _publicProofs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;

  void updateAuth(AuthService auth) {
    _authService = auth;
    if (auth.isAuthenticated) {
      loadUserProofs();
    }
  }

  void setWalletService(WalletService wallet) {
    _walletService = wallet;
  }

  /// Create a new proof
  Future<ProofModel?> createProof({
    required File file,
    required String title,
    required String description,
    required ProofCategory category,
    ProofVisibility visibility = ProofVisibility.public,
    List<String> tags = const [],
    LicenseInfo? license,
    bool storeOnChain = true,
  }) async {
    if (_authService?.currentUser == null) {
      _error = 'Not authenticated';
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      _uploadProgress = 0;
      _error = null;
      notifyListeners();

      final user = _authService!.currentUser!;
      final proofId = _uuid.v4();
      final fileBytes = await file.readAsBytes();
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName).toLowerCase();
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

      // Step 1: Generate hash
      debugPrint('Generating file hash...');
      final fileHash = HashService.generateHash(fileBytes);
      _uploadProgress = 0.1;
      notifyListeners();

      // Step 2: Upload file to Firebase Storage
      debugPrint('Uploading file to storage...');
      final storagePath = 'proofs/${user.uid}/$proofId$fileExtension';
      final storageRef = _storage.ref().child(storagePath);
      
      final uploadTask = storageRef.putData(
        fileBytes,
        SettableMetadata(contentType: mimeType),
      );

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = 0.1 + (snapshot.bytesTransferred / snapshot.totalBytes) * 0.4;
        notifyListeners();
      });

      await uploadTask;
      final fileUrl = await storageRef.getDownloadURL();
      _uploadProgress = 0.5;
      notifyListeners();

      // Step 3: Generate thumbnail for images
      String? thumbnailUrl;
      if (mimeType.startsWith('image/')) {
        // In production, use a cloud function to generate thumbnails
        thumbnailUrl = fileUrl;
      }

      // Step 4: Store on blockchain (optional)
      String? transactionHash;
      int? blockNumber;
      
      if (storeOnChain && _walletService?.isConnected == true) {
        debugPrint('Storing proof on blockchain...');
        _uploadProgress = 0.6;
        notifyListeners();

        try {
          final blockchainResult = await BlockchainService.storeProof(
            walletService: _walletService!,
            fileHash: fileHash,
            timestamp: DateTime.now(),
          );
          
          transactionHash = blockchainResult['transactionHash'];
          blockNumber = blockchainResult['blockNumber'];
          _uploadProgress = 0.8;
          notifyListeners();
        } catch (e) {
          debugPrint('Blockchain storage failed: $e');
          // Continue without blockchain - proof still valid with hash
        }
      }

      // Step 5: Save to Firestore
      debugPrint('Saving proof to database...');
      final proof = ProofModel(
        id: proofId,
        creatorId: user.uid,
        creatorName: user.displayName,
        creatorPhotoUrl: user.photoUrl,
        title: title,
        description: description,
        fileUrl: fileUrl,
        thumbnailUrl: thumbnailUrl,
        fileName: fileName,
        fileType: mimeType,
        fileSize: fileBytes.length,
        fileHash: fileHash,
        transactionHash: transactionHash,
        blockNumber: blockNumber,
        contractAddress: transactionHash != null 
            ? _walletService?.contractAddress 
            : null,
        category: category,
        visibility: visibility,
        status: transactionHash != null 
            ? ProofStatus.verified 
            : ProofStatus.pending,
        tags: tags,
        createdAt: DateTime.now(),
        verifiedAt: transactionHash != null ? DateTime.now() : null,
        license: license,
      );

      await _firestore.collection('proofs').doc(proofId).set(proof.toMap());

      // Update user stats
      await _firestore.collection('users').doc(user.uid).update({
        'stats.totalProofs': FieldValue.increment(1),
      });

      _uploadProgress = 1.0;
      _userProofs.insert(0, proof);
      _isLoading = false;
      notifyListeners();

      return proof;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Create proof error: $e');
      return null;
    }
  }

  /// Load current user's proofs
  Future<void> loadUserProofs() async {
    if (_authService?.currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('proofs')
          .where('creatorId', isEqualTo: _authService!.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _userProofs = querySnapshot.docs
          .map((doc) => ProofModel.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load public proofs for explore page
  Future<void> loadPublicProofs({
    ProofCategory? category,
    int limit = 20,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      Query query = _firestore
          .collection('proofs')
          .where('visibility', isEqualTo: ProofVisibility.public.name)
          .where('status', isEqualTo: ProofStatus.verified.name);

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      _publicProofs = querySnapshot.docs
          .map((doc) => ProofModel.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a single proof by ID
  Future<ProofModel?> getProofById(String proofId) async {
    try {
      final doc = await _firestore.collection('proofs').doc(proofId).get();
      if (doc.exists) {
        return ProofModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Verify a proof by hash
  Future<ProofModel?> verifyByHash(String hash) async {
    try {
      final querySnapshot = await _firestore
          .collection('proofs')
          .where('fileHash', isEqualTo: hash.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProofModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Verify a file against stored proofs
  Future<ProofModel?> verifyFile(Uint8List fileBytes) async {
    final hash = HashService.generateHash(fileBytes);
    return verifyByHash(hash);
  }

  /// Like a proof
  Future<void> likeProof(String proofId) async {
    if (_authService?.currentUser == null) return;

    try {
      final userId = _authService!.currentUser!.uid;
      final likeRef = _firestore
          .collection('proofs')
          .doc(proofId)
          .collection('likes')
          .doc(userId);

      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        // Unlike
        await likeRef.delete();
        await _firestore.collection('proofs').doc(proofId).update({
          'stats.likes': FieldValue.increment(-1),
        });
      } else {
        // Like
        await likeRef.set({'createdAt': FieldValue.serverTimestamp()});
        await _firestore.collection('proofs').doc(proofId).update({
          'stats.likes': FieldValue.increment(1),
        });
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Check if user has liked a proof
  Future<bool> hasLikedProof(String proofId) async {
    if (_authService?.currentUser == null) return false;

    try {
      final doc = await _firestore
          .collection('proofs')
          .doc(proofId)
          .collection('likes')
          .doc(_authService!.currentUser!.uid)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Increment view count
  Future<void> incrementViews(String proofId) async {
    try {
      await _firestore.collection('proofs').doc(proofId).update({
        'stats.views': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Increment views error: $e');
    }
  }

  /// Delete a proof
  Future<bool> deleteProof(String proofId) async {
    if (_authService?.currentUser == null) return false;

    try {
      final proof = _userProofs.firstWhere(
        (p) => p.id == proofId,
        orElse: () => throw Exception('Proof not found'),
      );

      // Check ownership
      if (proof.creatorId != _authService!.currentUser!.uid) {
        throw Exception('Not authorized');
      }

      // Delete from storage
      try {
        final storageRef = _storage.refFromURL(proof.fileUrl);
        await storageRef.delete();
      } catch (e) {
        debugPrint('Storage delete error: $e');
      }

      // Delete from Firestore
      await _firestore.collection('proofs').doc(proofId).delete();

      // Update user stats
      await _firestore.collection('users').doc(proof.creatorId).update({
        'stats.totalProofs': FieldValue.increment(-1),
      });

      _userProofs.removeWhere((p) => p.id == proofId);
      notifyListeners();
      return true;

    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
