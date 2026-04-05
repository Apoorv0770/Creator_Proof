import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? walletAddress;
  final String? bio;
  final String? website;
  final List<String> skills;
  final List<SocialLink> socialLinks;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserStats stats;
  final bool isVerified;
  final String? creatorId; // Unique creator ID for public profile

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.walletAddress,
    this.bio,
    this.website,
    this.skills = const [],
    this.socialLinks = const [],
    required this.createdAt,
    this.lastLoginAt,
    UserStats? stats,
    this.isVerified = false,
    this.creatorId,
  }) : stats = stats ?? UserStats();

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      walletAddress: data['walletAddress'],
      bio: data['bio'],
      website: data['website'],
      skills: List<String>.from(data['skills'] ?? []),
      socialLinks: (data['socialLinks'] as List<dynamic>?)
          ?.map((e) => SocialLink.fromMap(e))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      stats: UserStats.fromMap(data['stats'] ?? {}),
      isVerified: data['isVerified'] ?? false,
      creatorId: data['creatorId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'walletAddress': walletAddress,
      'bio': bio,
      'website': website,
      'skills': skills,
      'socialLinks': socialLinks.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'stats': stats.toMap(),
      'isVerified': isVerified,
      'creatorId': creatorId,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? walletAddress,
    String? bio,
    String? website,
    List<String>? skills,
    List<SocialLink>? socialLinks,
    DateTime? lastLoginAt,
    UserStats? stats,
    bool? isVerified,
    String? creatorId,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      walletAddress: walletAddress ?? this.walletAddress,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      skills: skills ?? this.skills,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      stats: stats ?? this.stats,
      isVerified: isVerified ?? this.isVerified,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  String get profileUrl => 'creatorproof.app/creator/$creatorId';
}

class SocialLink {
  final String platform;
  final String url;

  SocialLink({required this.platform, required this.url});

  factory SocialLink.fromMap(Map<String, dynamic> map) {
    return SocialLink(
      platform: map['platform'] ?? '',
      url: map['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'platform': platform, 'url': url};
}

class UserStats {
  final int totalProofs;
  final int totalLikes;
  final int totalViews;
  final int followers;
  final int following;

  UserStats({
    this.totalProofs = 0,
    this.totalLikes = 0,
    this.totalViews = 0,
    this.followers = 0,
    this.following = 0,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalProofs: map['totalProofs'] ?? 0,
      totalLikes: map['totalLikes'] ?? 0,
      totalViews: map['totalViews'] ?? 0,
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalProofs': totalProofs,
      'totalLikes': totalLikes,
      'totalViews': totalViews,
      'followers': followers,
      'following': following,
    };
  }
}
