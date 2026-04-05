import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType {
  plagiarism,
  copyright,
  inappropriate,
  spam,
  other,
}

enum ReportStatus {
  pending,
  reviewing,
  resolved,
  dismissed,
}

class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String proofId;
  final String proofTitle;
  final String creatorId;
  final ReportType type;
  final String description;
  final List<String> evidenceUrls;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolution;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.proofId,
    required this.proofTitle,
    required this.creatorId,
    required this.type,
    required this.description,
    this.evidenceUrls = const [],
    this.status = ReportStatus.pending,
    required this.createdAt,
    this.resolvedAt,
    this.resolution,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? '',
      proofId: data['proofId'] ?? '',
      proofTitle: data['proofTitle'] ?? '',
      creatorId: data['creatorId'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ReportType.other,
      ),
      description: data['description'] ?? '',
      evidenceUrls: List<String>.from(data['evidenceUrls'] ?? []),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      resolution: data['resolution'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reporterName': reporterName,
      'proofId': proofId,
      'proofTitle': proofTitle,
      'creatorId': creatorId,
      'type': type.name,
      'description': description,
      'evidenceUrls': evidenceUrls,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolution': resolution,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case ReportType.plagiarism:
        return 'Plagiarism';
      case ReportType.copyright:
        return 'Copyright Violation';
      case ReportType.inappropriate:
        return 'Inappropriate Content';
      case ReportType.spam:
        return 'Spam';
      case ReportType.other:
        return 'Other';
    }
  }
}
