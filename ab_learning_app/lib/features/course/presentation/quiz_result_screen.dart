import 'package:flutter/material.dart';

import 'certificate_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.score, required this.total, required this.percentage});

  final int score;
  final int total;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    final passed = percentage >= 70;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.verified_rounded : Icons.replay_rounded,
                size: 90,
                color: passed ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                passed ? 'Excellent!' : 'Good effort!',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'You scored $score/$total ($percentage%)',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              if (passed)
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CertificateScreen(courseName: 'Go Backend Professional'),
                    ),
                  ),
                  child: const Text('View Certificate'),
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Course'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
