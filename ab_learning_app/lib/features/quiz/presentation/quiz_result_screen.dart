import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

/// Screen 15 — Quiz Result. Shows a score ring, pass/fail badge, skill
/// analysis bars, and next-step actions.
class QuizResultScreen extends StatelessWidget {
  final QuizAttemptResult result;
  final List<QuizQuestion> questions;
  final String lessonId;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.questions,
    required this.lessonId,
  });

  void _showReviewAnswers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: questions.length,
          separatorBuilder: (_, __) => const Divider(height: 32),
          itemBuilder: (context, i) {
            final q = questions[i];
            final selected = result.selectedAnswers[i];
            final isCorrect = selected == q.correctIndex;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Q${i + 1}. ${q.question}', style: AppTypography.h2),
                const SizedBox(height: 8),
                for (var j = 0; j < q.options.length; j++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          j == q.correctIndex
                              ? Icons.check_circle
                              : (j == selected ? Icons.cancel : Icons.circle_outlined),
                          size: 18,
                          color: j == q.correctIndex
                              ? AppColors.success
                              : (j == selected ? AppColors.error : AppColors.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(q.options[j], style: AppTypography.body)),
                      ],
                    ),
                  ),
                if (!isCorrect)
                  Text(
                    'Your answer was incorrect.',
                    style: AppTypography.caption.copyWith(color: AppColors.error),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = result.scorePercent;
    final isPass = result.isPass;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 12,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: AlwaysStoppedAnimation(isPass ? AppColors.success : AppColors.error),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(percent * 100).round()}%', style: AppTypography.display),
                      Text(
                        '${result.correctCount}/${result.totalCount} correct',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isPass ? AppColors.pillSuccessBg : AppColors.pillErrorBg,
                borderRadius: BorderRadius.circular(AppRadius.badge),
              ),
              child: Text(
                isPass ? 'Passed' : 'Not Passed',
                style: AppTypography.caption.copyWith(
                  color: isPass ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text('Skill Analysis', style: AppTypography.h2),
          const SizedBox(height: 12),
          ...MockRepository.skillBreakdown.map(
            (skill) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(skill.skill, style: AppTypography.body),
                      Text('${(skill.percent * 100).round()}%', style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                    child: LinearProgressIndicator(
                      value: skill.percent,
                      minHeight: 8,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: AlwaysStoppedAnimation(
                        skill.percent >= 0.7 ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimaryBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
              onPressed: () => context.go('/home'),
              child: const Text('Continue Learning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.btnOutlineBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
              onPressed: () => _showReviewAnswers(context),
              child: const Text('Review Answers'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => context.pushReplacement('/quiz/$lessonId'),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}
