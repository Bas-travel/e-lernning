import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inProgress = MockRepository.enrolledCourses.where((c) => c.progress < 1.0).toList();
    final completed = MockRepository.enrolledCourses.where((c) => c.progress >= 1.0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Learning')),
      body: MockRepository.enrolledCourses.isEmpty
          ? _EmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (inProgress.isNotEmpty) ...[
                  const Text('In Progress', style: AppTypography.h2),
                  const SizedBox(height: 10),
                  ...inProgress.map((c) => _EnrolledCourseCard(course: c)),
                  const SizedBox(height: 12),
                ],
                if (completed.isNotEmpty) ...[
                  const Text('Completed', style: AppTypography.h2),
                  const SizedBox(height: 10),
                  ...completed.map((c) => _EnrolledCourseCard(course: c)),
                ],
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('No enrolled courses yet', style: AppTypography.h2),
            const SizedBox(height: 6),
            Text(
              'Head over to Explore to start your first course.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/explore'),
              child: const Text('Explore Courses'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrolledCourseCard extends StatelessWidget {
  final Course course;

  const _EnrolledCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${course.coverColorHex}', radix: 16));
    final isCompleted = course.progress >= 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => context.push('/course/${course.id}/curriculum'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(Icons.menu_book_rounded, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(course.title, style: AppTypography.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.pillSuccessBg, borderRadius: BorderRadius.circular(AppRadius.badge)),
                      child: Text('Completed', style: AppTypography.micro.copyWith(color: AppColors.success)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.badge),
                child: LinearProgressIndicator(
                  value: course.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.cardBorder,
                  valueColor: AlwaysStoppedAnimation(isCompleted ? AppColors.success : AppColors.primary),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${course.completedLessons}/${course.totalLessons} lessons · ${(course.progress * 100).round()}%',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
