import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Your Brand Colors
class AppColors {
  static const Color brandPrimary = Color(0xFF00E676); // Neon Green
  static const Color brandAccent = Color(0xFF1A1A1A);  // Deep Black
  static const Color error = Color(0xFFBA1A1A);
}

// Optional: Theme Extensions if you have custom semantic colors
class MotorAmbosTheme extends ThemeExtension<MotorAmbosTheme> {
  final Color? success;
  final Color? warning;

  const MotorAmbosTheme({this.success, this.warning});

  @override
  MotorAmbosTheme copyWith({Color? success, Color? warning}) {
    return MotorAmbosTheme(
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  MotorAmbosTheme lerp(ThemeExtension<MotorAmbosTheme>? other, double t) {
    if (other is! MotorAmbosTheme) return this;
    return MotorAmbosTheme(
      success: Color.lerp(success, other.success, t),
      warning: Color.lerp(warning, other.warning, t),
    );
  }

  static MotorAmbosTheme light = const MotorAmbosTheme(
    success: Color(0xFF006C4C),
    warning: Color(0xFF6C4F00),
  );

  static MotorAmbosTheme dark = const MotorAmbosTheme(
    success: Color(0xFF00E676),
    warning: Color(0xFFFFCC80),
  );
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
      primary: AppColors.brandPrimary,
      onPrimary: Colors.black, // High contrast on neon green
      primaryContainer: Color(0xFFD1FFDC),
      onPrimaryContainer: Color(0xFF00210E),

      secondary: AppColors.brandAccent,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE0E0E0),
      onSecondaryContainer: Color(0xFF1A1A1A),

      surface: Colors.white,
      onSurface: Color(0xFF1A1A1A),
      surfaceContainer: Color(0xFFF5F5F5), // Light gray background

      error: AppColors.error,
      onError: Colors.white,

      outline: Color(0xFF757575),
      outlineVariant: Color(0xFFC2C8BC),
    );

    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      extension: MotorAmbosTheme.light,
    );
  }

  // --- DARK THEME ---
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.brandPrimary,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF005324),
      onPrimaryContainer: Color(0xFFD1FFDC),

      secondary: Colors.white,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF424242),
      onSecondaryContainer: Colors.white,

      surface: Color(0xFF121212), // Deep dark
      onSurface: Color(0xFFE2E2E2),
      surfaceContainer: Color(0xFF1E1E1E), // Slightly lighter panel color

      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),

      outline: Color(0xFF8E918F),
      outlineVariant: Color(0xFF444746),
    );

    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      extension: MotorAmbosTheme.dark,
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
        scrolledUnderElevation: 0, // Keeps it flat when scrolling
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: _buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          // Ensure text on primary button is readable (Black on Green)
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
        color: colorScheme.surfaceContainer, // <--- CORRECT FIX
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
            ? const Color(0xFFF3F4F6)
            : const Color(0xFF1E1E1E),
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
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
      ),

      // Misc
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.5),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.brandAccent,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}