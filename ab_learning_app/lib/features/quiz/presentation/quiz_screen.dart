import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

/// Screen 14 — Quiz. Single-select MCQ flow with a Previous/Next footer and
/// Submit on the last question.
class QuizScreen extends StatefulWidget {
  final String lessonId;

  const QuizScreen({super.key, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<QuizQuestion> _questions = MockRepository.sampleQuiz;
  late final List<int?> _selected = List.filled(_questions.length, null);
  int _index = 0;

  QuizQuestion get _current => _questions[_index];

  void _submit() {
    final lesson = MockRepository.lessonById(widget.lessonId);
    if (lesson != null) {
      MockRepository.completeLesson(lesson.id);
    }

    var correct = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_selected[i] == _questions[i].correctIndex) correct++;
    }

    final result = QuizAttemptResult(
      correctCount: correct,
      totalCount: _questions.length,
      selectedAnswers: List.of(_selected),
    );

    context.pushReplacement(
      '/quiz-result',
      extra: {'result': result, 'questions': _questions, 'lessonId': widget.lessonId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = MockRepository.lessonById(widget.lessonId);
    final isLastQuestion = _index == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text(lesson?.title ?? 'Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_index + 1}/${_questions.length}',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.badge),
              child: LinearProgressIndicator(
                value: (_index + 1) / _questions.length,
                minHeight: 6,
                backgroundColor: AppColors.cardBorder,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(_current.question, style: AppTypography.h2),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _current.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final selected = _selected[_index] == i;
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    onTap: () => setState(() => _selected[_index] = i),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: selected ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_current.options[i], style: AppTypography.body)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                if (_index > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _index -= 1),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.btnOutlineBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_index > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selected[_index] == null
                        ? null
                        : () {
                            if (isLastQuestion) {
                              _submit();
                            } else {
                              setState(() => _index += 1);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btnPrimaryBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isLastQuestion ? 'Submit' : 'Next',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
