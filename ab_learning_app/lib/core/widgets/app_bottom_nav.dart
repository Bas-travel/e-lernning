import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// `.bottomnav` — Home / Explore / Learn / Community / Profile.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.currentIndex = 0, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.search, label: 'Explore'),
    (icon: Icons.school_outlined, label: 'Learn'),
    (icon: Icons.chat_bubble_outline, label: 'Community'),
    (icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 9, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == currentIndex,
                    label: _items[i].label,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onTap == null ? null : () => onTap!(i),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _items[i].icon,
                            size: 20,
                            color: i == currentIndex
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _items[i].label,
                            style: AppTypography.base(
                              10,
                              weight: i == currentIndex
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: i == currentIndex
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              height: 1.2,
                            ),
                          ),
                        ],
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
