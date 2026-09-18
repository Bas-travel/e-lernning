import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Corresponds to `Card/Live` in the Figma component library.
/// Used on Home (08) and Live List (17).
class LiveCard extends StatelessWidget {
  const LiveCard({
    required this.title,
    required this.instructorName,
    required this.width,
    this.isLiveNow = false,
    this.startsInLabel,
    this.onTap,
    super.key,
  });

  final String title;
  final String instructorName;
  final double width;
  final bool isLiveNow;
  final String? startsInLabel;
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
                Stack(
                  children: <Widget>[
                    Container(
                      height: 96,
                      decoration:
                          const BoxDecoration(gradient: AppColors.accentGradient),
                    ),
                    if (isLiveNow)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: Pill(label: '● LIVE', variant: PillVariant.live),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$instructorName${startsInLabel != null ? ' · $startsInLabel' : ''}',
                          style: AppTypography.micro),
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

enum PillVariant { success, warning, error, live, neutral }

/// Corresponds to `Badge` in the Figma component library — small status
/// pills used across cards, tables, and detail headers.
class Pill extends StatelessWidget {
  const Pill({required this.label, this.variant = PillVariant.neutral, super.key});

  final String label;
  final PillVariant variant;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (variant) {
      PillVariant.success => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
      PillVariant.warning => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      PillVariant.error => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
      PillVariant.live => (const Color(0xFFCFFAFE), const Color(0xFF0E7490)),
      PillVariant.neutral => (AppColors.border, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
