/// Course catalog shapes returned by `GET /courses/{id}`,
/// `GET /courses/{id}/curriculum` and `GET /lessons/{id}`.
///
/// Parsing is deliberately forgiving: a missing optional field must not take
/// a whole screen down.
class CatalogCourse {
  const CatalogCourse({
    required this.id,
    required this.title,
    this.description = '',
    this.instructorName = '',
    this.price = 0,
    this.discountPrice,
    this.ratingAvg = 0,
    this.studentCount = 0,
    this.level = '',
    this.category = '',
    this.thumbnailUrl = '',
  });

  final int id;
  final String title;
  final String description;
  final String instructorName;
  final double price;
  final double? discountPrice;
  final double ratingAvg;
  final int studentCount;
  final String level;
  final String category;
  final String thumbnailUrl;

  /// What the learner actually pays.
  double get effectivePrice => discountPrice ?? price;

  factory CatalogCourse.fromJson(Map<String, dynamic> json) {
    final instructor = json['instructor'];
    return CatalogCourse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructorName: instructor is Map
          ? instructor['display_name'] as String? ?? ''
          : json['instructor_name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      studentCount: (json['student_count'] as num?)?.toInt() ?? 0,
      level: json['level'] as String? ?? '',
      category: json['category'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
    );
  }
}

class CatalogLesson {
  const CatalogLesson({
    required this.id,
    required this.title,
    this.type = 'video',
    this.durationSeconds = 0,
    this.isPreview = false,
    this.videoUrl,
  });

  final int id;
  final String title;
  final String type;
  final int durationSeconds;
  final bool isPreview;
  final String? videoUrl;

  /// "12:05" style label.
  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  factory CatalogLesson.fromJson(Map<String, dynamic> json) {
    final video = json['video_url'] as String?;
    return CatalogLesson(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? 'video',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      isPreview: json['is_preview'] as bool? ?? false,
      videoUrl: (video == null || video.isEmpty) ? null : video,
    );
  }
}

class CatalogSection {
  const CatalogSection({
    required this.id,
    required this.title,
    required this.lessons,
  });

  final int id;
  final String title;
  final List<CatalogLesson> lessons;

  factory CatalogSection.fromJson(Map<String, dynamic> json) {
    return CatalogSection(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      lessons: (json['lessons'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CatalogLesson.fromJson)
          .toList(),
    );
  }
}

/// `GET /lessons/{id}`: a lesson plus the learner's progress on it.
class LessonDetail {
  const LessonDetail({
    required this.id,
    required this.courseId,
    required this.title,
    this.sectionTitle = '',
    this.type = 'video',
    this.videoUrl,
    this.durationSeconds = 0,
    this.status = 'not_started',
    this.watchedSeconds = 0,
  });

  final int id;
  final int courseId;
  final String title;
  final String sectionTitle;
  final String type;
  final String? videoUrl;
  final int durationSeconds;
  final String status;
  final int watchedSeconds;

  bool get isCompleted => status == 'completed';

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    final video = json['video_url'] as String?;
    return LessonDetail(
      id: (json['id'] as num).toInt(),
      courseId: (json['course_id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      sectionTitle: json['section_title'] as String? ?? '',
      type: json['type'] as String? ?? 'video',
      videoUrl: (video == null || video.isEmpty) ? null : video,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'not_started',
      watchedSeconds: (json['watched_seconds'] as num?)?.toInt() ?? 0,
    );
  }
}
