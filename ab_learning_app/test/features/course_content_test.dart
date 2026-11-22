import 'package:ab_learning_app/core/format/baht.dart';
import 'package:ab_learning_app/features/catalog/data/catalog_models.dart';
import 'package:ab_learning_app/features/course/presentation/course_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatBaht', () {
    test('groups thousands', () {
      expect(formatBaht(2990), '฿2,990');
      expect(formatBaht(1234567), '฿1,234,567');
      expect(formatBaht(450), '฿450');
    });

    test('free or unknown is ฟรี', () {
      expect(formatBaht(0), 'ฟรี');
      expect(formatBaht(null), 'ฟรี');
    });
  });

  group('CourseContent', () {
    const course = CatalogCourse(
      id: 7,
      title: 'Go API',
      instructorName: 'Dr. Krit',
      price: 4990,
      discountPrice: 2990,
      ratingAvg: 4.9,
      studentCount: 120,
    );
    const sections = [
      CatalogSection(
        id: 1,
        title: 'Intro',
        lessons: [
          CatalogLesson(
            id: 11,
            title: 'Welcome',
            durationSeconds: 125,
            isPreview: true,
          ),
          CatalogLesson(id: 12, title: 'Locked', durationSeconds: 3600),
        ],
      ),
    ];

    test('sample keeps the mockup content', () {
      final c = CourseContent.sample();
      expect(c.title, 'Go Backend Professional');
      expect(c.priceLabel, '฿2,990');
      expect(c.discountBadge, '-40%');
      expect(c.savingsBadge, 'ประหยัด 40%');
      expect(c.outcomes, isNotEmpty);
      expect(c.lessons.last.locked, isTrue);
    });

    test('fromApi maps price, discount, meta and lessons', () {
      final c = CourseContent.fromApi(course, sections);
      expect(c.title, 'Go API');
      expect(c.priceLabel, '฿2,990');
      expect(c.oldPriceLabel, '฿4,990');
      expect(c.discountBadge, '-40%');
      expect(c.metaMobile, '⭐ 4.9 · 120 students · Dr. Krit');
      expect(c.outcomes, isEmpty);
      expect(c.lessons.map((l) => l.lessonId), ['11', '12']);
      expect(c.lessons.first.locked, isFalse);
      expect(c.lessons.first.duration, '2:05');
      expect(c.lessons.last.locked, isTrue);
      expect(c.infoLines, contains('1h 2m'));
      expect(c.infoLines, contains('2 บทเรียน'));
    });

    test('no discount means no badges and no old price', () {
      final c = CourseContent.fromApi(
        const CatalogCourse(id: 1, title: 'Free', price: 0),
        const [],
      );
      expect(c.priceLabel, 'ฟรี');
      expect(c.oldPriceLabel, isNull);
      expect(c.discountBadge, isNull);
      expect(c.savingsBadge, isNull);
    });
  });
}
