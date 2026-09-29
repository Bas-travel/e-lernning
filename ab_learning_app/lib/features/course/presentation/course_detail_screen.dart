import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final course = MockRepository.courseById(courseId);
    final color = Color(int.parse('FF${course.coverColorHex}', radix: 16));
    final isEnrolled = course.completedLessons > 0 || course.progress > 0;
    final previewLessons = MockRepository.curriculumFor(courseId).first.lessons.take(3);

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
            children: [
              Container(
                height: 220,
                color: color.withValues(alpha: 0.15),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SafeArea(
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.text),
                            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(Icons.play_circle_fill, color: color, size: 64),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: AppTypography.display.copyWith(fontSize: 22)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.warning, size: 16),
                        const SizedBox(width: 4),
                        Text(course.rating.toStringAsFixed(1), style: AppTypography.body),
                        const SizedBox(width: 8),
                        Text(
                          '(${course.students} students)',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(radius: 16, backgroundColor: color.withValues(alpha: 0.2), child: Icon(Icons.person, color: color, size: 18)),
                        const SizedBox(width: 8),
                        Text(course.instructor, style: AppTypography.body),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(course.priceLabel, style: AppTypography.h1.copyWith(color: AppColors.primary)),
                        if (course.originalPriceLabel != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            course.originalPriceLabel!,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Divider(height: 32),

                    const Text('Description', style: AppTypography.h2),
                    const SizedBox(height: 8),
                    Text(
                      course.description.isEmpty
                          ? 'No description available yet for this course.'
                          : course.description,
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    if (course.whatYouLearn.isNotEmpty) ...[
                      const Text("What You'll Learn", style: AppTypography.h2),
                      const SizedBox(height: 8),
                      ...course.whatYouLearn.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item, style: AppTypography.body)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Curriculum', style: AppTypography.h2),
                        TextButton(
                          onPressed: () => context.push('/course/$courseId/curriculum'),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: previewLessons
                            .map((lesson) => ListTile(
                                  leading: Icon(
                                    lesson.state == LessonState.completed
                                        ? Icons.check_circle
                                        : Icons.play_circle_outline,
                                    color: lesson.state == LessonState.completed
                                        ? AppColors.success
                                        : AppColors.primary,
                                  ),
                                  title: Text(lesson.title, style: AppTypography.body),
                                  trailing: Text(
                                    lesson.duration,
                                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.cardBorder)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btnPrimaryBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                    ),
                    onPressed: () => context.push('/course/$courseId/curriculum'),
                    child: Text(
                      isEnrolled ? 'Continue Learning' : 'Start Learning',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
