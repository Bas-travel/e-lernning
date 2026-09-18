import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/role_menus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_scaffold.dart';
import '../application/employer_controller.dart';
import '../models/employer_dashboard.dart';

/// Screen 39 — Employer Dashboard. Reachable by EMPLOYER accounts only;
/// data is scoped to the `employers` row linked to that account.
class EmployerDashboardScreen extends ConsumerWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<EmployerDashboard> dashboard =
        ref.watch(employerDashboardProvider);
    final AsyncValue<List<TopApplicant>> applicants =
        ref.watch(topApplicantsProvider);

    return RoleScaffold(
      role: AppRole.employer,
      activeRoute: '/employer',
      title: 'Employer Dashboard',
      child: AsyncStateView<EmployerDashboard>(
        value: dashboard,
        onRetry: () => ref.invalidate(employerDashboardProvider),
        data: (context, d) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(d.companyName, style: AppTypography.h1),
              const SizedBox(height: 4),
              const Text('Talent Marketplace Overview', style: AppTypography.caption),
              const SizedBox(height: 16),
              KpiRow(cards: <KpiCard>[
                KpiCard(label: 'Open Jobs', value: '${d.openJobs}'),
                KpiCard(label: 'Applications', value: '${d.totalApplications}'),
                KpiCard(label: 'Shortlisted', value: '${d.shortlistedCount}'),
                KpiCard(label: 'Hired', value: '${d.hiredCount}'),
              ]),
              const SizedBox(height: 24),
              const Text('Recommended Talent', style: AppTypography.h2),
              const SizedBox(height: 12),
              applicants.when(
                loading: () => const SizedBox(
                  height: 72,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (Object e, StackTrace _) => const Text(
                  'โหลดรายชื่อผู้สมัครไม่สำเร็จ',
                  style: AppTypography.caption,
                ),
                data: (List<TopApplicant> list) {
                  if (list.isEmpty) {
                    return const Text('ยังไม่มีผู้สมัครในขณะนี้', style: AppTypography.caption);
                  }
                  return Column(
                    children: list
                        .map((TopApplicant a) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      a.name.isNotEmpty ? a.name[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(a.name,
                                            style: AppTypography.body
                                                .copyWith(fontWeight: FontWeight.w600)),
                                        Text('${a.headline} · ${a.jobTitle}',
                                            style: AppTypography.caption),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Match ${a.matchScore.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
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
