import 'package:flutter/painting.dart';

import '../../../core/network/rest_client.dart';
import '../../../core/theme/colors.dart';
import '../presentation/learn_sample_data.dart';

const _gradients = <Gradient>[
  AppGradients.brand,
  AppGradients.accentPrimary,
  AppGradients.accentSecondary,
];

/// Maps one `GET /me/courses` row. `progress` arrives as 0-100.
EnrolledCourse enrolledFromJson(Map<String, dynamic> json, int index) {
  final courseId = (json['id'] as num?)?.toInt() ?? 0;
  final lastLesson = (json['last_lesson_id'] as num?)?.toInt();
  final percent = ((json['progress'] as num?)?.toDouble() ?? 0).clamp(0, 100);
  return EnrolledCourse(
    id: '$courseId',
    title: json['title'] as String? ?? '',
    progress: percent / 100,
    gradient: _gradients[index % _gradients.length],
    // Resume where the learner stopped; a course never opened goes to its page.
    resumeRoute:
        lastLesson == null ? '/course/$courseId' : '/player/$lastLesson',
  );
}

abstract class LearnRepository {
  bool get bundledOnly;

  /// The signed-in learner's enrolments. Throws when the server cannot be
  /// reached so the screen can offer a retry.
  Future<List<EnrolledCourse>> enrolled();
}

class ApiLearnRepository implements LearnRepository {
  ApiLearnRepository(this._client);

  final RestClient _client;

  @override
  bool get bundledOnly => false;

  @override
  Future<List<EnrolledCourse>> enrolled() async {
    final res = await _client.dio.get<List<dynamic>>('/me/courses');
    final rows = res.data ?? const <dynamic>[];
    return [
      for (var i = 0; i < rows.length; i++)
        if (rows[i] is Map<String, dynamic>)
          enrolledFromJson(rows[i] as Map<String, dynamic>, i),
    ];
  }
}

/// Offline stand-in (`USE_MOCK_AUTH`, tests): the mockup's demo enrolments.
class OfflineLearnRepository implements LearnRepository {
  const OfflineLearnRepository();

  @override
  bool get bundledOnly => true;

  @override
  Future<List<EnrolledCourse>> enrolled() async => LearnSampleData.enrolled;
}
