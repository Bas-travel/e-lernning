import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_card.dart';
import '../data/course_catalog_sample.dart';

/// Horizontal list card used by Explore ("คอร์สทั้งหมด") and Search results.
class CourseListTile extends StatelessWidget {
  const CourseListTile({
    super.key,
    required this.course,
    this.thumbWidth = 80,
    this.thumbHeight = 56,
    this.thumbRadius = 10,
    this.onTap,
  });

  final CatalogCourse course;
  final double thumbWidth;
  final double thumbHeight;
  final double thumbRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: thumbWidth,
            height: thumbHeight,
            decoration: BoxDecoration(
              gradient: course.gradient,
              borderRadius: BorderRadius.circular(thumbRadius),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: AppTypography.base(
                    12.5,
                    weight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                Text(
                  '${course.rating} · ${course.price}',
                  style: AppTypography.base(
                    11,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
