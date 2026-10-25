import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Demo catalog taken from the mockups (Explore / Search).
/// TODO(api): replace with `GET /api/v1/courses` and `GET /api/v1/search?q=`.
class CatalogCourse {
  const CatalogCourse({
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

class CourseCatalogSample {
  static const trending = <CatalogCourse>[
    CatalogCourse(
      id: 'prompt-engineering',
      title: 'Prompt Engineering',
      rating: '4.9 ★',
      price: '฿1,490',
      gradient: AppGradients.brand,
    ),
    CatalogCourse(
      id: 'sql-masterclass',
      title: 'SQL Masterclass',
      rating: '4.8 ★',
      price: '฿1,290',
      gradient: AppGradients.accentPrimary,
    ),
  ];

  static const all = <CatalogCourse>[
    CatalogCourse(
      id: 'prompt-engineering',
      title: 'Prompt Engineering',
      rating: '4.9 ★',
      price: '฿1,490',
      gradient: AppGradients.brand,
    ),
    CatalogCourse(
      id: 'sql-masterclass',
      title: 'SQL Masterclass',
      rating: '4.8 ★',
      price: '฿1,290',
      gradient: AppGradients.accentPrimary,
    ),
    CatalogCourse(
      id: 'python-data-analytics',
      title: 'Python Data Analytics',
      rating: '4.8 ★',
      price: '฿1,990',
      gradient: AppGradients.accentSecondary,
    ),
    CatalogCourse(
      id: 'ux-ui-design',
      title: 'UX/UI Design',
      rating: '4.7 ★',
      price: '฿1,690',
      gradient: AppGradients.warm,
    ),
  ];

  static const searchable = <CatalogCourse>[
    CatalogCourse(
      id: 'flutter-professional',
      title: 'Flutter Professional',
      rating: '4.8 ★',
      price: '฿2,490',
      gradient: AppGradients.brand,
    ),
    CatalogCourse(
      id: 'flutter-go-full-stack',
      title: 'Flutter + Go Full Stack',
      rating: '4.9 ★',
      price: '฿3,290',
      gradient: AppGradients.live,
    ),
    CatalogCourse(
      id: 'flutter-advanced-animation',
      title: 'Flutter Advanced Animation',
      rating: '4.7 ★',
      price: '฿1,890',
      gradient: AppGradients.warm,
    ),
    ...all,
  ];

  static const categories = <String>[
    'ทั้งหมด',
    'Programming',
    'AI',
    'Data',
    'Design',
    'Marketing',
    'Business',
  ];

  static List<CatalogCourse> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return searchable;
    return searchable.where((c) => c.title.toLowerCase().contains(q)).toList();
  }
}

/// Price bands offered by the Explore filter.
enum PriceBand {
  any('ทุกราคา'),
  under1500('ต่ำกว่า ฿1,500'),
  from1500('฿1,500 ขึ้นไป');

  const PriceBand(this.label);
  final String label;
}

/// Client-side filter applied to the demo catalog.
/// TODO(api): send as query params to `GET /courses` instead.
class CourseFilter {
  const CourseFilter({this.price = PriceBand.any, this.minRating = 0});

  final PriceBand price;
  final double minRating;

  bool get isActive => price != PriceBand.any || minRating > 0;

  static double _number(String text) =>
      double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  bool matches(CatalogCourse c) {
    final amount = _number(c.price);
    final okPrice = switch (price) {
      PriceBand.any => true,
      PriceBand.under1500 => amount < 1500,
      PriceBand.from1500 => amount >= 1500,
    };
    return okPrice && _number(c.rating) >= minRating;
  }
}
