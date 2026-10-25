import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_switcher_sheet.dart';
import '../../../data/mock/models.dart';

/// Screen 40 — Admin Dashboard.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(adminDashboardProvider);
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
          dashboard.when(
            loading: () => const SizedBox(
                height: 92, child: Center(child: CircularProgressIndicator())),
            error: (error, _) => _DashboardError(
                message: error.toString(),
                onRetry: () => ref.invalidate(adminDashboardProvider)),
            data: (data) => KpiRow(stats: [
              KpiStat(label: 'Users', value: '${data['users_total'] ?? 0}'),
              KpiStat(
                  label: 'Instructors', value: '${data['instructors'] ?? 0}'),
              KpiStat(
                  label: 'Published courses',
                  value: '${data['courses_published'] ?? 0}'),
              KpiStat(
                  label: 'Pending courses',
                  value: '${data['courses_pending'] ?? 0}'),
              KpiStat(label: 'Revenue', value: '฿${data['revenue'] ?? 0}'),
              KpiStat(
                  label: 'Open reports', value: '${data['open_reports'] ?? 0}'),
            ]),
          ),
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
          dashboard.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _DashboardError(
                message: error.toString(),
                onRetry: () => ref.invalidate(adminDashboardProvider)),
            data: (data) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text('Gross merchandise value: ฿${data['gmv'] ?? 0}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Expanded(child: Text('โหลด Dashboard ไม่สำเร็จ: $message')),
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh))
      ]));
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile(
      {required this.icon, required this.label, required this.onTap});

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
            Expanded(
                child: Text(label,
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
