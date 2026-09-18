import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design tokens — type scale, matching `00-blueprint-overview.md` §2.
///
/// Font family defaults to the system font until the real Inter / Noto Sans
/// Thai font files are dropped into `assets/fonts` and declared in
/// `pubspec.yaml` (see the commented-out `fonts:` block there).
class AppTypography {
  AppTypography._();

  static const String fontFamilyEn = 'Inter';
  static const String fontFamilyTh = 'NotoSansThai';

  static const TextStyle display = TextStyle(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle micro = TextStyle(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Reserved bold weight — prices and score numbers only (per style guide).
  static const TextStyle emphasis = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}
