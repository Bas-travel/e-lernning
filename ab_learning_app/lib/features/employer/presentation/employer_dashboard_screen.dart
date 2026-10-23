import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_switcher_sheet.dart';
import '../../../data/mock/models.dart';
import '../application/employer_controller.dart';

/// Employer KPIs and recommended candidates are served by role-guarded APIs.
class EmployerDashboardScreen extends ConsumerWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(employerDashboardProvider);
    final talent = ref.watch(topApplicantsProvider);
    return Scaffold(
      appBar: AppBar(
        title: dashboard.maybeWhen(
            data: (value) => Text(value.companyName),
            orElse: () => const Text('Employer Dashboard')),
        actions: [
          IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Switch role',
              onPressed: () => showRoleSwitcherSheet(context))
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        dashboard.when(
          loading: () => const SizedBox(
              height: 92, child: Center(child: CircularProgressIndicator())),
          error: (error, _) => _LoadError(
              message: error.toString(),
              onRetry: () => ref.invalidate(employerDashboardProvider)),
          data: (data) => KpiRow(stats: [
            KpiStat(label: 'Open jobs', value: '${data.openJobs}'),
            KpiStat(label: 'Applications', value: '${data.totalApplications}'),
            KpiStat(label: 'Shortlisted', value: '${data.shortlistedCount}'),
            KpiStat(label: 'Hired', value: '${data.hiredCount}'),
          ]),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Recommended Talent', style: AppTypography.h2),
          TextButton(
              onPressed: () => context.push('/employer/talent'),
              child: const Text('View all')),
        ]),
        const SizedBox(height: 8),
        talent.when(
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator())),
          error: (error, _) => _LoadError(
              message: error.toString(),
              onRetry: () => ref.invalidate(topApplicantsProvider)),
          data: (people) => people.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('ยังไม่มีผู้สมัครที่แนะนำ'))
              : Column(
                  children: people
                      .take(3)
                      .map((person) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.card),
                                border:
                                    Border.all(color: AppColors.cardBorder)),
                            child: Row(children: [
                              CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.15),
                                  child: const Icon(Icons.person,
                                      color: AppColors.primary)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(person.name,
                                        style: AppTypography.body.copyWith(
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        '${person.headline} · ${person.jobTitle}',
                                        style: AppTypography.caption.copyWith(
                                            color: AppColors.textSecondary)),
                                  ])),
                              Text('${person.matchScore.round()}%',
                                  style: AppTypography.body.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700)),
                            ]),
                          ))
                      .toList()),
        ),
      ]),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text('โหลดข้อมูลไม่สำเร็จ: $message')),
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh))
      ]);
}
