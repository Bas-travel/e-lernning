import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final course = _courseMap[courseId] ?? _courseMap['c001']!;

    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course['category'] as String, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(course['title'] as String, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${course['instructor']} • ${course['duration']} • ${course['level']}'),
            const SizedBox(height: 16),
            Text(course['description'] as String),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.orange),
                Text(' ${course['rating']} '),
                const SizedBox(width: 24),
                const Icon(Icons.access_time_rounded),
                Text(' ${course['duration']}'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/player/${course['firstLesson']}'),
                child: const Text('Start Lesson'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/quiz/q001'),
                child: const Text('Take Quiz'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Course Curriculum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...((course['lessons'] as List<String>).map((lesson) => ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(lesson),
                  onTap: () => context.go('/player/${lesson.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}'),
                ))),
          ],
        ),
      ),
    );
  }

  static const Map<String, Map<String, Object>> _courseMap = {
    'c001': {
      'title': 'Go Backend Professional',
      'category': 'Backend',
      'instructor': 'Nattapong',
      'duration': '6 weeks',
      'level': 'Intermediate',
      'rating': '4.9',
      'description': 'Learn how to design robust backend services, build clean architecture, and ship scalable APIs with Go.',
      'firstLesson': 'go-rest-foundations',
      'lessons': ['REST Foundations', 'Layered Architecture', 'Middleware and Validation'],
    },
    'c002': {
      'title': 'Flutter Professional',
      'category': 'Mobile',
      'instructor': 'Kanya',
      'duration': '5 weeks',
      'level': 'Intermediate',
      'rating': '4.8',
      'description': 'Master mobile app UX, routing, and state handling with scalable Flutter patterns.',
      'firstLesson': 'flutter-app-architecture',
      'lessons': ['App Architecture', 'Navigation and Routes', 'State and UI Patterns'],
    },
  };
}
