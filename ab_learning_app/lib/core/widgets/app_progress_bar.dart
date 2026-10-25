import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// `.progress-track` + `.progress-fill`. [value] is 0..1.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.trackColor = AppColors.track,
    this.color = AppColors.primary,
  });

  final double value;
  final double height;
  final Color trackColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return Semantics(
      value: '${(clamped * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Container(
          height: height,
          color: trackColor,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: clamped,
            child: Container(color: color),
          ),
        ),
      ),
    );
  }
}
