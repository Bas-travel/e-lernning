import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Demo enrolments. TODO(api): `GET /api/v1/me/courses` (+ enrollment progress).
class EnrolledCourse {
  const EnrolledCourse({
    required this.id,
    required this.title,
    required this.progress,
    required this.gradient,
    this.nextLessonId = 'lesson1',
  });

  final String id;
  final String title;
  final double progress;
  final Gradient gradient;
  final String nextLessonId;
}

class LearnSampleData {
  static const enrolled = <EnrolledCourse>[
    EnrolledCourse(
      id: 'go-backend',
      title: 'Go Backend Masterclass',
      progress: 0.68,
      gradient: AppGradients.brand,
    ),
    EnrolledCourse(
      id: 'flutter-professional',
      title: 'Flutter Professional',
      progress: 0.35,
      gradient: AppGradients.accentPrimary,
    ),
    EnrolledCourse(
      id: 'ai-for-business',
      title: 'AI for Business',
      progress: 0.1,
      gradient: AppGradients.accentSecondary,
    ),
  ];
}
