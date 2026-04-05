import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String proofId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;

  CommentModel({
    required this.id,
    required this.proofId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      proofId: data['proofId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'proofId': proofId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'likedBy': likedBy,
    };
  }
}
