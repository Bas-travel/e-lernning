import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import 'profile_sample_data.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Wallet',
      children: [
        AppCard(
          gradient: AppGradients.brand,
          borderColor: Colors.transparent,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ยอดคงเหลือ',
                style: AppTypography.base(12, color: AppColors.whiteA85),
              ),
              const SizedBox(height: 4),
              Text(
                formatBaht(ProfileSampleData.walletBalance),
                style: AppTypography.base(
                  28,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SectionLabel('รายการล่าสุด'),
        for (final t in ProfileSampleData.transactions) ...[
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: AppTypography.base(13, weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        t.date,
                        style: AppTypography.base(11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${t.amount > 0 ? '+' : ''}${formatBaht(t.amount)}',
                  style: AppTypography.base(
                    13,
                    weight: FontWeight.w700,
                    color: t.amount > 0 ? AppColors.pillSuccessFg : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
