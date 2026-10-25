import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quizId});
  final String quizId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<String, String> _answers = {};
  int _questionIndex = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'q1',
      'text': 'What is Go commonly used for?',
      'options': [
        'Frontend UI',
        'Backend services',
        'Graphic design',
        'Database schema only'
      ],
      'correct': 'Backend services',
    },
    {
      'id': 'q2',
      'text': 'Which keyword declares a function in Go?',
      'options': ['func', 'fn', 'function', 'def'],
      'correct': 'func',
    },
  ];

  void _selectOption(String option) {
    setState(() {
      _answers[_questions[_questionIndex]['id']] = option;
    });
  }

  void _nextQuestion() {
    if (_questionIndex < _questions.length - 1) {
      setState(() => _questionIndex++);
      return;
    }

    final correct =
        _questions.where((q) => _answers[q['id']] == q['correct']).length;
    final result = (correct / _questions.length) * 100;

    context.go(
        '/quiz-result?score=$correct&total=${_questions.length}&percentage=${result.round()}');
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_questionIndex];
    final currentSelected = _answers[question['id']];

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_questionIndex + 1}/${_questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(question['text'],
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            RadioGroup<String>(
              groupValue: currentSelected,
              onChanged: (value) {
                if (value != null) _selectOption(value);
              },
              child: Column(
                children: (question['options'] as List<String>)
                    .map((option) => RadioListTile<String>(
                          title: Text(option),
                          value: option,
                        ))
                    .toList(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _nextQuestion(),
                child: Text(_questionIndex == _questions.length - 1
                    ? 'Submit'
                    : 'Next Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
