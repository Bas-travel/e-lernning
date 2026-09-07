import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseCatalogScreen extends StatelessWidget {
  const CourseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = [
      {
        'id': 'c001',
        'title': 'Go Backend Professional',
        'category': 'Backend',
        'level': 'Intermediate',
        'price': '1490',
      },
      {
        'id': 'c002',
        'title': 'Flutter Professional',
        'category': 'Mobile',
        'level': 'Intermediate',
        'price': '1390',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Course Marketplace')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(course['title'] as String),
                subtitle: Text('${course['category']} • ${course['level']} • ฿${course['price']}'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onTap: () => context.go('/course/${course['id']}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
