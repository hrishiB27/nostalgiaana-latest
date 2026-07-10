import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Modern Retro" cream/crimson palette — the app's one and only theme.
/// `charcoal` is the primary text/icon color (dark-on-light); `cream`/
/// `panelCream` are the two background tones.
class AppColors {
  const AppColors._();

  static const cream = Color(0xFFFDFBF7);
  static const panelCream = Color(0xFFFDF5EC);
  /// Dashboard/screen background — deliberately more visibly beige than
  /// [cream] (used by the splash screen and sheet surfaces, which stay
  /// unchanged) or [panelCream] (used for input fields/panels).
  static const beige = Color(0xFFF2E8D5);
  /// One shade darker than [beige], used only by [CommandHeaderBar] to read
  /// as a distinct raised panel against the page background.
  static const headerBeige = Color(0xFFE8DAC0);
  static const crimson = Color(0xFFC62828);
  static const teal = Color(0xFF00897B);
  static const gold = Color(0xFFFBC02D);
  static const charcoal = Color(0xFF212121);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get theme {
    final base = GoogleFonts.interTextTheme();
    final textTheme = base.copyWith(
      headlineLarge: GoogleFonts.playfairDisplay(
        color: AppColors.charcoal,
        fontWeight: FontWeight.w700,
        fontSize: 28,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        color: AppColors.crimson,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: AppColors.charcoal,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      bodyMedium: GoogleFonts.inter(color: AppColors.charcoal, fontSize: 14),
      bodySmall: GoogleFonts.inter(color: AppColors.charcoal.withValues(alpha: 0.65), fontSize: 13),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        surface: AppColors.beige,
        primary: AppColors.crimson,
        secondary: AppColors.teal,
        tertiary: AppColors.gold,
        error: AppColors.crimson,
        onSurface: AppColors.charcoal,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.beige,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: AppColors.charcoal),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.beige,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.charcoal,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panelCream,
        labelStyle: GoogleFonts.inter(color: AppColors.charcoal.withValues(alpha: 0.7)),
        hintStyle: GoogleFonts.inter(color: AppColors.charcoal.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.crimson.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.crimson.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.crimson, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.crimson, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.crimson.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
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

  /// The script-style "Where Memories Matter" tagline under the logo badge.
  static TextStyle get taglineStyle => GoogleFonts.dancingScript(
        color: AppColors.gold,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      );
}
