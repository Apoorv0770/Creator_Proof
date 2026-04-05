import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/auth_service.dart';
import 'services/wallet_service.dart';
import 'services/proof_service.dart';
import 'services/community_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
    // Continue anyway - will show error in UI
  }
  
  // Prefetch Google Fonts
  GoogleFonts.config.allowRuntimeFetching = true;
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const CreatorProofApp());
}

class CreatorProofApp extends StatelessWidget {
  const CreatorProofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => WalletService()),
        ChangeNotifierProxyProvider<AuthService, ProofService>(
          create: (_) => ProofService(),
          update: (_, auth, proof) => proof!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, CommunityService>(
          create: (_) => CommunityService(),
          update: (_, auth, community) => community!..updateAuth(auth),
        ),
      ],
      child: MaterialApp(
        title: 'CreatorShield',
        debugShowCheckedModeBanner: false,
        // Always use dark neon theme
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showOnboarding = false;
  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('onboarding_complete') ?? false;
      if (mounted) {
        setState(() {
          _showOnboarding = !completed;
          _onboardingChecked = true;
        });
      }
    } catch (e) {
      // If SharedPreferences fails, skip onboarding
      if (mounted) {
        setState(() {
          _showOnboarding = false;
          _onboardingChecked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Show splash screen while checking auth state or onboarding
        if (authService.isLoading || !_onboardingChecked) {
          return const SplashScreen();
        }
        
        // Show onboarding screen for first-time users
        if (_showOnboarding) {
          return OnboardingScreen(
            onComplete: () {
              if (mounted) setState(() => _showOnboarding = false);
            },
          );
        }
        
        // Show home if authenticated, login if not
        if (authService.isAuthenticated) {
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}
