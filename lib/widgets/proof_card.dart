import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/proof_model.dart';
import '../models/report_model.dart';
import '../services/hash_service.dart';
import '../services/blockchain_service.dart';
import '../services/community_service.dart';
import '../services/certificate_service.dart';
import 'app_theme.dart';
import 'ui_components.dart';
import 'gradient_widgets.dart';

class ProofCard extends StatelessWidget {
  final ProofModel proof;
  final bool showCreator;
  final VoidCallback? onTap;

  const ProofCard({
    super.key,
    required this.proof,
    this.showCreator = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap ?? () => _showProofDetails(context),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with improved loading
          if (proof.thumbnailUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: proof.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.surface,
                    child: const Center(
                      child: ShimmerBox(height: double.infinity),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.surface,
                    child: const Icon(Icons.image_not_supported, color: Colors.white24),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(proof.category).withAlpha(30),
                    AppTheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(_getCategoryIcon(proof.category), size: 40, color: _getCategoryColor(proof.category).withAlpha(128)),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and verified badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        proof.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (proof.isVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: AppTheme.success, size: 14),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Creator info (optional)
                if (showCreator) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppTheme.primary.withAlpha(51),
                        backgroundImage: proof.creatorPhotoUrl != null ? NetworkImage(proof.creatorPhotoUrl!) : null,
                        child: proof.creatorPhotoUrl == null
                            ? Text(proof.creatorName.substring(0, 1), style: const TextStyle(fontSize: 10, color: AppTheme.primary))
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Text(proof.creatorName, style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(153))),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Category and date
                Row(
                  children: [
                    StatusBadge(text: proof.categoryDisplayName, color: _getCategoryColor(proof.category)),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 12, color: Colors.white.withAlpha(102)),
                    const SizedBox(width: 4),
                    Text(_formatDate(proof.createdAt), style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(102))),
                  ],
                ),
                const SizedBox(height: 8),

                // Hash preview
                Row(
                  children: [
                    Icon(Icons.fingerprint, size: 12, color: AppTheme.primary.withAlpha(153)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        HashService.formatHashForDisplay(proof.fileHash, length: 8),
                        style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white.withAlpha(102)),
                      ),
                    ),
                  ],
                ),

                // Stats with interactive like
                const SizedBox(height: 10),
                _ProofStats(proof: proof),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ProofCategory category) {
    switch (category) {
      case ProofCategory.art: return AppTheme.accent;
      case ProofCategory.music: return AppTheme.secondary;
      case ProofCategory.writing: return AppTheme.primary;
      case ProofCategory.photography: return const Color(0xFFF59E0B);
      case ProofCategory.video: return const Color(0xFFEF4444);
      case ProofCategory.design: return const Color(0xFF10B981);
      case ProofCategory.code: return const Color(0xFF6366F1);
      case ProofCategory.other: return Colors.white54;
    }
  }

  IconData _getCategoryIcon(ProofCategory category) {
    switch (category) {
      case ProofCategory.art: return Icons.palette;
      case ProofCategory.music: return Icons.music_note;
      case ProofCategory.writing: return Icons.article;
      case ProofCategory.photography: return Icons.camera_alt;
      case ProofCategory.video: return Icons.videocam;
      case ProofCategory.design: return Icons.design_services;
      case ProofCategory.code: return Icons.code;
      case ProofCategory.other: return Icons.folder;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _showProofDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const BottomSheetHandle(),
                const SizedBox(height: 8),

                // Title
                Row(
                  children: [
                    Expanded(
                      child: Text(proof.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    if (proof.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.success.withAlpha(77)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: AppTheme.success, size: 14),
                            SizedBox(width: 4),
                            Text('Verified', style: TextStyle(color: AppTheme.success, fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Creator
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary.withAlpha(51),
                      backgroundImage: proof.creatorPhotoUrl != null ? NetworkImage(proof.creatorPhotoUrl!) : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(proof.creatorName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(_formatDate(proof.createdAt), style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(128))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                if (proof.description.isNotEmpty) ...[
                  Text(proof.description, style: TextStyle(color: Colors.white.withAlpha(204))),
                  const SizedBox(height: 16),
                ],

                Divider(color: Colors.white.withAlpha(25)),
                const SizedBox(height: 16),

                // Technical details
                const Text('Protection Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                _buildDetailRow(context, 'Digital Fingerprint', proof.fileHash, copyable: true),
                _buildDetailRow(context, 'File Type', proof.fileType),
                _buildDetailRow(context, 'File Size', proof.fileSizeFormatted),
                _buildDetailRow(context, 'Category', proof.categoryDisplayName),

                if (proof.transactionHash != null) ...[
                  const SizedBox(height: 16),
                  const Text('Secured Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDetailRow(context, 'Transaction', proof.transactionHash!, copyable: true),
                  _buildDetailRow(context, 'Block', '${proof.blockNumber}'),
                  _buildDetailRow(context, 'Network', 'Polygon'),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: 'View on Explorer',
                    icon: Icons.open_in_new,
                    onPressed: () => _openExplorer(proof.transactionHash!),
                  ),
                ],

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: GradientOutlineButton(
                        text: 'Share',
                        icon: Icons.share,
                        onPressed: () => _shareProof(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        text: 'Certificate',
                        icon: Icons.download,
                        onPressed: () => _downloadCertificate(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Report button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showReportDialog(context);
                    },
                    icon: const Icon(Icons.flag_outlined, size: 16),
                    label: const Text('Report this content'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: BorderSide(color: Colors.white.withAlpha(25)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 13)),
          ),
          Expanded(
            child: copyable
                ? GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied!'), backgroundColor: AppTheme.success),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            HashService.formatHashForDisplay(value),
                            style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.withAlpha(204)),
                          ),
                        ),
                        const Icon(Icons.copy, size: 14, color: AppTheme.primary),
                      ],
                    ),
                  )
                : Text(value, style: TextStyle(color: Colors.white.withAlpha(204))),
          ),
        ],
      ),
    );
  }

  void _openExplorer(String txHash) async {
    final url = Uri.parse(BlockchainService.getExplorerUrl(txHash));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _shareProof(BuildContext context) {
    final text = '''
🎨 ${proof.title}

Created by: ${proof.creatorName}
Category: ${proof.categoryDisplayName}
Fingerprint: ${HashService.formatHashForDisplay(proof.fileHash)}
${proof.isVerified ? '✅ Permanently Protected' : ''}

Verify at: creatorproof.app/verify/${proof.fileHash}
''';
    Share.share(text);
  }

  void _downloadCertificate(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating certificate...'), backgroundColor: AppTheme.primary),
    );

    try {
      await CertificateService.generateAndShare(proof);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _showReportDialog(BuildContext context) {
    ReportType? selectedType;
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetHandle(),
              const SizedBox(height: 8),
              const Text('Report Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Why are you reporting this?', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              ...ReportType.values.map((type) => RadioListTile<ReportType>(
                title: Text(_reportTypeLabel(type)),
                value: type,
                groupValue: selectedType,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => selectedType = v),
              )),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe the issue...',
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Submit Report',
                onPressed: selectedType != null
                    ? () async {
                        final communityService = context.read<CommunityService>();
                        await communityService.reportContent(
                          proofId: proof.id,
                          proofTitle: proof.title,
                          creatorId: proof.creatorId,
                          type: selectedType!,
                          description: descController.text,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Report submitted'), backgroundColor: AppTheme.success),
                          );
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _reportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.plagiarism: return 'Plagiarism / Stolen work';
      case ReportType.copyright: return 'Copyright infringement';
      case ReportType.inappropriate: return 'Inappropriate content';
      case ReportType.spam: return 'Spam';
      case ReportType.other: return 'Other';
    }
  }
}

// Interactive stats widget with animated like button
class _ProofStats extends StatefulWidget {
  final ProofModel proof;

  const _ProofStats({required this.proof});

  @override
  State<_ProofStats> createState() => _ProofStatsState();
}

class _ProofStatsState extends State<_ProofStats> with SingleTickerProviderStateMixin {
  bool _hasLiked = false;
  int _likes = 0;
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _likes = widget.proof.stats.likes;
    _likeAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeAnimController, curve: Curves.easeInOut));
    _checkLikeStatus();
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  Future<void> _checkLikeStatus() async {
    final communityService = context.read<CommunityService>();
    final liked = await communityService.hasLiked(widget.proof.id);
    if (mounted) setState(() => _hasLiked = liked);
  }

  Future<void> _toggleLike() async {
    final communityService = context.read<CommunityService>();
    final wasLiked = _hasLiked;

    // Optimistic update with animation
    setState(() {
      _hasLiked = !_hasLiked;
      _likes += _hasLiked ? 1 : -1;
    });
    _likeAnimController.forward(from: 0);

    // Haptic feedback
    HapticFeedback.lightImpact();

    final result = await communityService.likeProof(widget.proof.id);
    if (result != _hasLiked) {
      // Revert on error
      setState(() {
        _hasLiked = wasLiked;
        _likes = widget.proof.stats.likes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.visibility, size: 14, color: Colors.white.withAlpha(102)),
        const SizedBox(width: 4),
        Text('${widget.proof.stats.views}', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(128))),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _toggleLike,
          child: Row(
            children: [
              ScaleTransition(
                scale: _likeScaleAnimation,
                child: Icon(
                  _hasLiked ? Icons.favorite : Icons.favorite_border,
                  size: 14,
                  color: _hasLiked ? Colors.red : Colors.white.withAlpha(102),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$_likes',
                style: TextStyle(fontSize: 12, color: _hasLiked ? Colors.red : Colors.white.withAlpha(128)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
