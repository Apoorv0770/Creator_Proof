import 'package:cloud_firestore/cloud_firestore.dart';

enum ProofCategory {
  art,
  music,
  writing,
  photography,
  video,
  design,
  code,
  other,
}

enum ProofVisibility {
  public,
  private,
  unlisted,
}

enum ProofStatus {
  pending,
  processing,
  verified,
  failed,
}

class ProofModel {
  final String id;
  final String creatorId;
  final String creatorName;
  final String? creatorPhotoUrl;
  final String title;
  final String description;
  final String fileUrl;
  final String? thumbnailUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String fileHash; // SHA-256 hash
  final String? transactionHash;
  final int? blockNumber;
  final String? contractAddress;
  final ProofCategory category;
  final ProofVisibility visibility;
  final ProofStatus status;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final ProofStats stats;
  final LicenseInfo? license;

  ProofModel({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    this.creatorPhotoUrl,
    required this.title,
    required this.description,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.fileHash,
    this.transactionHash,
    this.blockNumber,
    this.contractAddress,
    required this.category,
    this.visibility = ProofVisibility.public,
    this.status = ProofStatus.pending,
    this.tags = const [],
    required this.createdAt,
    this.verifiedAt,
    ProofStats? stats,
    this.license,
  }) : stats = stats ?? ProofStats();

  factory ProofModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProofModel(
      id: doc.id,
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorPhotoUrl: data['creatorPhotoUrl'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      fileName: data['fileName'] ?? '',
      fileType: data['fileType'] ?? '',
      fileSize: data['fileSize'] ?? 0,
      fileHash: data['fileHash'] ?? '',
      transactionHash: data['transactionHash'],
      blockNumber: data['blockNumber'],
      contractAddress: data['contractAddress'],
      category: ProofCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => ProofCategory.other,
      ),
      visibility: ProofVisibility.values.firstWhere(
        (e) => e.name == data['visibility'],
        orElse: () => ProofVisibility.public,
      ),
      status: ProofStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProofStatus.pending,
      ),
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      stats: ProofStats.fromMap(data['stats'] ?? {}),
      license: data['license'] != null 
          ? LicenseInfo.fromMap(data['license']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorPhotoUrl': creatorPhotoUrl,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'fileHash': fileHash,
      'transactionHash': transactionHash,
      'blockNumber': blockNumber,
      'contractAddress': contractAddress,
      'category': category.name,
      'visibility': visibility.name,
      'status': status.name,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'stats': stats.toMap(),
      'license': license?.toMap(),
    };
  }

  ProofModel copyWith({
    String? transactionHash,
    int? blockNumber,
    String? contractAddress,
    ProofStatus? status,
    DateTime? verifiedAt,
    ProofStats? stats,
  }) {
    return ProofModel(
      id: id,
      creatorId: creatorId,
      creatorName: creatorName,
      creatorPhotoUrl: creatorPhotoUrl,
      title: title,
      description: description,
      fileUrl: fileUrl,
      thumbnailUrl: thumbnailUrl,
      fileName: fileName,
      fileType: fileType,
      fileSize: fileSize,
      fileHash: fileHash,
      transactionHash: transactionHash ?? this.transactionHash,
      blockNumber: blockNumber ?? this.blockNumber,
      contractAddress: contractAddress ?? this.contractAddress,
      category: category,
      visibility: visibility,
      status: status ?? this.status,
      tags: tags,
      createdAt: createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      stats: stats ?? this.stats,
      license: license,
    );
  }

  bool get isVerified => status == ProofStatus.verified && transactionHash != null;
  
  String get categoryDisplayName {
    switch (category) {
      case ProofCategory.art:
        return 'Art';
      case ProofCategory.music:
        return 'Music';
      case ProofCategory.writing:
        return 'Writing';
      case ProofCategory.photography:
        return 'Photography';
      case ProofCategory.video:
        return 'Video';
      case ProofCategory.design:
        return 'Design';
      case ProofCategory.code:
        return 'Code';
      case ProofCategory.other:
        return 'Other';
    }
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class ProofStats {
  final int views;
  final int likes;
  final int shares;
  final int downloads;

  ProofStats({
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.downloads = 0,
  });

  factory ProofStats.fromMap(Map<String, dynamic> map) {
    return ProofStats(
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      shares: map['shares'] ?? 0,
      downloads: map['downloads'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'views': views,
      'likes': likes,
      'shares': shares,
      'downloads': downloads,
    };
  }
}

class LicenseInfo {
  final String type;
  final bool commercialUse;
  final bool attribution;
  final bool derivatives;
  final String? customTerms;

  LicenseInfo({
    required this.type,
    this.commercialUse = false,
    this.attribution = true,
    this.derivatives = true,
    this.customTerms,
  });

  factory LicenseInfo.fromMap(Map<String, dynamic> map) {
    return LicenseInfo(
      type: map['type'] ?? 'All Rights Reserved',
      commercialUse: map['commercialUse'] ?? false,
      attribution: map['attribution'] ?? true,
      derivatives: map['derivatives'] ?? true,
      customTerms: map['customTerms'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'commercialUse': commercialUse,
      'attribution': attribution,
      'derivatives': derivatives,
      'customTerms': customTerms,
    };
  }
}
