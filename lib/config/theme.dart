import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_routine_app/core/constants/colors.dart';

enum AppThemeType {
  strawberry,
  peach,
  sky,
  mint,
  dark,
}

class AppTheme {
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.strawberry:
        return _buildTheme(
          primary: AppColors.strawberryPrimary,
          secondary: AppColors.strawberrySecondary,
          background: AppColors.strawberryBackground,
          surface: Colors.white,
          brightness: Brightness.light,
        );
      case AppThemeType.peach:
        return _buildTheme(
          primary: AppColors.peachPrimary,
          secondary: AppColors.peachSecondary,
          background: AppColors.peachBackground,
          surface: Colors.white,
          brightness: Brightness.light,
        );
      case AppThemeType.sky:
        return _buildTheme(
          primary: AppColors.skyPrimary,
          secondary: AppColors.skySecondary,
          background: AppColors.skyBackground,
          surface: Colors.white,
          brightness: Brightness.light,
        );
      case AppThemeType.mint:
        return _buildTheme(
          primary: AppColors.mintPrimary,
          secondary: AppColors.mintSecondary,
          background: AppColors.mintBackground,
          surface: Colors.white,
          brightness: Brightness.light,
        );
      case AppThemeType.dark:
        return _buildTheme(
          primary: AppColors.darkPrimary,
          secondary: AppColors.darkSecondary,
          background: AppColors.darkBackground,
          surface: AppColors.darkSurface,
          brightness: Brightness.dark,
        );
    }
  }

  static ThemeData _buildTheme({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Brightness brightness,
  }) {
    final baseTextTheme = brightness == Brightness.light
        ? Typography.blackMountainView
        : Typography.whiteMountainView;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: brightness == Brightness.light ? Colors.white : Colors.black,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: brightness == Brightness.light ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
