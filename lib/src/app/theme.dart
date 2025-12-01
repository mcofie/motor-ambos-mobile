import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'motorambos_theme_extension.dart';

// Your Brand Colors
class AppColors {
  static const Color forestGreen = Color(0xFF163300);
  static const Color brightLime = Color(0xFF9FE870);
  static const Color white = Color(0xFFFFFFFF);
  
  static const Color cardDark = Color(0xFF1A3B00);
  
  static const Color borderLight = Color(0xFFE2E8E0);
  static const Color borderDark = Color(0xFF2E5C0A);
  
  static const Color mutedLight = Color(0xFFF2F9ED);
  static const Color mutedDark = Color(0xFF224505);

  static const Color error = Color(0xFFDC2626); // Standard Red
}

class AppTheme {
  // 1. Text Theme: Manrope is great, keep it.
  static TextTheme _buildTextTheme(TextTheme base) {
    final font = GoogleFonts.inter;
    return fontTextTheme(base, font);
  }

  // Helper to apply font to all styles
  static TextTheme fontTextTheme(TextTheme base, Function font) {
    return TextTheme(
      displayLarge: font(textStyle: base.displayLarge, fontWeight: FontWeight.w800),
      displayMedium: font(textStyle: base.displayMedium, fontWeight: FontWeight.w800),
      displaySmall: font(textStyle: base.displaySmall, fontWeight: FontWeight.w700),
      headlineLarge: font(textStyle: base.headlineLarge, fontWeight: FontWeight.w700),
      headlineMedium: font(textStyle: base.headlineMedium, fontWeight: FontWeight.w700),
      headlineSmall: font(textStyle: base.headlineSmall, fontWeight: FontWeight.w700),
      titleLarge: font(textStyle: base.titleLarge, fontWeight: FontWeight.w700),
      titleMedium: font(textStyle: base.titleMedium, fontWeight: FontWeight.w600),
      titleSmall: font(textStyle: base.titleSmall, fontWeight: FontWeight.w600),
      bodyLarge: font(textStyle: base.bodyLarge, fontWeight: FontWeight.w400),
      bodyMedium: font(textStyle: base.bodyMedium, fontWeight: FontWeight.w400),
      bodySmall: font(textStyle: base.bodySmall, fontWeight: FontWeight.w400),
      labelLarge: font(textStyle: base.labelLarge, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelMedium: font(textStyle: base.labelMedium, fontWeight: FontWeight.w600),
      labelSmall: font(textStyle: base.labelSmall, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    );
  }

  // 2. Component Shapes
  static final _roundedShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
  static final _buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

  // --- LIGHT THEME ---
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.forestGreen,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.mutedLight,
      onPrimaryContainer: AppColors.forestGreen,

      secondary: AppColors.brightLime,
      onSecondary: AppColors.forestGreen,
      secondaryContainer: AppColors.borderLight,
      onSecondaryContainer: AppColors.forestGreen,

      surface: AppColors.white,
      onSurface: AppColors.forestGreen,
      surfaceContainer: AppColors.white, // Cards are white in light mode

      error: AppColors.error,
      onError: Colors.white,

      outline: AppColors.borderLight,
      outlineVariant: AppColors.borderLight,
    );

    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      extension: MotorAmbosTheme.light(),
    );
  }

  // --- DARK THEME ---
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.brightLime,
      onPrimary: AppColors.forestGreen,
      primaryContainer: AppColors.mutedDark,
      onPrimaryContainer: AppColors.brightLime,

      secondary: AppColors.white,
      onSecondary: AppColors.forestGreen,
      secondaryContainer: AppColors.cardDark,
      onSecondaryContainer: AppColors.white,

      surface: AppColors.forestGreen,
      onSurface: AppColors.white,
      surfaceContainer: AppColors.cardDark,

      error: AppColors.error,
      onError: Colors.white,

      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderDark,
    );

    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      extension: MotorAmbosTheme.dark(colorScheme),
    );
  }

  // --- SHARED BUILDER ---
  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required MotorAmbosTheme extension,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      extensions: [extension],

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: _buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: _buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: colorScheme.outline),
          foregroundColor: colorScheme.onSurface,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: _buttonShape,
        ),
      ),

      // Cards & Sheets
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: _roundedShape,
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? AppColors.borderLight
            : AppColors.borderDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
      ),

      // Misc
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.5),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: TextStyle(color: colorScheme.surface),
      ),
    );
  }
}