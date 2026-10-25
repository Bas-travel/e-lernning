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

  static const continueTitle = 'Go Backend Masterclass';
  static const continueProgress = 0.68;
  static const continueLessonId = 'lesson1';
  static const continueCourseId = 'go-backend';

  static const recommended = <HomeCourse>[
    HomeCourse(
      id: 'ai-for-business',
      title: 'AI for Business',
      rating: '4.9 ★',
      price: '฿1,990',
      gradient: AppGradients.brand,
    ),
    HomeCourse(
      id: 'flutter-professional',
      title: 'Flutter Professional',
      rating: '4.8 ★',
      price: '฿2,490',
      gradient: AppGradients.accentPrimary,
    ),
    HomeCourse(
      id: 'digital-marketing',
      title: 'Digital Marketing',
      rating: '4.7 ★',
      price: '฿1,590',
      gradient: AppGradients.accentSecondary,
    ),
  ];

  static const liveTitle = 'AI for Business — Live Q&A';
  static const liveStartsIn = 'อีก 2 ชม.';
}
