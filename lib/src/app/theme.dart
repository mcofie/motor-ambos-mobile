import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'motorambos_theme_extension.dart';

// Your Brand Colors
class AppColors {
  static const Color forestGreen = Color(0xFF163300);
  static const Color brandGreen = Color(0xFF15803D); // Primary Brand Color
  static const Color white = Color(0xFFFFFFFF);
  
  // Modern Slate Palette (Light -> Dark)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8); // Muted Text
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B); // Dark Cards
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617); // Dark Background

  static const Color error = Color(0xFFEF4444); // Modern Red
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
  // 2. Component Shapes
  static final _roundedShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)); // Modern 16px radius
  static final _buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  // --- LIGHT THEME ---
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.brandGreen,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.slate100, // Subtle green/slate mix could be better, but sticking to slate for clean look
      onPrimaryContainer: AppColors.brandGreen,

      secondary: AppColors.forestGreen,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.slate200,
      onSecondaryContainer: AppColors.forestGreen,

      surface: AppColors.white,
      onSurface: AppColors.slate900,
      surfaceContainer: AppColors.white,

      error: AppColors.error,
      onError: Colors.white,

      outline: AppColors.slate200,
      outlineVariant: AppColors.slate300,
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
      primary: AppColors.brandGreen,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.slate800,
      onPrimaryContainer: AppColors.brandGreen,

      secondary: AppColors.white,
      onSecondary: AppColors.forestGreen,
      secondaryContainer: AppColors.slate800,
      onSecondaryContainer: AppColors.white,

      surface: AppColors.slate950,
      onSurface: AppColors.slate50,
      surfaceContainer: AppColors.slate900,

      error: AppColors.error,
      onError: Colors.white,

      outline: AppColors.slate700,
      outlineVariant: AppColors.slate600,
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
      scaffoldBackgroundColor: brightness == Brightness.light ? AppColors.slate50 : AppColors.slate950,
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
          side: BorderSide(color: colorScheme.outlineVariant),
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
        shape: _roundedShape.copyWith(side: BorderSide(color: colorScheme.outline, width: 1)),
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
            ? AppColors.white
            : AppColors.slate900,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.85)),
        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.65)),
      ),

      // Misc
      iconTheme: IconThemeData(color: colorScheme.onSurface, opacity: 0.9),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1.2,
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