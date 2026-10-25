import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

enum StatusPillVariant { success, warn, error, live }

/// `.pill` variants from the mockup.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.variant = StatusPillVariant.success,
  });

  final String label;
  final StatusPillVariant variant;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (variant) {
      case StatusPillVariant.success:
        bg = AppColors.pillSuccessBg;
        fg = AppColors.pillSuccessFg;
        break;
      case StatusPillVariant.warn:
        bg = AppColors.pillWarnBg;
        fg = AppColors.pillWarnFg;
        break;
      case StatusPillVariant.error:
        bg = AppColors.pillErrorBg;
        fg = AppColors.pillErrorFg;
        break;
      case StatusPillVariant.live:
        bg = AppColors.pillLiveBg;
        fg = AppColors.pillLiveFg;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Text(
        label,
        style: AppTypography.base(
          10.5,
          weight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }
}
