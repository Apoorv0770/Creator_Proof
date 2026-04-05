import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    final authService = context.read<AuthService>();
    await authService.signInWithGoogle();
    if (mounted) setState(() => _isSigningIn = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Animated background blobs
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  BackgroundBlob(
                    color: AppTheme.secondary,
                    size: 500,
                    offset: Offset(-200, size.height * 0.1),
                    opacity: 0.25 * _pulseAnimation.value,
                  ),
                  BackgroundBlob(
                    color: AppTheme.primary,
                    size: 400,
                    offset: Offset(size.width - 100, size.height * 0.5),
                    opacity: 0.15 * (2 - _pulseAnimation.value),
                  ),
                  BackgroundBlob(
                    color: AppTheme.accent,
                    size: 250,
                    offset: Offset(size.width * 0.5, size.height * 0.05),
                    opacity: 0.12 * _pulseAnimation.value,
                  ),
                ],
              );
            },
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo with glow
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, _) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAlpha((80 * _pulseAnimation.value).toInt()),
                                  blurRadius: 30 + (10 * _pulseAnimation.value),
                                  spreadRadius: 3 + (3 * _pulseAnimation.value),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.shield_rounded, size: 52, color: Colors.white),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Title w/ gradient
                      const GradientText(
                        text: 'CreatorShield',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Blockchain-Powered Proof of Creation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withAlpha(153),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Feature highlights
                      _buildFeatureRow(Icons.shield, 'Protect your creative work'),
                      const SizedBox(height: 14),
                      _buildFeatureRow(Icons.verified, 'Blockchain-verified ownership'),
                      const SizedBox(height: 14),
                      _buildFeatureRow(Icons.share, 'Shareable proof certificates'),

                      const Spacer(flex: 2),

                      // Sign In button
                      _buildGoogleSignInButton(),
                      const SizedBox(height: 16),

                      // Terms
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'By continuing, you agree to our Terms of Service and Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withAlpha(77),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha(204),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSigningIn ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSigningIn
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google logo
                  Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
