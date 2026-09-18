import 'package:flutter/widgets.dart';

/// Breakpoints from `00-blueprint-overview.md` §5.
class Breakpoints {
  Breakpoints._();

  static const double tablet = 768;
  static const double desktop = 1024;
}

/// True when the current layout should use the desktop (sidebar) shell
/// instead of the mobile (bottom nav) shell. Screens are written once and
/// composed into both — see `MobileHomeLayout` / `DesktopHomeLayout`.
bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

bool isTablet(BuildContext context) {
  final double width = MediaQuery.sizeOf(context).width;
  return width >= Breakpoints.tablet && width < Breakpoints.desktop;
}

/// Convenience widget: picks the right layout for the current width.
/// Usage:
/// ```dart
/// ResponsiveBuilder(
///   mobile: (ctx) => MobileHomeLayout(...),
///   desktop: (ctx) => DesktopHomeLayout(...),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    required this.desktop,
    super.key,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    return isDesktop(context) ? desktop(context) : mobile(context);
  }
}
