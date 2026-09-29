import 'package:flutter/material.dart';
import '../../data/mock/models.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

/// Horizontal-scroll KPI card used on Instructor / Corporate / Employer /
/// Admin dashboards (screens 31, 36, 39, 40).
class KpiCard extends StatelessWidget {
  final KpiStat stat;

  const KpiCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.label,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(stat.value, style: AppTypography.h1.copyWith(fontSize: 20)),
          if (stat.deltaLabel != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  stat.deltaIsPositive ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: stat.deltaIsPositive ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 2),
                Text(
                  stat.deltaLabel!,
                  style: AppTypography.micro.copyWith(
                    color: stat.deltaIsPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontal-scroll row of [KpiCard]s.
class KpiRow extends StatelessWidget {
  final List<KpiStat> stats;

  const KpiRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: stats.map((s) => KpiCard(stat: s)).toList(),
      ),
    );
  }
}
