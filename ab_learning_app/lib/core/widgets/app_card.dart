import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';

/// `.card` from the mockup: white, 16px radius, 1px #EEF0F4 border, 14px padding.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.gradient,
    this.color = Colors.white,
    this.borderColor = AppColors.cardBorder,
    this.borderWidth = 1,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}
