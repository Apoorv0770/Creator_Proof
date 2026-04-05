import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';

class CommunityService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CommentModel> _comments = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<CommentModel> get comments => _comments;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadNotifications => _notifications.where((n) => !n.isRead).length;

  // ========== LIKES ==========

  Future<bool> likeProof(String proofId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

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
        return false;
      } else {
        // Like
        await likeRef.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _firestore.collection('proofs').doc(proofId).update({
          'stats.likes': FieldValue.increment(1),
        });

        // Send notification to proof creator
        final proofDoc =
            await _firestore.collection('proofs').doc(proofId).get();
        final creatorId = proofDoc.data()?['creatorId'];
        if (creatorId != null && creatorId != userId) {
          await _sendNotification(
            userId: creatorId,
            type: NotificationType.newLike,
            title: 'New Like!',
            body: '${_auth.currentUser?.displayName} liked your work',
            proofId: proofId,
          );
        }
        return true;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> hasLiked(String proofId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final likeDoc = await _firestore
        .collection('proofs')
        .doc(proofId)
        .collection('likes')
        .doc(userId)
        .get();
    return likeDoc.exists;
  }

  // ========== COMMENTS ==========

  Future<void> loadComments(String proofId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('proofs')
          .doc(proofId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _comments =
          snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<CommentModel?> addComment(String proofId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final comment = CommentModel(
        id: '',
        proofId: proofId,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        userPhotoUrl: user.photoURL,
        content: content,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('proofs')
          .doc(proofId)
          .collection('comments')
          .add(comment.toMap());

      // Notify proof creator
      final proofDoc = await _firestore.collection('proofs').doc(proofId).get();
      final creatorId = proofDoc.data()?['creatorId'];
      if (creatorId != null && creatorId != user.uid) {
        await _sendNotification(
          userId: creatorId,
          type: NotificationType.newComment,
          title: 'New Comment',
          body: '${user.displayName}: $content',
          proofId: proofId,
        );
      }

      return CommentModel(
        id: docRef.id,
        proofId: proofId,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        userPhotoUrl: user.photoURL,
        content: content,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<bool> deleteComment(String proofId, String commentId) async {
    try {
      await _firestore
          .collection('proofs')
          .doc(proofId)
          .collection('comments')
          .doc(commentId)
          .delete();
      _comments.removeWhere((c) => c.id == commentId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ========== FOLLOW ==========

  Future<bool> followUser(String targetUserId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId == targetUserId) return false;

      final followRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc(targetUserId);
      final followDoc = await followRef.get();

      if (followDoc.exists) {
        // Unfollow
        await followRef.delete();
        await _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(userId)
            .delete();

        await _firestore.collection('users').doc(userId).update({
          'stats.following': FieldValue.increment(-1),
        });
        await _firestore.collection('users').doc(targetUserId).update({
          'stats.followers': FieldValue.increment(-1),
        });
        return false;
      } else {
        // Follow
        await followRef.set({
          'userId': targetUserId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(userId)
            .set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('users').doc(userId).update({
          'stats.following': FieldValue.increment(1),
        });
        await _firestore.collection('users').doc(targetUserId).update({
          'stats.followers': FieldValue.increment(1),
        });

        // Notify followed user
        await _sendNotification(
          userId: targetUserId,
          type: NotificationType.newFollower,
          title: 'New Follower!',
          body: '${_auth.currentUser?.displayName} started following you',
        );
        return true;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> isFollowing(String targetUserId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .doc(targetUserId)
        .get();
    return doc.exists;
  }

  // ========== REPORTS ==========

  Future<bool> reportContent({
    required String proofId,
    required String proofTitle,
    required String creatorId,
    required ReportType type,
    required String description,
    List<String>? evidenceUrls,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final report = ReportModel(
        id: '',
        reporterId: user.uid,
        reporterName: user.displayName ?? 'Anonymous',
        proofId: proofId,
        proofTitle: proofTitle,
        creatorId: creatorId,
        type: type,
        description: description,
        evidenceUrls: evidenceUrls ?? [],
        createdAt: DateTime.now(),
      );

      await _firestore.collection('reports').add(report.toMap());
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ========== NOTIFICATIONS ==========

  Future<void> loadNotifications() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          type: _notifications[index].type,
          title: _notifications[index].title,
          body: _notifications[index].body,
          proofId: _notifications[index].proofId,
          fromUserId: _notifications[index].fromUserId,
          fromUserName: _notifications[index].fromUserName,
          fromUserPhoto: _notifications[index].fromUserPhoto,
          createdAt: _notifications[index].createdAt,
          isRead: true,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final batch = _firestore.batch();
      for (final notification in _notifications.where((n) => !n.isRead)) {
        batch.update(
            _firestore.collection('notifications').doc(notification.id),
            {'isRead': true});
      }
      await batch.commit();
      await loadNotifications();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> _sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? proofId,
  }) async {
    final fromUser = _auth.currentUser;
    final notification = NotificationModel(
      id: '',
      userId: userId,
      type: type,
      title: title,
      body: body,
      proofId: proofId,
      fromUserId: fromUser?.uid,
      fromUserName: fromUser?.displayName,
      fromUserPhoto: fromUser?.photoURL,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('notifications').add(notification.toMap());
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Called when auth state changes via ProxyProvider
  void updateAuth(dynamic authService) {
    // Reload notifications when user changes
    if (_auth.currentUser != null) {
      loadNotifications();
    } else {
      _notifications = [];
      notifyListeners();
    }
  }
}
