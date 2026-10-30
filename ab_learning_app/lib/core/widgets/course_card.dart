import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Corresponds to `Card/Course` in the Figma component library.
/// Used on Home (08), Explore (09), Search (10), and Career Path (24).
class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.title,
    required this.width,
    this.instructorName,
    this.ratingAvg,
    this.price,
    this.progressPct,
    this.gradient = AppColors.primaryGradient,
    this.onTap,
    super.key,
  });

  final String title;
  final double width;
  final String? instructorName;
  final double? ratingAvg;
  final double? price;
  final double? progressPct;
  final Gradient gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 96,
                  decoration: BoxDecoration(gradient: gradient),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (progressPct != null) ...<Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.badge),
                          child: LinearProgressIndicator(
                            value: progressPct! / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progressPct!.toStringAsFixed(0)}% เสร็จแล้ว',
                          style: AppTypography.micro,
                        ),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            if (ratingAvg != null)
                              Text('$ratingAvg ★', style: AppTypography.micro),
                            if (price != null)
                              Text(
                                '฿${price!.toStringAsFixed(0)}',
                                style: AppTypography.micro.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
