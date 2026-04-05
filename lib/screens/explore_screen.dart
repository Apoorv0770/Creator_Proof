import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/proof_model.dart';
import '../services/proof_service.dart';
import '../widgets/widgets.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  ProofCategory? _selectedCategory;
  final _searchController = TextEditingController();
  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProofService>().loadPublicProofs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterByCategory(ProofCategory? category) {
    setState(() => _selectedCategory = category);
    context.read<ProofService>().loadPublicProofs(category: category);
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

  @override
  Widget build(BuildContext context) {
    final proofService = context.watch<ProofService>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientText(text: 'Explore', fontSize: 28, fontWeight: FontWeight.w800),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                      // Sort toggle
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SortChip(
                              label: '🔥 Hot',
                              isSelected: _sortBy == 'trending',
                              onTap: () => setState(() => _sortBy = 'trending'),
                            ),
                            _SortChip(
                              label: '🕐 New',
                              isSelected: _sortBy == 'recent',
                              onTap: () => setState(() => _sortBy = 'recent'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search protected works...',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withAlpha(102)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (query) {
                        // TODO: Implement search
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category filter with icons
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip(null, 'All', Icons.apps),
                  ...ProofCategory.values.map((cat) => _buildCategoryChip(
                    cat,
                    cat.name[0].toUpperCase() + cat.name.substring(1),
                    _getCategoryIcon(cat),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Proofs list
            Expanded(
              child: proofService.isLoading
                  ? _buildSkeletonList()
                  : proofService.publicProofs.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.explore_off,
                          title: 'No works found',
                          subtitle: 'Be the first to protect your creation!',
                          actionLabel: 'Create Proof',
                          onAction: () {},
                        )
                      : RefreshIndicator(
                          color: AppTheme.primary,
                          backgroundColor: AppTheme.surface,
                          onRefresh: () => proofService.loadPublicProofs(category: _selectedCategory),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: proofService.publicProofs.length,
                            itemBuilder: (context, index) {
                              final proof = proofService.publicProofs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProofCard(proof: proof, showCreator: true),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ProofCategory? category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _filterByCategory(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white.withAlpha(25),
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: AppTheme.primary.withAlpha(51), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.white.withAlpha(128)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.white.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SkeletonProofCard(),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.white.withAlpha(128),
          ),
        ),
      ),
    );
  }
}
