import 'package:flutter/material.dart';

/// Design tokens — colors.
///
/// These values are the single source of truth for color across the app.
/// They mirror `00-blueprint-overview.md` §2 exactly — do not hardcode a
/// hex value anywhere else in the codebase; import this file instead.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF7C3AED);
  static const Color accent = Color(0xFF06B6D4);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // Convenience gradients used on hero cards / thumbnails across the app.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFF0891B2)],
  );
}
