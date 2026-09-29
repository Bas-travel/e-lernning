import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_switcher_sheet.dart';
import '../../../data/mock/mock_repository.dart';

/// Screen 40 — Admin Dashboard.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
          const KpiRow(stats: MockRepository.adminKpis),
          const SizedBox(height: 24),
          const Text('Quick Menu', style: AppTypography.h2),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _MenuTile(
                icon: Icons.people_alt_outlined,
                label: 'User Management',
                onTap: () => context.push('/admin/users'),
              ),
              _MenuTile(
                icon: Icons.fact_check_outlined,
                label: 'Course Moderation',
                onTap: () => context.push('/admin/moderation'),
              ),
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                label: 'Payments',
                onTap: () => context.push('/admin/payments'),
              ),
              _MenuTile(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => context.push('/admin/settings'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Platform Growth', style: AppTypography.h2),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              'Revenue, user growth, and course sales charts arrive once '
              '/admin/dashboard is wired to the real API in Phase 3.',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
