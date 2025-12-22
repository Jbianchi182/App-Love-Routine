import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_routine_app/core/constants/colors.dart';

enum AppThemeType { rosa, salmao, verde, claro, escuro }

class AppTheme {
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.rosa:
        return _buildTheme(
          primary: AppColors.strawberryPrimary,
          secondary: AppColors.strawberrySecondary,
          background: AppColors.strawberryBackground,
          surface: Colors.white,
          brightness: Brightness.light,
        );
      case AppThemeType.salmao:
        return _buildTheme(
          primary: AppColors.peachPrimary,
          secondary: AppColors.peachSecondary,
          background: AppColors.peachBackground,
          surface: Colors.white,
          brightness: Brightness.light,
        );
      case AppThemeType.verde:
        return _buildTheme(
          primary: AppColors.mintPrimary,
          secondary: AppColors.mintSecondary,
          background: AppColors.mintBackground,
          surface: Colors.white,
          brightness: Brightness.light,
        );
      case AppThemeType.claro:
        return _buildTheme(
          primary: AppColors.lightPrimary,
          secondary: AppColors.lightSecondary,
          background: AppColors.lightBackground,
          surface: AppColors.lightSurface,
          brightness: Brightness.light,
        );
      case AppThemeType.escuro:
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
        foregroundColor: brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary,
        labelStyle: TextStyle(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        secondaryLabelStyle: TextStyle(
          color: brightness == Brightness.light ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        checkmarkColor: brightness == Brightness.light
            ? Colors.white
            : Colors.black,
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
          foregroundColor: brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primary,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(
              color: brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
            );
          }
          return IconThemeData(
            color: brightness == Brightness.light
                ? Colors.black54
                : Colors.white70,
          );
        }),
      ),
    );
  }
}
