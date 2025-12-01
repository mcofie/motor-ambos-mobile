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
      accent: Color(0xFF163300), // Forest Green (Primary)
      success: Color(0xFF22C55E),
      warning: Color(0xFFF59E0B),
      info: Color(0xFF3B82F6),
      softCardBackground: Color(0xFFF2F9ED), // Muted Light
      slateText: Color(0xFF5D7052), // Muted Foreground Light
      inputBg: Color(0xFFE2E8E0), // Border/Input Light
      subtleBorder: Color(0xFFE2E8E0), // Border Light
    );
  }

  factory MotorAmbosTheme.dark(ColorScheme scheme) {
    return const MotorAmbosTheme(
      accent: Color(0xFF9FE870), // Bright Lime (Primary)
      success: Color(0xFF4ADE80),
      warning: Color(0xFFFBBF24),
      info: Color(0xFF60A5FA),
      softCardBackground: Color(0xFF224505), // Muted Dark
      slateText: Color(0xFFA3C299), // Muted Foreground Dark
      inputBg: Color(0xFF2E5C0A), // Border/Input Dark
      subtleBorder: Color(0xFF2E5C0A), // Border Dark
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