import 'package:flutter/material.dart';

/// Typography tokens (design-tokens.json → type.scale).
///
/// Font families: Inter (Latin) with Noto Sans Thai fallback. The font files are
/// not bundled yet, so the platform falls back to its system font until the
/// files are added under `assets/fonts/` and declared in pubspec.yaml.
class AppTypography {
  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = ['Noto Sans Thai'];

  static const display = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w500,
  );
  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w500,
  );
  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w500,
  );
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
  );
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );
  static const micro = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w400,
  );

  /// Base for mockup-specific sizes (12.5px, 13px, 14px, 17px ...). The mockup
  /// uses sizes between the token steps, so screens call
  /// `AppTypography.base(size, weight)` instead of inventing raw TextStyles.
  static TextStyle base(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = const Color(0xFF0F172A),
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
