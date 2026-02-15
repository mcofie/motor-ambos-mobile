import 'package:flutter/material.dart';

/// Custom theme data for MotorAmbos-specific tokens.
/// This sits on top of Material's ColorScheme.
class MotorAmbosTheme extends ThemeExtension<MotorAmbosTheme> {
  final Color accent; // brand accent (black)
  final Color success;
  final Color warning;
  final Color info;

  final Color softCardBackground;
  final Color slateText;
  final Color inputBg;
  final Color subtleBorder;

  const MotorAmbosTheme({
    required this.accent,
    required this.success,
    required this.warning,
    required this.info,
    required this.softCardBackground,
    required this.subtleBorder,
    required this.slateText,
    required this.inputBg,
  });

  factory MotorAmbosTheme.light() {
    return const MotorAmbosTheme(
      accent: Color(0xFF15803D), // brandGreen
      success: Color(0xFF16A34A),
      warning: Color(0xFFF59E0B),
      info: Color(0xFF3B82F6),
      softCardBackground: Color(0xFFF1F5F9), // slate100
      slateText: Color(0xFF475569), // slate600 - Good contrast for muted text
      inputBg: Color(0xFFF8FAFC), // slate50 - Very clean input bg
      subtleBorder: Color(0xFFE2E8F0), // slate200
    );
  }

  factory MotorAmbosTheme.dark(ColorScheme scheme) {
    return const MotorAmbosTheme(
      accent: Color(0xFF22C55E), // Slightly brighter for dark mode visibility but still robust green
      success: Color(0xFF4ADE80),
      warning: Color(0xFFFBBF24),
      info: Color(0xFF60A5FA),
      softCardBackground: Color(0xFF1E293B), // slate800
      slateText: Color(0xFFCBD5E1), // slate300
      inputBg: Color(0xFF0F172A), // slate900
      subtleBorder: Color(0xFF334155), // slate700
    );
  }

  @override
  MotorAmbosTheme copyWith({
    Color? accent,
    Color? success,
    Color? warning,
    Color? info,
    Color? softCardBackground,
    Color? subtleBorder,
    Color? slateText,
    Color? inputBg,
  }) {
    return MotorAmbosTheme(
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      softCardBackground: softCardBackground ?? this.softCardBackground,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      slateText: slateText ?? this.slateText,
      inputBg: inputBg ?? this.inputBg,
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
      slateText: Color.lerp(slateText, other.slateText, t) ?? slateText,
      inputBg: Color.lerp(inputBg, other.inputBg, t) ?? inputBg,
    );
  }
}

extension MotorAmbosThemeX on BuildContext {
  MotorAmbosTheme get motTheme =>
      Theme.of(this).extension<MotorAmbosTheme>()!;
}