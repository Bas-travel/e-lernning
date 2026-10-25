import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Rounded-square logo block used on splash and login (as drawn in the mockup).
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    required this.size,
    required this.radius,
    this.color = AppColors.primary,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  final double size;
  final double radius;
  final Color color;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
    );
  }
}
