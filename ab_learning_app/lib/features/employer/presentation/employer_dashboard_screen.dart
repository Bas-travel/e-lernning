import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_switcher_sheet.dart';
import '../../../data/mock/mock_repository.dart';

/// Screen 39 — Employer Dashboard.
class EmployerDashboardScreen extends StatelessWidget {
  const EmployerDashboardScreen({super.key});

  static const _talent = [
    _Talent('Napat S.', 'Frontend Engineer', '4.9'),
    _Talent('Kanya P.', 'Data Analyst', '4.7'),
    _Talent('Wichai T.', 'UX Designer', '4.8'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch role',
            onPressed: () => showRoleSwitcherSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const KpiRow(stats: MockRepository.employerKpis),
          const SizedBox(height: 20),
          const Text('Recommended Talent', style: AppTypography.h2),
          const SizedBox(height: 12),
          ..._talent.map(
            (t) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.15), child: const Icon(Icons.person, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                        Text(t.role, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(t.rating, style: AppTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Skill Trends', style: AppTypography.h2),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Full charts arrive with Phase 3 backend wiring.', style: AppTypography.caption),
                SizedBox(height: 8),
                _TrendBar(label: 'Cloud / DevOps', percent: 0.82),
                _TrendBar(label: 'Data Analysis', percent: 0.68),
                _TrendBar(label: 'UI/UX Design', percent: 0.55),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Talent {
  final String name;
  final String role;
  final String rating;

  const _Talent(this.name, this.role, this.rating);
}

class _TrendBar extends StatelessWidget {
  final String label;
  final double percent;

  const _TrendBar({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
