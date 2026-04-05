import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPageData(
      icon: Icons.shield_rounded,
      iconColor: AppTheme.primary,
      title: 'Protect Your Work',
      subtitle: 'Upload any creative work and instantly generate a tamper-proof digital fingerprint that proves you created it.',
      badgeText: '🛡️ Blockchain-Backed',
    ),
    _OnboardingPageData(
      icon: Icons.verified_rounded,
      iconColor: AppTheme.success,
      title: 'Verify Ownership',
      subtitle: 'Anyone can verify that you are the original creator. Your proof is secured permanently on the blockchain.',
      badgeText: '✅ Instant Verification',
    ),
    _OnboardingPageData(
      icon: Icons.public_rounded,
      iconColor: AppTheme.secondary,
      title: 'Showcase & Share',
      subtitle: 'Build a verified portfolio of your protected works. Share certificates and grow your creative reputation.',
      badgeText: '🚀 Public Portfolio',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background blobs
          BackgroundBlob(
            color: AppTheme.secondary,
            size: 400,
            offset: const Offset(-150, -100),
            opacity: 0.2,
          ),
          BackgroundBlob(
            color: AppTheme.primary,
            size: 300,
            offset: Offset(size.width - 80, size.height * 0.6),
            opacity: 0.12,
          ),

          // Page content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const GradientText(text: 'CreatorShield', fontSize: 16, fontWeight: FontWeight.w700),
                        ],
                      ),
                      // Skip
                      if (_currentPage < _pages.length - 1)
                        GestureDetector(
                          onTap: _completeOnboarding,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(13),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withAlpha(25)),
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) => _OnboardingPage(data: _pages[index]),
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Column(
                    children: [
                      // Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: _currentPage == index ? AppTheme.primaryGradient : null,
                              color: _currentPage == index ? null : Colors.white.withAlpha(38),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: _currentPage == index
                                  ? [BoxShadow(color: AppTheme.primary.withAlpha(77), blurRadius: 8)]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // CTA button
                      GradientButton(
                        text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                        icon: _currentPage == _pages.length - 1 ? Icons.rocket_launch : Icons.arrow_forward,
                        onPressed: _nextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badgeText;

  const _OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badgeText,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Main icon with glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [data.iconColor, data.iconColor.withAlpha(128)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: data.iconColor.withAlpha(102),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(data.icon, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: data.iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: data.iconColor.withAlpha(64)),
            ),
            child: Text(
              data.badgeText,
              style: TextStyle(color: data.iconColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 28),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withAlpha(153),
                height: 1.5,
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
