import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  proofCreated,
  proofVerified,
  newLike,
  newComment,
  newFollower,
  systemAlert,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? proofId;
  final String? fromUserId;
  final String? fromUserName;
  final String? fromUserPhoto;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.proofId,
    this.fromUserId,
    this.fromUserName,
    this.fromUserPhoto,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      proofId: data['proofId'],
      fromUserId: data['fromUserId'],
      fromUserName: data['fromUserName'],
      fromUserPhoto: data['fromUserPhoto'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'proofId': proofId,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserPhoto': fromUserPhoto,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
