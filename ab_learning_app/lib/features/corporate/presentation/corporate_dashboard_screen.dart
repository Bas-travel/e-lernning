import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/role_menus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/role_scaffold.dart';
import '../application/corporate_controller.dart';
import '../models/corporate_dashboard.dart';

/// Screen 36 — Corporate Dashboard. Reachable by CORP_ADMIN or
/// CORP_MANAGER; data is scoped to whichever single organization that
/// account is linked to (an account linked to zero organizations gets a
/// clear error state below, not a crash or empty zeros).
class CorporateDashboardScreen extends ConsumerWidget {
  const CorporateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CorporateDashboard> dashboard =
        ref.watch(corporateDashboardProvider);

    return RoleScaffold(
      role: AppRole.corpAdmin,
      activeRoute: '/corporate',
      title: 'Corporate Dashboard',
      child: AsyncStateView<CorporateDashboard>(
        value: dashboard,
        onRetry: () => ref.invalidate(corporateDashboardProvider),
        data: (context, d) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(d.organizationName, style: AppTypography.h1),
              const SizedBox(height: 4),
              const Text('Corporate Learning Overview', style: AppTypography.caption),
              const SizedBox(height: 16),
              KpiRow(cards: <KpiCard>[
                KpiCard(label: 'Employees', value: '${d.employeeCount}'),
                KpiCard(label: 'Registered', value: '${d.registeredEmployees}'),
                KpiCard(label: 'Active Learners', value: '${d.activeLearners}'),
                KpiCard(
                  label: 'Completion Rate',
                  value: '${d.completionRatePct.toStringAsFixed(0)}%',
                ),
                KpiCard(
                  label: 'Training Budget',
                  value: '฿${_formatMoney(d.trainingBudget)}',
                ),
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
                    const Icon(Icons.route_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('สร้าง Learning Path — เร็วๆ นี้ (screen 38)'),
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

  String _formatMoney(double v) {
    final String s = v.toStringAsFixed(0);
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
