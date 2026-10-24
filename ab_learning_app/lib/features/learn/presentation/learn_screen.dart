import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/nav_targets.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/course_card.dart';
import '../../../core/widgets/responsive.dart';
import 'learn_sample_data.dart';

/// "My Learning" (bottom tab "Learn" / sidebar "My Learning").
///
/// There is no dedicated mockup for this screen: it is composed from the
/// existing Home "Continue learning" card and course list tile patterns.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => _buildMobile(context),
      desktop: (_) => _buildDesktop(context),
    );
  }

  void _resume(BuildContext context, EnrolledCourse c) =>
      context.push('/player/${c.nextLessonId}');

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: CenteredContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'My Learning',
                  style: AppTypography.base(16, weight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                for (final c in LearnSampleData.enrolled) ...[
                  AppCard(
                    onTap: () => _resume(context, c),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: c.gradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                style: AppTypography.base(
                                  12.5,
                                  weight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              AppProgressBar(value: c.progress),
                              const SizedBox(height: 6),
                              _ProgressMeta(progress: c.progress),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (i) => NavTargets.onTab(context, i),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            activeKey: 'learn',
            onSelect: (k) => NavTargets.onSidebar(context, k),
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'My Learning',
                      style: AppTypography.base(19, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    CardGrid(
                      columns: 3,
                      children: [
                        for (final c in LearnSampleData.enrolled)
                          CourseCard(
                            title: c.title,
                            gradient: c.gradient,
                            extra: AppProgressBar(value: c.progress),
                            meta: _ProgressMeta(progress: c.progress),
                            onTap: () => _resume(context, c),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressMeta extends StatelessWidget {
  const _ProgressMeta({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '${(progress * 100).round()}% เสร็จแล้ว',
            overflow: TextOverflow.ellipsis,
            style: AppTypography.base(11, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'เรียนต่อ',
          style: AppTypography.base(
            11,
            weight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
