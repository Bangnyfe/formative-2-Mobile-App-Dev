import 'package:flutter/material.dart';

/// Brand colours used across the app.
class AppColors {
  AppColors._();

  // Sky blue brand colour with hot pink accents.
  static const primary = Color(0xFF0593C6);
  static const primaryDark = Color(0xFF04729A);
  static const primaryLight = Color(0xFFE2F3FA);
  static const accent = Color(0xFFD83995);
  static const accentLight = Color(0xFFFBE6F1);

  // Cool, slightly blue-tinted neutrals so the greys sit well with the brand.
  static const background = Color(0xFFF4F8FB);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0F2433);
  static const textSecondary = Color(0xFF5E7282);
  static const border = Color(0xFFDDE8EF);

  // Status colours, chosen to stay distinct from the sky blue and hot pink:
  // info is indigo rather than blue, and danger is a warm red, not pink.
  static const success = Color(0xFF1F9D6B);
  static const warning = Color(0xFFE59A1A);
  static const info = Color(0xFF5B5FD6);
  static const danger = Color(0xFFE0483A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      tertiary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
