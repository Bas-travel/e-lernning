import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/role_menus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_scaffold.dart';
import '../application/admin_controller.dart';
import '../models/admin_dashboard.dart';

/// Screen 40 — Admin Dashboard, plus an inline slice of screen 41's
/// moderation queue. ADMIN-only; not scoped to any single account.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AdminDashboard> dashboard = ref.watch(adminDashboardProvider);
    final AsyncValue<List<PendingCourse>> pending = ref.watch(pendingCoursesProvider);

    return RoleScaffold(
      role: AppRole.admin,
      activeRoute: '/admin',
      title: 'Admin Dashboard',
      child: AsyncStateView<AdminDashboard>(
        value: dashboard,
        onRetry: () => ref.invalidate(adminDashboardProvider),
        data: (context, d) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              KpiRow(cards: <KpiCard>[
                KpiCard(label: 'Total Users', value: '${d.totalUsers}'),
                KpiCard(label: 'Instructors', value: '${d.totalInstructors}'),
                KpiCard(label: 'Courses', value: '${d.totalCourses}'),
                KpiCard(label: 'Revenue', value: '฿${d.totalRevenue.toStringAsFixed(0)}'),
                KpiCard(label: 'Pending', value: '${d.pendingModeration}'),
              ]),
              const SizedBox(height: 24),
              const Text('Course Moderation Queue', style: AppTypography.h2),
              const SizedBox(height: 12),
              pending.when(
                loading: () => const SizedBox(
                  height: 72,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (Object e, StackTrace _) => const Text(
                  'โหลดคิวตรวจสอบไม่สำเร็จ',
                  style: AppTypography.caption,
                ),
                data: (List<PendingCourse> courses) {
                  if (courses.isEmpty) {
                    return const Text('ไม่มีคอร์สรอตรวจสอบในขณะนี้ ✓',
                        style: AppTypography.caption);
                  }
                  return Column(
                    children: courses
                        .map((PendingCourse c) => _PendingCourseRow(course: c))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingCourseRow extends ConsumerStatefulWidget {
  const _PendingCourseRow({required this.course});
  final PendingCourse course;

  @override
  ConsumerState<_PendingCourseRow> createState() => _PendingCourseRowState();
}

class _PendingCourseRowState extends ConsumerState<_PendingCourseRow> {
  bool _approving = false;

  Future<void> _approve() async {
    setState(() => _approving = true);
    try {
      await ref.read(adminActionsProvider).approveCourse(widget.course.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อนุมัติ "${widget.course.title}" แล้ว')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อนุมัติไม่สำเร็จ ลองอีกครั้ง'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _approving = false);
    }
    // Row disappears on its own next frame once pendingCoursesProvider
    // refetches (see AdminActions.approveCourse) — no manual removal here.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.course.title,
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                Text('${widget.course.instructorName} · ${widget.course.category}',
                    style: AppTypography.caption),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _approving ? null : () {},
            child: const Text('Preview'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _approving ? null : _approve,
            child: _approving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Approve'),
          ),
        ],
      ),
    );
  }
}
