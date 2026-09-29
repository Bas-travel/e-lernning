import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_switcher_sheet.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

/// Screen 31 — Instructor Dashboard.
class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = MockRepository.courses.take(3).toList();

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
          const KpiRow(stats: MockRepository.instructorKpis),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: courses
                  .map((c) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(int.parse('FF${c.coverColorHex}', radix: 16)).withValues(alpha: 0.15),
                          child: Icon(Icons.menu_book_rounded, color: Color(int.parse('FF${c.coverColorHex}', radix: 16))),
                        ),
                        title: Text(c.title, style: AppTypography.body),
                        subtitle: Text(
                          '${c.students} students · ★ ${c.rating.toStringAsFixed(1)}',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => context.push('/instructor/courses'),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

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
            Text(label, style: AppTypography.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
