import 'package:flutter/widgets.dart';

/// Layout breakpoints. The mockup defines Mobile (375) and Desktop (1280-1440);
/// widths from 768 up to 1023 reuse the mobile layout inside a centred column.
class Breakpoints {
  static const double tablet = 768;
  static const double desktop = 1024;

  /// Max width of a single-column mobile layout when shown on a wide screen.
  static const double mobileContentMax = 560;
}

/// Chooses between a mobile and a desktop builder using the available width.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth >= Breakpoints.desktop
            ? desktop(context)
            : mobile(context);
      },
    );
  }
}

/// Centres [child] and caps its width (used for the mobile layout on tablets).
class CenteredContent extends StatelessWidget {
  const CenteredContent({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.mobileContentMax,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Equal-width column grid (replaces CSS `grid-template-columns: repeat(n, 1fr)`).
class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.columns,
    required this.children,
    this.spacing = 14,
  });

  final int columns;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}
