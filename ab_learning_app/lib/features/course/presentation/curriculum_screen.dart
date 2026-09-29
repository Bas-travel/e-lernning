import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

class CurriculumScreen extends StatelessWidget {
  final String courseId;

  const CurriculumScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final course = MockRepository.courseById(courseId);
    final sections = MockRepository.curriculumFor(courseId);

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: LinearProgressIndicator(
              value: course.progress,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${course.completedLessons}/${course.totalLessons} lessons completed',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final section in sections) _SectionAccordion(courseId: courseId, section: section),
        ],
      ),
    );
  }
}

class _SectionAccordion extends StatelessWidget {
  final String courseId;
  final CourseSection section;

  const _SectionAccordion({required this.courseId, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(section.title, style: AppTypography.h2),
          childrenPadding: const EdgeInsets.only(bottom: 4),
          children: section.lessons.map((lesson) => _LessonRow(courseId: courseId, lesson: lesson)).toList(),
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final String courseId;
  final LessonItem lesson;

  const _LessonRow({required this.courseId, required this.lesson});

  IconData get _icon {
    switch (lesson.state) {
      case LessonState.completed:
        return Icons.check_circle;
      case LessonState.inProgress:
        return Icons.play_circle_fill;
      case LessonState.locked:
        return Icons.lock_outline;
    }
  }

  Color _iconColor() {
    switch (lesson.state) {
      case LessonState.completed:
        return AppColors.success;
      case LessonState.inProgress:
        return AppColors.primary;
      case LessonState.locked:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = lesson.state == LessonState.locked;

    return ListTile(
      leading: Icon(_icon, color: _iconColor()),
      title: Text(
        lesson.title,
        style: AppTypography.body.copyWith(color: locked ? AppColors.textSecondary : AppColors.text),
      ),
      subtitle: Text(lesson.duration, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
      trailing: locked ? null : const Icon(Icons.chevron_right, size: 18),
      enabled: !locked,
      onTap: locked
          ? null
          : () {
              if (lesson.hasQuiz) {
                context.push('/quiz/${lesson.id}');
              } else {
                context.push('/player/${lesson.id}');
              }
            },
    );
  }
}
