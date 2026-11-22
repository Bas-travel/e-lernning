import '../../../core/format/baht.dart';
import '../../catalog/data/catalog_models.dart';

/// One row of the curriculum list.
class CourseLessonRow {
  const CourseLessonRow({
    required this.lessonId,
    required this.title,
    required this.duration,
    this.prefix = '▶',
    this.locked = false,
  });

  /// Route parameter for `/player/:id`.
  final String lessonId;
  final String prefix;
  final String title;
  final String duration;
  final bool locked;
}

/// Everything the hi-fi Course detail screen shows that can come from the
/// server, built either from the mockup's sample data or from
/// `GET /courses/{id}` + `GET /courses/{id}/curriculum`.
class CourseContent {
  const CourseContent({
    required this.title,
    required this.metaMobile,
    required this.metaDesktop,
    required this.priceLabel,
    required this.lessons,
    required this.infoLines,
    this.oldPriceLabel,
    this.discountPercent,
    this.outcomes = const [],
  });

  /// The demo content from the mockup (offline / slug ids).
  factory CourseContent.sample() {
    return const CourseContent(
      title: 'Go Backend Professional',
      metaMobile: '⭐ 4.9 (2,140) · 8,421 students · Dr. Krit',
      metaDesktop: '⭐ 4.9 (2,140 รีวิว) · 8,421 students · สอนโดย Dr. Krit',
      priceLabel: '฿2,990',
      oldPriceLabel: '฿4,990',
      discountPercent: 40,
      outcomes: [
        'ออกแบบ REST API ด้วย Go',
        'เชื่อมต่อฐานข้อมูล MySQL',
        'Authentication ด้วย JWT',
        'Deploy สู่ Production',
      ],
      lessons: [
        CourseLessonRow(
          lessonId: 'lesson1',
          prefix: '✓',
          title: 'Introduction',
          duration: '12 min',
        ),
        CourseLessonRow(
          lessonId: 'lesson1',
          title: 'Go Fundamentals',
          duration: '1h 20m',
        ),
        CourseLessonRow(
          lessonId: 'lesson1',
          prefix: '🔒',
          title: 'Production Deployment',
          duration: '40 min',
          locked: true,
        ),
      ],
      infoLines:
          '📹 18h 30m วิดีโอ\n📄 42 บทเรียน\n🏆 ใบเกียรติบัตรเมื่อจบหลักสูตร',
    );
  }

  /// Built from the server. The API has no "what you will learn" list, so
  /// [outcomes] stays empty and the screen hides that section.
  factory CourseContent.fromApi(
    CatalogCourse course,
    List<CatalogSection> sections,
  ) {
    final lessons = [for (final s in sections) ...s.lessons];
    final totalSeconds = lessons.fold<int>(
      0,
      (sum, l) => sum + l.durationSeconds,
    );
    final hasDiscount = course.discountPrice != null &&
        course.price > 0 &&
        course.discountPrice! < course.price;

    final meta = <String>[
      if (course.ratingAvg > 0) '⭐ ${course.ratingAvg.toStringAsFixed(1)}',
      '${course.studentCount} students',
      if (course.instructorName.isNotEmpty) course.instructorName,
    ];

    return CourseContent(
      title: course.title,
      metaMobile: meta.join(' · '),
      metaDesktop: meta.join(' · '),
      priceLabel: formatBaht(course.effectivePrice),
      oldPriceLabel: hasDiscount ? formatBaht(course.price) : null,
      discountPercent: hasDiscount
          ? ((1 - course.discountPrice! / course.price) * 100).round()
          : null,
      lessons: [
        for (final l in lessons)
          CourseLessonRow(
            lessonId: '${l.id}',
            prefix: _isOpen(l) ? '▶' : '🔒',
            title: l.title,
            duration: l.durationLabel,
            locked: !_isOpen(l),
          ),
      ],
      infoLines: '📹 ${_hoursMinutes(totalSeconds)} วิดีโอ\n'
          '📄 ${lessons.length} บทเรียน\n'
          '🏆 ใบเกียรติบัตรเมื่อจบหลักสูตร',
    );
  }

  final String title;
  final String metaMobile;
  final String metaDesktop;
  final String priceLabel;
  final String? oldPriceLabel;
  final int? discountPercent;
  final List<String> outcomes;
  final List<CourseLessonRow> lessons;
  final String infoLines;

  /// "-40%" badge on mobile; null when there is no discount.
  String? get discountBadge =>
      discountPercent == null ? null : '-$discountPercent%';

  /// "ประหยัด 40%" badge on desktop; null when there is no discount.
  String? get savingsBadge =>
      discountPercent == null ? null : 'ประหยัด $discountPercent%';

  /// A lesson is playable when it is a free preview or the server sent its
  /// video (i.e. the learner is allowed to watch it).
  static bool _isOpen(CatalogLesson l) => l.isPreview || l.videoUrl != null;

  static String _hoursMinutes(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}
