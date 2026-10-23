import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// 18px checkbox with a tappable label (the mockup's `<label><input checkbox>`).
class AppCheckRow extends StatelessWidget {
  const AppCheckRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.fontSize = 11.5,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTypography.base(
                fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
