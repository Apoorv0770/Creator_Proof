import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/widgets.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final walletService = context.watch<WalletService>();
    final user = authService.currentUser;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Cover gradient banner
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.secondary.withAlpha(100),
                  AppTheme.primary.withAlpha(60),
                  AppTheme.background,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          BackgroundBlob(
            color: AppTheme.accent,
            size: 200,
            offset: Offset(size.width - 80, 20),
            opacity: 0.15,
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Top actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const GradientText(
                        text: 'Profile',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      Row(
                        children: [
                          // Share profile
                          _ActionButton(
                            icon: Icons.share_outlined,
                            onTap: () {
                              Share.share(
                                '🎨 Check out my verified portfolio on CreatorShield!\nhttps://creatorproof.app/profile/${user?.uid ?? ''}',
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          // Edit profile
                          _ActionButton(
                            icon: Icons.edit_outlined,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile header
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),

                  // Stats
                  _buildStats(user),
                  const SizedBox(height: 24),

                  // Wallet section
                  _buildWalletSection(context, walletService, authService),
                  const SizedBox(height: 24),

                  // Menu items
                  _buildMenuSection(context, authService),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Column(
      children: [
        // Avatar with gradient neon border
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(77),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.surface,
            backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
            child: user?.photoUrl == null
                ? Text(user?.displayName.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontSize: 32, color: AppTheme.primary, fontWeight: FontWeight.bold))
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(user?.displayName ?? 'Creator',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(user?.email ?? '', style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14)),
        if (user?.isVerified ?? false) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary.withAlpha(38), AppTheme.secondary.withAlpha(25)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withAlpha(77)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: AppTheme.primary, size: 16),
                SizedBox(width: 6),
                Text('Verified Creator', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStats(user) {
    final stats = user?.stats;
    return Row(
      children: [
        Expanded(child: _AnimatedStatItem(value: stats?.totalProofs ?? 0, label: 'Protected')),
        const SizedBox(width: 10),
        Expanded(child: _AnimatedStatItem(value: stats?.followers ?? 0, label: 'Followers')),
        const SizedBox(width: 10),
        Expanded(child: _AnimatedStatItem(value: stats?.following ?? 0, label: 'Following')),
      ],
    );
  }

  Widget _buildWalletSection(BuildContext context, WalletService walletService, AuthService authService) {
    return GradientBorderCard(
      gradientColors: walletService.isConnected
          ? [AppTheme.success.withAlpha(100), AppTheme.primary.withAlpha(51)]
          : [Colors.white.withAlpha(38), Colors.white.withAlpha(13)],
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconCircle(
                icon: Icons.account_balance_wallet,
                color: walletService.isConnected ? AppTheme.success : AppTheme.primary,
                size: 38,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              StatusBadge(
                text: walletService.isConnected ? 'Connected' : 'Not Connected',
                color: walletService.isConnected ? AppTheme.success : Colors.grey,
                icon: walletService.isConnected ? Icons.check_circle : Icons.circle_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (walletService.isConnected) ...[
            Text('Address', style: TextStyle(color: Colors.white.withAlpha(102), fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                walletService.walletAddress ?? '',
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.withAlpha(204)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance', style: TextStyle(color: Colors.white.withAlpha(102), fontSize: 12)),
                GradientText(
                  text: '${walletService.balance?.toStringAsFixed(4) ?? '0'} MATIC',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Network', style: TextStyle(color: Colors.white.withAlpha(102), fontSize: 12)),
                Text(walletService.networkName, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            GradientOutlineButton(
              text: 'Disconnect Wallet',
              icon: Icons.logout,
              onPressed: () async {
                await walletService.disconnectWallet();
                await authService.updateUserProfile(walletAddress: null);
              },
            ),
          ] else ...[
            Text('Connect your wallet to secure your proofs permanently',
                style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 13)),
            const SizedBox(height: 14),
            GradientButton(
              text: 'Connect Wallet',
              icon: Icons.link,
              onPressed: () async {
                final address = await walletService.connectWallet();
                if (address != null) {
                  await authService.updateUserProfile(walletAddress: address);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthService authService) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildMenuItem(context, Icons.history, 'Activity History', () {},
              subtitle: 'View your recent activity'),
          Divider(height: 1, color: Colors.white.withAlpha(20)),
          _buildMenuItem(context, Icons.favorite, 'Liked Works', () {},
              subtitle: 'Works you\'ve endorsed'),
          Divider(height: 1, color: Colors.white.withAlpha(20)),
          _buildMenuItem(context, Icons.settings, 'Settings', () => _showSettings(context),
              subtitle: 'App preferences'),
          Divider(height: 1, color: Colors.white.withAlpha(20)),
          _buildMenuItem(context, Icons.help_outline, 'Help & Support', () {},
              subtitle: 'FAQ and contact us'),
          Divider(height: 1, color: Colors.white.withAlpha(20)),
          _buildMenuItem(
            context,
            Icons.logout,
            'Sign Out',
            () => _showSignOutDialog(context, authService),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false, String? subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? AppTheme.error : AppTheme.primary).withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? AppTheme.error : AppTheme.primary, size: 20),
      ),
      title: Text(label, style: TextStyle(color: isDestructive ? AppTheme.error : Colors.white, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(77), fontSize: 12))
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.white.withAlpha(51), size: 20),
      onTap: onTap,
    );
  }

  void _showSettings(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BottomSheetHandle(),
            const SizedBox(height: 12),
            const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text('Always on', style: TextStyle(color: Colors.white.withAlpha(128))),
              value: true,
              activeColor: AppTheme.primary,
              onChanged: null,
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: Text('Receive updates', style: TextStyle(color: Colors.white.withAlpha(128))),
              value: true,
              activeColor: AppTheme.primary,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withAlpha(153))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authService.signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

/// Small action button for top bar
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

/// Animated stat item with counter
class _AnimatedStatItem extends StatelessWidget {
  final int value;
  final String label;

  const _AnimatedStatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            AnimatedCounter(
              targetValue: value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
