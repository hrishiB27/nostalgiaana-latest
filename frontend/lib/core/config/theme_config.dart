import 'package:flutter/material.dart';

/// "Modern Retro" palette lifted from the Nostalgiaana logo.
class AppColors {
  const AppColors._();

  static const charcoal = Color(0xFF212121);
  static const offWhite = Color(0xFFF5F5F0);
  static const crimson = Color(0xFFD32F2F);
  static const teal = Color(0xFF00897B);
  static const gold = Color(0xFFFBC02D);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      surface: AppColors.charcoal,
      primary: AppColors.crimson,
      secondary: AppColors.teal,
      tertiary: AppColors.gold,
      error: AppColors.gold,
      onSurface: AppColors.offWhite,
      onPrimary: AppColors.offWhite,
      onSecondary: AppColors.offWhite,
      onError: AppColors.charcoal,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.charcoal,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.offWhite,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: AppColors.offWhite),
        bodySmall: TextStyle(color: Color(0xB3F5F5F0)),
      ),
      iconTheme: const IconThemeData(color: AppColors.offWhite),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.offWhite,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        labelStyle: const TextStyle(color: AppColors.offWhite),
        hintStyle: TextStyle(color: AppColors.offWhite.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          foregroundColor: AppColors.offWhite,
          disabledBackgroundColor: AppColors.crimson.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.offWhite.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.teal),
      ),
    );
  }
}
