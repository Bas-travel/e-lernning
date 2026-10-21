import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4338CA);
  static const secondary = Color(0xFF7C3AED);
  static const accent = Color(0xFF0EA5E9);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const background = Color(0xFFF8FAFC);
  static const text = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  // Pill / alert backgrounds
  static const pillSuccessBg = Color(0xFFDCFCE7);
  static const pillWarnBg = Color(0xFFFEF3C7);
  static const pillErrorBg = Color(0xFFFEE2E2);
  // Button & card tokens
  static const btnPrimaryBg = Color(0xFF4338CA);
  static const btnOutlineBorder = Color(0xFF4338CA);
  static const cardBorder = Color(0xFFEEF0F4);

  // --- Additional values used by 02-hifi-mockups.html (not in design-tokens.json) ---
  /// Hairline borders for topbar, inputs, ghost buttons, bottom nav (#E2E8F0).
  static const border = Color(0xFFE2E8F0);
  /// Progress track / inactive dot (#E2E8F0).
  static const track = Color(0xFFE2E8F0);
  /// Neutral chip background (#F1F5F9).
  static const chipBg = Color(0xFFF1F5F9);
  /// Active sidebar item background and role badge (#EEF2FF).
  static const primaryTint = Color(0xFFEEF2FF);
  /// Second stop of the brand-tinted auth background (#F5F3FF).
  static const secondaryTint = Color(0xFFF5F3FF);
  /// Video player surface (#0F172A).
  static const playerSurface = Color(0xFF0F172A);
  /// Muted text on dark surfaces (#94A3B8).
  static const textOnDarkMuted = Color(0xFF94A3B8);
  /// Teal used as the end stop of "live" gradients (#0891B2).
  static const live = Color(0xFF0891B2);
  /// Orange used as the end stop of warning gradients (#F97316).
  static const orange = Color(0xFFF97316);

  // Pill foregrounds
  static const pillSuccessFg = Color(0xFF166534);
  static const pillWarnFg = Color(0xFF92400E);
  static const pillErrorFg = Color(0xFF991B1B);
  static const pillLiveBg = Color(0xFFCFFAFE);
  static const pillLiveFg = Color(0xFF0E7490);

  // Coin chip (#FEF3C7 / #92400E)
  static const coinBg = Color(0xFFFEF3C7);
  static const coinFg = Color(0xFF92400E);

  // White overlays used on gradient surfaces (pre-computed ARGB, no withOpacity).
  static const whiteA08 = Color(0x14FFFFFF);
  static const whiteA15 = Color(0x26FFFFFF);
  static const whiteA25 = Color(0x40FFFFFF);
  static const whiteA40 = Color(0x66FFFFFF);
  static const whiteA85 = Color(0xD9FFFFFF);
}

/// Gradients taken from the hi-fi mockup (`linear-gradient(135deg, ...)`).
class AppGradients {
  /// CSS 135deg ≈ top-left → bottom-right.
  static const _tl = Alignment.topLeft;
  static const _br = Alignment.bottomRight;

  static const brand = LinearGradient(
    begin: _tl,
    end: _br,
    colors: [AppColors.primary, AppColors.secondary],
  );
  static const brandAccent = LinearGradient(
    begin: _tl,
    end: _br,
    colors: [AppColors.primary, AppColors.accent],
  );
  static const accentPrimary = LinearGradient(
    begin: _tl,
    end: _br,
    colors: [AppColors.accent, AppColors.primary],
  );
  static const accentSecondary = LinearGradient(
    begin: _tl,
    end: _br,
    colors: [AppColors.accent, AppColors.secondary],
  );
  static const live = LinearGradient(
    begin: _tl,
    end: _br,
    colors: [AppColors.accent, AppColors.live],
  );
  static const warm = LinearGradient(
    begin: _tl,
    end: _br,
    colors: [AppColors.warning, AppColors.orange],
  );

  /// Splash: CSS `160deg` (mostly top → bottom, slightly rightwards).
  static const splash = LinearGradient(
    begin: Alignment(-0.342, -0.940),
    end: Alignment(0.342, 0.940),
    colors: [AppColors.primary, AppColors.secondary],
  );

  /// Desktop login background: `135deg, #EEF2FF → #F5F3FF`.
  static const authTint = LinearGradient(
    begin: _tl,
    end: _br,
    colors: [AppColors.primaryTint, AppColors.secondaryTint],
  );
}
