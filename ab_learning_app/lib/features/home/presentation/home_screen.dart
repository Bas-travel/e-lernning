import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/role_switcher_sheet.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final continueLearning =
        MockRepository.enrolledCourses.where((c) => c.progress < 1.0).toList();
    final recommended = MockRepository.courses
        .where((c) => c.completedLessons == 0 && c.progress == 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AB LEARNING'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch role',
            onPressed: () => showRoleSwitcherSheet(context),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Welcome back, Learner! 👋', style: AppTypography.h1),
          const SizedBox(height: 4),
          Text(
            'Pick up where you left off, or start something new.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Hero AI prompt card.
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: () => context.push('/tutor'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What do you want to achieve today?',
                          style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ask your AI Tutor for a plan',
                          style: AppTypography.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),

          if (continueLearning.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Continue Learning',
              onSeeAll: () => context.push('/my-learning'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 176,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: continueLearning.length,
                itemBuilder: (context, i) => _HomeCourseCard(course: continueLearning[i]),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Text('Browse Categories', style: AppTypography.h2),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockRepository.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final category = MockRepository.categories[i];
                return ActionChip(
                  label: Text(category),
                  onPressed: () => context.push('/explore'),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: 'Recommended for you', onSeeAll: () => context.push('/explore')),
          const SizedBox(height: 12),
          SizedBox(
            height: 176,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommended.length,
              itemBuilder: (context, i) => _HomeCourseCard(course: recommended[i]),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.h2),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _HomeCourseCard extends StatelessWidget {
  final Course course;

  const _HomeCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${course.coverColorHex}', radix: 16));
    final showProgress = course.progress > 0;

    return GestureDetector(
      onTap: () => context.push('/course/${course.id}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 84,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.play_circle_fill, color: color, size: 32),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.h2.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.instructor,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  if (showProgress) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                      child: LinearProgressIndicator(
                        value: course.progress,
                        minHeight: 6,
                        backgroundColor: AppColors.cardBorder,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(course.progress * 100).round()}% complete',
                      style: AppTypography.micro.copyWith(color: AppColors.textSecondary),
                    ),
                  ] else
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.warning, size: 14),
                        const SizedBox(width: 4),
                        Text(course.rating.toStringAsFixed(1), style: AppTypography.caption),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
