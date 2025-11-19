import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Custom theme data for MotorAmbos-specific tokens.
/// This sits on top of Material's ColorScheme.
class MotorAmbosTheme extends ThemeExtension<MotorAmbosTheme> {
  final Color accent; // brand accent (black)
  final Color success;
  final Color warning;
  final Color info;

  final Color softCardBackground;
  final Color subtleBorder;

  const MotorAmbosTheme({
    required this.accent,
    required this.success,
    required this.warning,
    required this.info,
    required this.softCardBackground,
    required this.subtleBorder,
  });

  factory MotorAmbosTheme.light() => MotorAmbosTheme(
    accent: AppColors.brandAccent,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    softCardBackground: Colors.white,
    subtleBorder: AppColors.greySoft,
  );

  factory MotorAmbosTheme.dark(ColorScheme scheme) => MotorAmbosTheme(
    accent: Colors.white,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    softCardBackground: scheme.surfaceVariant,
    subtleBorder: scheme.outlineVariant,
  );

  @override
  MotorAmbosTheme copyWith({
    Color? accent,
    Color? success,
    Color? warning,
    Color? info,
    Color? softCardBackground,
    Color? subtleBorder,
  }) {
    return MotorAmbosTheme(
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      softCardBackground: softCardBackground ?? this.softCardBackground,
      subtleBorder: subtleBorder ?? this.subtleBorder,
    );
  }

  @override
  MotorAmbosTheme lerp(ThemeExtension<MotorAmbosTheme>? other, double t) {
    if (other is! MotorAmbosTheme) return this;
    return MotorAmbosTheme(
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      softCardBackground:
      Color.lerp(softCardBackground, other.softCardBackground, t) ??
          softCardBackground,
      subtleBorder:
      Color.lerp(subtleBorder, other.subtleBorder, t) ?? subtleBorder,
    );
  }
}

extension MotorAmbosThemeX on BuildContext {
  MotorAmbosTheme get motTheme =>
      Theme.of(this).extension<MotorAmbosTheme>()!;
}