import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/role_menus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_scaffold.dart';
import '../application/instructor_controller.dart';
import '../models/instructor_dashboard.dart';

/// Screen 31 — Instructor Dashboard. Only reachable by an INSTRUCTOR
/// account (see `app_router.dart`'s guard) and the data itself is scoped
/// server-side to that instructor's own courses — there is no client-side
/// filtering happening here, the backend simply never returns anyone
/// else's numbers.
class InstructorDashboardScreen extends ConsumerWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<InstructorDashboard> dashboard =
        ref.watch(instructorDashboardProvider);

    return RoleScaffold(
      role: AppRole.instructor,
      activeRoute: '/instructor',
      title: 'Instructor Dashboard',
      child: AsyncStateView<InstructorDashboard>(
        value: dashboard,
        onRetry: () => ref.invalidate(instructorDashboardProvider),
        data: (context, d) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              KpiRow(cards: <KpiCard>[
                KpiCard(label: 'Courses', value: '${d.courseCount}'),
                KpiCard(label: 'Total Students', value: _formatCount(d.totalStudents)),
                KpiCard(label: 'Avg. Rating', value: d.avgRating.toStringAsFixed(1)),
              ]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('สร้างคอร์สใหม่ — เร็วๆ นี้ (screen 33)'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
