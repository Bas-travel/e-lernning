import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Demo content taken from `02-hifi-mockups.html`.
///
/// TODO(api): replace with the `GET /api/v1/home` response once the repository
/// layer is connected (entities: courses, enrollments, live_sessions).
class HomeCourse {
  const HomeCourse({
    required this.id,
    required this.title,
    required this.rating,
    required this.price,
    required this.gradient,
  });

  final String id;
  final String title;
  final String rating;
  final String price;
  final Gradient gradient;
}

class HomeSampleData {
  static const userName = 'คุณอนันต์';
  static const userInitial = 'A';
  static const coins = '2,450';
  static const careerProgress = 0.78;

  static const continueTitle = 'Go Backend Essentials';
  static const continueProgress = 0.0;
  static const continueLessonId = 'l3';
  static const continueCourseId = 'c3';

  static const recommended = <HomeCourse>[
    HomeCourse(
      id: 'c1',
      title: 'Flutter for Beginners',
      rating: '4.8 ★',
      price: '฿1,290',
      gradient: AppGradients.brand,
    ),
    HomeCourse(
      id: 'c2',
      title: 'UX Research Fundamentals',
      rating: '4.6 ★',
      price: '฿990',
      gradient: AppGradients.accentPrimary,
    ),
    HomeCourse(
      id: 'c5',
      title: 'Growth Marketing Playbook',
      rating: '4.4 ★',
      price: '฿1,090',
      gradient: AppGradients.accentSecondary,
    ),
  ];

  static const liveTitle = 'AI for Business — Live Q&A';
  static const liveStartsIn = 'อีก 2 ชม.';
}
