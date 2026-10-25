import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

/// `.chip` / `.chip.active` from the mockup.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.chipBg,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Text(
        label,
        softWrap: false,
        style: AppTypography.base(
          12,
          color: active ? Colors.white : AppColors.textSecondary,
          height: 1.2,
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      selected: active,
      child: onTap == null
          ? chip
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: chip,
            ),
    );
  }
}
