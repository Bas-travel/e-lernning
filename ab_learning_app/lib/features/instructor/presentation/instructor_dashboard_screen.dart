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

/// Screen 31 — Instructor Dashboard.
class InstructorDashboardScreen extends ConsumerWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(instructorDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
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
                onRetry: () => ref.invalidate(instructorDashboardProvider)),
            data: (data) => KpiRow(stats: [
              KpiStat(
                  label: 'Revenue', value: '฿${data['revenue_total'] ?? 0}'),
              KpiStat(
                  label: 'Students', value: '${data['students_total'] ?? 0}'),
              KpiStat(label: 'Courses', value: '${data['courses_total'] ?? 0}'),
              KpiStat(
                  label: 'Rating',
                  value:
                      '${(data['rating_avg'] as num? ?? 0).toStringAsFixed(1)} ★'),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Quick Actions', style: AppTypography.h2),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'Create Course',
                  onTap: () => context.push('/instructor/create-course'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.podcasts_outlined,
                  label: 'Go Live',
                  onTap: () => context.push('/instructor/go-live'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.payments_outlined,
                  label: 'Revenue',
                  onTap: () => context.push('/instructor/revenue'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Course Performance', style: AppTypography.h2),
              TextButton(
                onPressed: () => context.push('/instructor/courses'),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          dashboard.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _DashboardError(
                message: error.toString(),
                onRetry: () => ref.invalidate(instructorDashboardProvider)),
            data: (data) {
              final courses =
                  (data['top_courses'] as List<dynamic>? ?? const [])
                      .cast<Map<String, dynamic>>();
              if (courses.isEmpty) {
                return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('ยังไม่มีคอร์สที่เผยแพร่')));
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: courses
                      .map((c) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.12),
                              child: const Icon(Icons.menu_book_rounded,
                                  color: AppColors.primary),
                            ),
                            title: Text('${c['title'] ?? ''}',
                                style: AppTypography.body),
                            subtitle: Text(
                              '${c['student_count'] ?? 0} students · ★ ${(c['rating_avg'] as num? ?? 0).toStringAsFixed(1)}',
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            trailing: const Icon(Icons.chevron_right, size: 18),
                            onTap: () => context.push('/instructor/courses'),
                          ))
                      .toList(),
                ),
              );
            },
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
        const Icon(Icons.cloud_off_outlined),
        const SizedBox(width: 8),
        Expanded(child: Text('Dashboard unavailable: $message')),
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh))
      ]));
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label,
                style: AppTypography.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
