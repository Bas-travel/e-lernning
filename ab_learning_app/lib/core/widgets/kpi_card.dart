import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Corresponds to `.kpi` in `02-hifi-mockups.html` — the small stat card
/// used across every dashboard screen (Instructor/Corp/Employer/Admin).
class KpiCard extends StatelessWidget {
  const KpiCard({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.h1.copyWith(fontSize: 22)),
        ],
      ),
    );
  }
}

/// A responsive row of [KpiCard]s that wraps instead of overflowing on
/// narrow widths — used by every dashboard screen's KPI row.
class KpiRow extends StatelessWidget {
  const KpiRow({required this.cards, super.key});
  final List<KpiCard> cards;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards.map((KpiCard c) => SizedBox(width: 160, child: c)).toList(),
    );
  }
}
