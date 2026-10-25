import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/auth_scaffold.dart';

// TODO(api): options come from `skills` / preferences; chips below are the
// mockup's content. Initial selection also mirrors the mockup.
const _interestsMobile = [
  'Programming', 'AI', 'Data', 'Marketing', 'Design', 'Business', 'Finance',
  'English',
];
const _interestsDesktop = ['Programming', 'AI', 'Data', 'Design', 'Marketing'];
const _levels = ['Beginner', 'Intermediate', 'Advanced'];
const _goalsMobile = ['Get a Job', 'Upskill', 'Career Change', 'Freelance'];
const _goalsDesktop = ['Get a Job', 'Upskill', 'Career Change'];

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _interests = {'Programming', 'AI'};
  String _level = 'Beginner';
  final Set<String> _goals = {'Get a Job'};

  void _toggle(Set<String> set, String value) {
    setState(() {
      if (!set.remove(value)) set.add(value);
    });
  }

  bool _saving = false;

  Future<void> _start() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await AppDependencies.authRepository.savePreferences(
        interests: _interests.toList(),
        level: _level,
        goals: _goals.toList(),
      );
    } catch (e) {
      // Preferences are not critical to continue (e.g. no session yet, or the
      // endpoint is not deployed). Do not block onboarding.
      debugPrint('savePreferences failed: $e');
    }
    if (!mounted) return;
    context.go('/home');
  }

  Widget _chips(
    List<String> options,
    bool Function(String) isActive,
    void Function(String) onTap,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          AppChip(label: o, active: isActive(o), onTap: () => onTap(o)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      cardWidth: 820,
      tinted: false,
      mobilePadding: const EdgeInsets.all(24),
      builder: (context, desktop) {
        final heading = AppTypography.base(
          desktop ? 12.5 : 13,
          weight: FontWeight.w600,
          color: desktop ? AppColors.textSecondary : AppColors.text,
        );

        if (!desktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'คุณสนใจเรื่องอะไร?',
                style: AppTypography.base(17, weight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _chips(
                _interestsMobile,
                _interests.contains,
                (v) => _toggle(_interests, v),
              ),
              const SizedBox(height: 22),
              Text('ระดับของคุณ', style: heading),
              const SizedBox(height: 10),
              _chips(_levels, (v) => v == _level, (v) {
                setState(() => _level = v);
              }),
              const SizedBox(height: 22),
              Text('เป้าหมาย', style: heading),
              const SizedBox(height: 10),
              _chips(_goalsMobile, _goals.contains, (v) => _toggle(_goals, v)),
              const SizedBox(height: 26),
              AppButton.primary(
                label: 'Start Learning',
                onPressed: _start,
                loading: _saving,
                expand: true,
              ),
            ],
          );
        }

        Widget column(String title, Widget child) => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: heading),
                  const SizedBox(height: 10),
                  child,
                ],
              ),
            );
        Widget stacked(
          List<String> options,
          bool Function(String) isActive,
          void Function(String) onTap,
        ) =>
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  AppChip(
                    label: options[i],
                    active: isActive(options[i]),
                    onTap: () => onTap(options[i]),
                  ),
                ],
              ],
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'บอกเราหน่อยว่าคุณสนใจอะไร',
              textAlign: TextAlign.center,
              style: AppTypography.base(20, weight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                column(
                  'สนใจ',
                  _chips(
                    _interestsDesktop,
                    _interests.contains,
                    (v) => _toggle(_interests, v),
                  ),
                ),
                const SizedBox(width: 14),
                column(
                  'ระดับ',
                  stacked(_levels, (v) => v == _level, (v) {
                    setState(() => _level = v);
                  }),
                ),
                const SizedBox(width: 14),
                column(
                  'เป้าหมาย',
                  stacked(
                    _goalsDesktop,
                    _goals.contains,
                    (v) => _toggle(_goals, v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            AppButton.primary(
              label: 'Start Learning',
              onPressed: _start,
              loading: _saving,
              expand: true,
            ),
          ],
        );
      },
    );
  }
}
