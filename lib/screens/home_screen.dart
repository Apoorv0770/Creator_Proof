import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../services/proof_service.dart';
import '../services/community_service.dart';
import '../widgets/widgets.dart';
import 'upload_screen.dart';
import 'verify_screen.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardPage(),
    ExploreScreen(),
    UploadScreen(),
    VerifyScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletService>().initWalletConnect();
      context.read<ProofService>().loadUserProofs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.primary.withAlpha(38))),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withAlpha(13),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: AppTheme.primary.withAlpha(38),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppTheme.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore, color: AppTheme.primary),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, size: 28),
              selectedIcon: Icon(Icons.add_circle, color: AppTheme.primary, size: 28),
              label: 'Create',
            ),
            NavigationDestination(
              icon: Icon(Icons.verified_outlined),
              selectedIcon: Icon(Icons.verified, color: AppTheme.primary),
              label: 'Verify',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppTheme.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final walletService = context.watch<WalletService>();
    final proofService = context.watch<ProofService>();
    final communityService = context.watch<CommunityService>();
    final user = authService.currentUser;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background gradient blobs
          BackgroundBlob(
            color: AppTheme.secondary,
            size: 300,
            offset: const Offset(-100, -50),
            opacity: 0.2,
          ),
          BackgroundBlob(
            color: AppTheme.primary,
            size: 200,
            offset: Offset(size.width - 50, 200),
            opacity: 0.1,
          ),

          // Main content
          SafeArea(
            child: RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              onRefresh: () => proofService.loadUserProofs(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, user, walletService, communityService),
                    const SizedBox(height: 24),

                    // Tip of the Day card
                    _buildTipCard(),
                    const SizedBox(height: 24),

                    // Stats cards
                    _buildStatsSection(context, user, proofService),
                    const SizedBox(height: 24),

                    // Quick actions
                    _buildQuickActions(context),
                    const SizedBox(height: 24),

                    // Recent proofs
                    _buildRecentProofs(context, proofService),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user, WalletService walletService, CommunityService communityService) {
    final unreadCount = communityService.unreadNotifications;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GradientText(
                    text: 'CreatorShield',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'BETA',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${_getGreeting()}, ${user.displayName.split(' ').first}! 👋',
                    style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
        // Notifications button
        _HeaderButton(
          icon: Icons.notifications_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          badgeCount: unreadCount,
        ),
        const SizedBox(width: 10),
        // Wallet status button
        _WalletButton(
          isConnected: walletService.isConnected,
          onTap: () => _showWalletModal(context, walletService),
        ),
      ],
    );
  }

  Widget _buildTipCard() {
    final tips = [
      {'icon': Icons.lightbulb_outline, 'text': 'Upload your creative work to get instant blockchain-backed proof of ownership.', 'label': '💡 Quick Tip'},
      {'icon': Icons.security, 'text': 'Connect your wallet for permanent, tamper-proof protection on the blockchain.', 'label': '🔐 Security Tip'},
      {'icon': Icons.share, 'text': 'Share your verified portfolio link to showcase your protected works.', 'label': '🚀 Pro Tip'},
    ];
    final tip = tips[DateTime.now().day % tips.length];

    return GradientBorderCard(
      gradientColors: [AppTheme.primary.withAlpha(100), AppTheme.secondary.withAlpha(60)],
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tip['icon'] as IconData, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['label'] as String,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['text'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(179), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, user, ProofService proofService) {
    final stats = user?.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.accent.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accent.withAlpha(77)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart, size: 14, color: AppTheme.accent),
                  SizedBox(width: 4),
                  Text(
                    'Your Stats',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _EnhancedStatCard(
                icon: Icons.shield,
                label: 'Protected',
                value: proofService.userProofs.length,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EnhancedStatCard(
                icon: Icons.favorite,
                label: 'Likes',
                value: stats?.totalLikes ?? 0,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EnhancedStatCard(
                icon: Icons.visibility,
                label: 'Views',
                value: stats?.totalViews ?? 0,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                icon: Icons.add_photo_alternate_outlined,
                title: 'Protect Work',
                description: 'Create new proof',
                iconColor: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FeatureCard(
                icon: Icons.search_rounded,
                title: 'Verify',
                description: 'Check ownership',
                iconColor: AppTheme.secondary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerifyScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentProofs(BuildContext context, ProofService proofService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your Protected Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (proofService.isLoading)
          // Skeleton loading
          Column(
            children: List.generate(2, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SkeletonProofCard(),
            )),
          )
        else if (proofService.userProofs.isEmpty)
          _EmptyState(
            icon: Icons.shield_outlined,
            title: 'No protected works yet',
            subtitle: 'Protect your first creation to get started',
            actionLabel: 'Protect Now',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadScreen()),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: proofService.userProofs.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final proof = proofService.userProofs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProofCard(proof: proof),
              );
            },
          ),
      ],
    );
  }

  void _showWalletModal(BuildContext context, WalletService walletService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: walletService.isConnected
                    ? LinearGradient(colors: [AppTheme.success.withAlpha(77), AppTheme.success.withAlpha(25)])
                    : LinearGradient(colors: [AppTheme.primary.withAlpha(51), AppTheme.secondary.withAlpha(25)]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                walletService.isConnected ? Icons.check_circle : Icons.account_balance_wallet,
                size: 48,
                color: walletService.isConnected ? AppTheme.success : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              walletService.isConnected ? 'Wallet Connected' : 'Connect Wallet',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (walletService.isConnected) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(25)),
                ),
                child: Text(
                  '${walletService.walletAddress?.substring(0, 10)}...${walletService.walletAddress?.substring(walletService.walletAddress!.length - 8)}',
                  style: TextStyle(color: Colors.white.withAlpha(179), fontFamily: 'monospace', fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              GradientText(
                text: '${walletService.balance?.toStringAsFixed(4) ?? '0'} MATIC',
                fontSize: 20,
              ),
              const SizedBox(height: 24),
              GradientOutlineButton(
                text: 'Disconnect',
                icon: Icons.logout,
                onPressed: () {
                  walletService.disconnectWallet();
                  Navigator.pop(context);
                },
              ),
            ] else ...[
              Text(
                'Connect your wallet to secure your proofs permanently on the blockchain',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(153), height: 1.5),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Connect Wallet',
                icon: Icons.account_balance_wallet,
                onPressed: () async {
                  await walletService.connectWallet();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Header button with optional badge
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            if (badgeCount > 0)
              Positioned(
                top: -6, right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Wallet connection button
class _WalletButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onTap;

  const _WalletButton({
    required this.isConnected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          gradient: isConnected
              ? LinearGradient(colors: [AppTheme.success.withAlpha(64), AppTheme.success.withAlpha(25)])
              : null,
          color: isConnected ? null : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected ? AppTheme.success.withAlpha(128) : Colors.white.withAlpha(20),
          ),
        ),
        child: Icon(
          isConnected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
          color: isConnected ? AppTheme.success : Colors.white70,
          size: 22,
        ),
      ),
    );
  }
}

/// Enhanced stat card with animated counter
class _EnhancedStatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _EnhancedStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      gradientColors: [color.withAlpha(153), color.withAlpha(51)],
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          AnimatedCounter(
            targetValue: value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget with gradient styling
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      gradientColors: [Colors.white24, Colors.white10],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary.withAlpha(38), AppTheme.secondary.withAlpha(25)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppTheme.primary.withAlpha(153)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withAlpha(153)),
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: actionLabel,
              onPressed: onAction,
              width: 180,
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to allow .let syntax
extension LetExtension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
