import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

/// `.kpi`: label + large value.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.base(11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.base(22, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
