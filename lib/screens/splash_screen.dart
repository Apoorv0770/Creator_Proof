import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/gradient_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
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
                    size: 400 * _pulseAnimation.value,
                    offset: Offset(-100, size.height * 0.2),
                    opacity: 0.25,
                  ),
                  BackgroundBlob(
                    color: AppTheme.primary,
                    size: 300 * (2 - _pulseAnimation.value),
                    offset: Offset(size.width - 60, size.height * 0.5),
                    opacity: 0.15,
                  ),
                  BackgroundBlob(
                    color: AppTheme.accent,
                    size: 200 * _pulseAnimation.value,
                    offset: Offset(size.width * 0.3, size.height * 0.1),
                    opacity: 0.1,
                  ),
                ],
              );
            },
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing logo with pulse
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(
                                  (100 * _pulseAnimation.value).toInt(),
                                ),
                                blurRadius: 40 + (10 * _pulseAnimation.value),
                                spreadRadius: 5 + (5 * _pulseAnimation.value),
                              ),
                              BoxShadow(
                                color: AppTheme.secondary.withAlpha(
                                  (60 * _pulseAnimation.value).toInt(),
                                ),
                                blurRadius: 60,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.shield_rounded, size: 64, color: Colors.white),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Neon title
                    const GradientText(
                      text: 'CreatorShield',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Protect Your Creations',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(153),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        backgroundColor: Colors.white.withAlpha(25),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Version text at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(51),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
