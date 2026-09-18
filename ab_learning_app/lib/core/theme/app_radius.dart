/// Design tokens — border radius, matching `00-blueprint-overview.md` §2.
class AppRadius {
  AppRadius._();

  static const double card = 16;
  static const double button = 12;
  static const double input = 10;
  static const double modal = 20;
  static const double badge = 999;
}

/// A single 4px-based spacing scale keeps every screen's paddings/margins
/// consistent instead of ad-hoc pixel values.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}
