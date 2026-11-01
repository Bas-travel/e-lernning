import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

/// `.ccard`: gradient thumbnail (96px) + title + optional extra + meta row.
class GradientCourseCard extends StatelessWidget {
  const GradientCourseCard({
    super.key,
    required this.title,
    required this.meta,
    this.gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, AppColors.secondary],
    ),
    this.width,
    this.extra,
    this.onTap,
  });

  final String title;

  /// Bottom row (e.g. rating + price, or progress label + CTA).
  final Widget meta;
  final Gradient gradient;
  final double? width;

  /// Optional widget between the title and meta (e.g. a progress bar).
  final Widget? extra;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(gradient: gradient),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.base(
                    12.5,
                    weight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                if (extra != null) ...[extra!, const SizedBox(height: 6)],
                DefaultTextStyle(
                  style: AppTypography.base(
                    11,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                  child: meta,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}
