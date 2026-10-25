import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// `.avatar`: primary circle with an initial.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initial,
    this.size = 30,
    this.fontSize = 12,
  });

  final String initial;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: AppTypography.base(
          fontSize,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
