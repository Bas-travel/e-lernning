import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import 'profile_sample_data.dart';

/// TODO(api): `GET /portfolio` / `PUT /portfolio`.
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Portfolio',
      children: [
        const SizedBox(height: 8),
        for (final p in ProfileSampleData.portfolio) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title, style: AppTypography.base(14, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  p.summary,
                  style: AppTypography.base(
                    12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final t in p.tags) AppChip(label: t)],
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
