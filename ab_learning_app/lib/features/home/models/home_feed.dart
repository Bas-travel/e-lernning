import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Mirrors the response of GET /api/v1/home in `05-openapi.yaml`.
class HomeFeed {
  const HomeFeed({
    required this.greetingName,
    required this.continueLearning,
    required this.recommended,
    required this.live,
    required this.careerPathProgressPct,
  });

  final String greetingName;
  final List<CourseSummary> continueLearning;
  final List<CourseSummary> recommended;
  final List<LiveSummary> live;
  final double careerPathProgressPct;

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    return HomeFeed(
      greetingName: json['greeting_name'] as String? ?? '',
      continueLearning: (json['continue_learning'] as List<dynamic>? ?? [])
          .map((e) => CourseSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommended: (json['recommended'] as List<dynamic>? ?? [])
          .map((e) => CourseSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      live: (json['live'] as List<dynamic>? ?? [])
          .map((e) => LiveSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      careerPathProgressPct:
          (json['career_path_progress_pct'] as num? ?? 0).toDouble(),
    );
  }
}

/// A trimmed-down `Course` — just what the Home feed cards need.
/// Full detail lives in the (not-yet-built) Course feature, screen 11.
class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.title,
    required this.instructorName,
    this.price,
    this.discountPrice,
    this.ratingAvg,
    this.progressPct,
    this.thumbnailGradient = AppColors.primaryGradient,
  });

  final int id;
  final String title;
  final String instructorName;
  final double? price;
  final double? discountPrice;
  final double? ratingAvg;
  final double? progressPct;
  final Gradient thumbnailGradient;

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    return CourseSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      instructorName: json['instructor_name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
      progressPct: (json['progress_pct'] as num?)?.toDouble(),
      thumbnailGradient: _gradientFor(json['thumbnail_gradient'] as String?),
    );
  }

  static Gradient _gradientFor(String? key) {
    switch (key) {
      case 'accent':
        return AppColors.accentGradient;
      case 'secondary':
        return const LinearGradient(
          colors: <Color>[AppColors.secondary, AppColors.primary],
        );
      case 'primary':
      default:
        return AppColors.primaryGradient;
    }
  }
}

class LiveSummary {
  const LiveSummary({
    required this.id,
    required this.title,
    required this.instructorName,
    required this.scheduledAt,
    required this.status,
  });

  final int id;
  final String title;
  final String instructorName;
  final DateTime scheduledAt;
  final String status; // upcoming, live, ended, cancelled

  bool get isLiveNow => status == 'live';

  factory LiveSummary.fromJson(Map<String, dynamic> json) {
    return LiveSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      instructorName: json['instructor_name'] as String? ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      status: json['status'] as String,
    );
  }

  /// e.g. "อีก 2 ชม." — used on the card's badge.
  String startsInLabel() {
    if (isLiveNow) return 'LIVE';
    final Duration diff = scheduledAt.difference(DateTime.now());
    if (diff.inMinutes <= 0) return 'เริ่มแล้ว';
    if (diff.inHours < 1) return 'อีก ${diff.inMinutes} นาที';
    if (diff.inHours < 24) return 'อีก ${diff.inHours} ชม.';
    return 'อีก ${diff.inDays} วัน';
  }
}
