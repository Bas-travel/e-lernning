import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_switcher_sheet.dart';
import '../../../data/mock/current_user.dart';
import '../../../data/mock/mock_repository.dart';

/// Screen 36 — Corporate Dashboard.
class CorporateDashboardScreen extends StatelessWidget {
  const CorporateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corporate Dashboard'),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Row(
              children: [
                const Icon(Icons.apartment_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Signed in as ${CurrentUser.role.label}', style: AppTypography.caption),
              ],
            ),
          ),
          const KpiRow(stats: MockRepository.corporateKpis),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MenuTile(
                  icon: Icons.groups_outlined,
                  label: 'Employee Management',
                  onTap: () => context.push('/corporate/employees'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MenuTile(
                  icon: Icons.route_outlined,
                  label: 'Learning Paths',
                  onTap: () => context.push('/corporate/learning-paths'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Department Performance', style: AppTypography.h2),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Column(
              children: [
                _DeptRow(name: 'Engineering', progress: 0.72),
                _DeptRow(name: 'Sales', progress: 0.51),
                _DeptRow(name: 'Customer Success', progress: 0.64),
                _DeptRow(name: 'Design', progress: 0.83),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.btnOutlineBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
              onPressed: () => context.push('/corporate/learning-paths'),
              icon: const Icon(Icons.add),
              label: const Text('Create Learning Path'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DeptRow extends StatelessWidget {
  final String name;
  final double progress;

  const _DeptRow({required this.name, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTypography.body),
              Text('${(progress * 100).round()}%', style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
