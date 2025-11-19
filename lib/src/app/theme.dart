import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'motorambos_theme_extension.dart';

class AppTheme {
  /// Light theme – primary green (#7CCF00), clean surfaces, subtle borders.
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandPrimary,
        brightness: Brightness.light,
      ),
    );

    final colorScheme = base.colorScheme.copyWith(
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,

      // Custom brand extension
      extensions: <ThemeExtension<dynamic>>[
        MotorAmbosTheme.light(),
      ],

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: colorScheme.onBackground,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.surface,
        indicatorColor: colorScheme.primary.withOpacity(0.16),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final isSelected = states.contains(MaterialState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: colorScheme.outlineVariant,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: _outlineInputBorder(colorScheme, 1),
        enabledBorder: _outlineInputBorder(colorScheme, 1),
        focusedBorder: _outlineInputBorder(
          colorScheme,
          1.4,
          colorScheme.primary,
        ),
        errorBorder: _outlineInputBorder(
          colorScheme,
          1.2,
          colorScheme.error,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: textTheme.labelSmall,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Dark theme – same structure, tuned for dark surfaces.
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandPrimary,
        brightness: Brightness.dark,
      ),
    );

    final colorScheme = base.colorScheme.copyWith(
      error: AppColors.error,
    );

    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,

      extensions: <ThemeExtension<dynamic>>[
        MotorAmbosTheme.dark(colorScheme),
      ],

      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withOpacity(0.20),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  /// Shared typography (light + dark) using Inter.
  static TextTheme _buildTextTheme(TextTheme base) {
    final font = GoogleFonts.manrope;

    return TextTheme(
      displayLarge: font(textStyle: base.displayLarge)?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      displayMedium: font(textStyle: base.displayMedium),
      displaySmall: font(textStyle: base.displaySmall),
      headlineLarge: font(textStyle: base.headlineLarge),
      headlineMedium: font(textStyle: base.headlineMedium),
      headlineSmall: font(textStyle: base.headlineSmall),
      titleLarge: font(textStyle: base.titleLarge)?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: font(textStyle: base.titleMedium)?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: font(textStyle: base.titleSmall)?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: font(textStyle: base.bodyLarge),
      bodyMedium: font(textStyle: base.bodyMedium),
      bodySmall: font(textStyle: base.bodySmall),
      labelLarge: font(textStyle: base.labelLarge)?.copyWith(
        letterSpacing: 0.1,
      ),
      labelMedium: font(textStyle: base.labelMedium)?.copyWith(
        letterSpacing: 0.1,
      ),
      labelSmall: font(textStyle: base.labelSmall)?.copyWith(
        letterSpacing: 0.1,
      ),
    );
  }

  static OutlineInputBorder _outlineInputBorder(
      ColorScheme colorScheme,
      double width, [
        Color? color,
      ]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        width: width,
        color: color ?? colorScheme.outlineVariant.withOpacity(0.7),
      ),
    );
  }
}