import 'package:flutter/material.dart';

/// Central place for MotorAmbos brand colours.
///
/// Primary: #7CCF00 (bright green)
/// Accent: black
class AppColors {
  /// MotorAmbos primary – bright fresh green
  /// Hex: #7CCF00
  static const Color brandPrimary = Color(0xFF7CCF00);

  /// Accent / emphasis colour – black
  /// Good for strong text, icons, and contrast.
  static const Color brandAccent = Colors.black;

  /// Background for most screens (light mode).
  static const Color background = Color(0xFFF5F5F7);

  /// Soft surface colour for cards & tiles.
  static const Color surface = Colors.white;

  /// Error colour.
  static const Color error = Color(0xFFB00020);

  /// Status colours
  static const Color success = Color(0xFF1B873F); // deep green
  static const Color warning = Color(0xFFFFB300); // amber
  static const Color info = Color(0xFF0277BD);    // blue

  /// Neutral greys (tweak as you like)
  static const Color greySoft = Color(0xFFE0E0E0);
  static const Color greyMedium = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF424242);
}