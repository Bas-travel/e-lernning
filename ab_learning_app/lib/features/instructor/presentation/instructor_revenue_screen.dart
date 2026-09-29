import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../data/mock/models.dart';

/// Screen 35 — Instructor Revenue.
class InstructorRevenueScreen extends StatelessWidget {
  const InstructorRevenueScreen({super.key});

  static const _kpis = [
    KpiStat(label: 'Gross', value: '฿96,400'),
    KpiStat(label: 'Platform Fee', value: '฿9,640', deltaIsPositive: false),
    KpiStat(label: 'Net', value: '฿86,760'),
    KpiStat(label: 'Pending', value: '฿12,300'),
    KpiStat(label: 'Paid Out', value: '฿74,460'),
  ];

  static const _payouts = [
    _Payout('Aug 2026', '฿18,200', 'Paid'),
    _Payout('Jul 2026', '฿15,900', 'Paid'),
    _Payout('Jun 2026', '฿14,100', 'Paid'),
    _Payout('Sep 2026', '฿12,300', 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revenue')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const KpiRow(stats: _kpis),
          const SizedBox(height: 20),
          const Text('Payout History', style: AppTypography.h2),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: _payouts
                  .map(
                    (p) => ListTile(
                      leading: Icon(
                        p.status == 'Paid' ? Icons.check_circle : Icons.hourglass_top,
                        color: p.status == 'Paid' ? AppColors.success : AppColors.warning,
                      ),
                      title: Text(p.month, style: AppTypography.body),
                      trailing: Text(p.amount, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text(p.status, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Payout {
  final String month;
  final String amount;
  final String status;

  const _Payout(this.month, this.amount, this.status);
}
