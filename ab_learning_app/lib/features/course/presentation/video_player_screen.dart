import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String lessonId;

  const VideoPlayerScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    final lessonLabel = _lessonMap[lessonId] ?? 'Lesson Preview';

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Player')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 96),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              lessonLabel,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('18 min • Beginner-friendly • Includes practice notes'),
            const SizedBox(height: 20),
            const Text(
              'This lesson introduces the core concept, shows the workflow live, and gives a short problem-solving exercise to reinforce the session.',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Continue Watching'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Map<String, String> _lessonMap = {
    'go-rest-foundations': 'REST Foundations',
    'go-layered-architecture': 'Layered Architecture',
    'go-middleware-validation': 'Middleware and Validation',
    'flutter-app-architecture': 'App Architecture',
    'flutter-navigation-routes': 'Navigation and Routes',
    'flutter-state-ui-patterns': 'State and UI Patterns',
  };
}
