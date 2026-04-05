import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme Configuration - CreatorShield Dark Theme
/// Premium SaaS design matching web app: ownify-sigma.vercel.app
class AppTheme {
  // Brand Colors - matching web app
  static const Color primary = Color(0xFF00D1FF); // Cyan neon
  static const Color secondary = Color(0xFF7C3AED); // Purple
  static const Color accent = Color(0xFFFF1493); // Pink/Magenta for highlights
  static const Color background = Color(0xFF0A0A1A); // Darker navy (matching web)
  static const Color surface = Color(0xFF0F172A); // Dark slate
  static const Color surfaceLight = Color(0xFF1E293B); // Lighter slate
  static const Color cardBg = Color(0xFF12142A); // Card background
  static const Color surfaceVariant = Color(0xFF1A1C3A); // Slightly lighter card variant

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradients - matching web app
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient borderGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF151530), Color(0xFF0F172A)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF2D3B4F), Color(0xFF1E293B)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );

  // Purple blob gradient (for background decorations)
  static const RadialGradient purpleBlob = RadialGradient(
    colors: [Color(0xFF7C3AED), Colors.transparent],
    stops: [0.0, 1.0],
  );

  // Cyan blob gradient
  static const RadialGradient cyanBlob = RadialGradient(
    colors: [Color(0xFF00D1FF), Colors.transparent],
    stops: [0.0, 1.0],
  );

  // Text theme using Google Fonts (Inter for clean SaaS feel)
  static TextTheme get _textTheme {
    return GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.3),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textSecondary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.5),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted),
      ),
    );
  }

  /// Dark Theme — the only theme for CreatorShield
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    textTheme: _textTheme,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: surface.withAlpha(128),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withAlpha(25)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight.withAlpha(128),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withAlpha(25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
      hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: primary.withAlpha(51),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: primary);
        }
        return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted);
      }),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: surfaceLight,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withAlpha(20),
      thickness: 1,
    ),
  );

  // Helper method for consistent box shadow glow
  static List<BoxShadow> glowShadow(Color color, {double blur = 20, double spread = -5, double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withAlpha((opacity * 255).toInt()),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }

  // Helper for gradient border decoration
  static BoxDecoration gradientBorderDecoration({
    List<Color>? colors,
    double borderRadius = 16,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: colors ?? [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
