import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Font Helpers - Baloo Thammudu 2 untuk judul, Inter untuk body
class AppFonts {
  // JUDUL & HEADING - Baloo Thammudu 2
  static TextStyle title({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textDark,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.balooThammudu2(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // BODY, LABEL, PENJELASAN - Inter
  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textDark,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
        fontStyle: fontStyle,
      );

  // Shortcut untuk tombol (Inter semibold)
  static TextStyle button({
    double fontSize = 15,
    Color color = Colors.white,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
      );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.creamBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        surface: AppColors.creamBackground,
        onPrimary: Colors.white,
        onSurface: AppColors.textDark,
      ),
      textTheme: TextTheme(
        // Headings → Baloo Thammudu 2
        displayLarge: GoogleFonts.balooThammudu2(color: AppColors.textDark, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.balooThammudu2(color: AppColors.textDark, fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.balooThammudu2(color: AppColors.textDark, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.balooThammudu2(color: AppColors.textDark, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.balooThammudu2(color: AppColors.textDark, fontWeight: FontWeight.w700),
        headlineSmall: GoogleFonts.balooThammudu2(color: AppColors.textDark, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.balooThammudu2(color: AppColors.textDark, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.balooThammudu2(color: AppColors.textDark, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.balooThammudu2(color: AppColors.textDark, fontWeight: FontWeight.w600),

        // Body & Label → Inter
        bodyLarge: GoogleFonts.inter(color: AppColors.textDark),
        bodyMedium: GoogleFonts.inter(color: AppColors.textDark),
        bodySmall: GoogleFonts.inter(color: AppColors.textMedium),
        labelLarge: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.inter(color: AppColors.textMedium, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.inter(color: AppColors.textLight, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.creamBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.balooThammudu2(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryGreen,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardTheme(
        color: AppColors.creamCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.beigeAccent, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
