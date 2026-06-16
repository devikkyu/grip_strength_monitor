import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFFF6B9D);
  static const Color primaryLightPink = Color(0xFFFFB3D1);
  static const Color primaryDarkPink = Color(0xFFE84D8A);
  static const Color primaryBlue = Color(0xFFFF6B9D);
  static const Color primaryLightBlue = Color(0xFFFFB3D1);
  static const Color accentGreen = Color(0xFF7DD3A8);
  static const Color accentLightGreen = Color(0xFFA8E6CF);
  static const Color backgroundWhite = Color(0xFFFFF5F8);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color cardWhite = Colors.white;
  static const Color cardDark = Color(0xFF2D2D44);
  static const Color warningOrange = Color(0xFFFFB366);
  static const Color riskRed = Color(0xFFFF6B6B);
  static const Color textPrimary = Color(0xFF2D2D44);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color separator = Color(0xFFE8E8E8);
  static const Color systemGray6 = Color(0xFFF5F5F5);

  static TextStyle _thaiStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.sarabun(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle get headlineLarge => _thaiStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3);
  static TextStyle get headlineMedium => _thaiStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3);
  static TextStyle get titleLarge => _thaiStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3);
  static TextStyle get titleMedium => _thaiStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3);
  static TextStyle get bodyLarge => _thaiStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.5);
  static TextStyle get bodyMedium => _thaiStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary, height: 1.5);
  static TextStyle get bodySmall => _thaiStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary, height: 1.4);
  static TextStyle get labelLarge => _thaiStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3);
  static TextStyle get labelMedium => _thaiStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, height: 1.3);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.sarabunTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundWhite,
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textPrimary),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundWhite,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.sarabun(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryPink.withValues(alpha: 0.15),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.sarabun(color: primaryPink, fontSize: 11, fontWeight: FontWeight.w600);
          }
          return GoogleFonts.sarabun(color: textSecondary, fontSize: 11);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      dividerTheme: const DividerThemeData(color: separator, thickness: 0.5, space: 0.5),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.sarabunTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: Colors.white),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: Colors.white),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.sarabun(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1C1C1E).withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryPink.withValues(alpha: 0.2),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.sarabun(color: primaryPink, fontSize: 11, fontWeight: FontWeight.w600);
          }
          return GoogleFonts.sarabun(color: textSecondary, fontSize: 11);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF38383A), thickness: 0.5, space: 0.5),
    );
  }
}
