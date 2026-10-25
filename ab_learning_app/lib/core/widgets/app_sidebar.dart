import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Desktop `.sidebar-d` (240px).
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key, this.activeKey = 'home', this.onSelect});

  final String activeKey;
  final ValueChanged<String>? onSelect;

  static const items = <({String label, String key})>[
    (label: 'Home', key: 'home'),
    (label: 'Explore', key: 'explore'),
    (label: 'My Learning', key: 'learn'),
    (label: 'Live', key: 'live'),
    (label: 'Community', key: 'community'),
    (label: 'AI Tutor', key: 'ai'),
    (label: 'Career', key: 'career'),
    (label: 'Portfolio', key: 'portfolio'),
    (label: 'Jobs', key: 'jobs'),
    (label: 'Wallet', key: 'wallet'),
    (label: 'Settings', key: 'settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 22),
                child: Text(
                  'AB LEARNING',
                  style: AppTypography.base(
                    16,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Semantics(
                    button: true,
                    selected: item.key == activeKey,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap:
                          onSelect == null ? null : () => onSelect!(item.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: item.key == activeKey
                              ? AppColors.primaryTint
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.label,
                          style: AppTypography.base(
                            13,
                            weight: item.key == activeKey
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: item.key == activeKey
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
