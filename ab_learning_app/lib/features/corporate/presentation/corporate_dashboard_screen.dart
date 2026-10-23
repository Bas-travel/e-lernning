import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_switcher_sheet.dart';
import '../../../data/mock/current_user.dart';
import '../../../data/mock/models.dart';

/// Screen 36 — Corporate Dashboard.
class CorporateDashboardScreen extends ConsumerWidget {
  const CorporateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(corporateDashboardProvider);
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
                const Icon(Icons.apartment_outlined,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Signed in as ${CurrentUser.role.label}',
                    style: AppTypography.caption),
              ],
            ),
          ),
          dashboard.when(
            loading: () => const SizedBox(
                height: 92, child: Center(child: CircularProgressIndicator())),
            error: (error, _) => _DashboardError(
                message: error.toString(),
                onRetry: () => ref.invalidate(corporateDashboardProvider)),
            data: (data) => KpiRow(
                stats: (data['kpis'] as List<dynamic>? ?? const []).map((item) {
              final kpi = item as Map<String, dynamic>;
              return KpiStat(
                  label: '${kpi['label'] ?? ''}',
                  value: '${kpi['value'] ?? ''}');
            }).toList()),
          ),
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
          dashboard.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _DashboardError(
                message: error.toString(),
                onRetry: () => ref.invalidate(corporateDashboardProvider)),
            data: (data) {
              final departments =
                  (data['departments'] as List<dynamic>? ?? const [])
                      .cast<Map<String, dynamic>>();
              if (departments.isEmpty) return const Text('ยังไม่มีข้อมูลแผนก');
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.cardBorder)),
                child: Column(children: [
                  for (final department in departments)
                    _DeptRow(
                        name: '${department['department'] ?? 'Unassigned'}',
                        progress: ((department['avg_progress'] as num? ?? 0)
                                    .toDouble() /
                                100)
                            .clamp(0.0, 1.0))
                ]),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.btnOutlineBorder),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button)),
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

  const _MenuTile(
      {required this.icon, required this.label, required this.onTap});

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
            Text(label,
                style:
                    AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
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
              Text('${(progress * 100).round()}%',
                  style: AppTypography.caption),
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

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text('โหลด Dashboard ไม่สำเร็จ: $message')),
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh))
      ]);
}
