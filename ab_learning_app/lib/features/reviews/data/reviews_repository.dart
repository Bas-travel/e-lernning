import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/rest_client.dart';
import '../../wallet/data/wallet_repository.dart' show thaiDate;

class CourseReview {
  const CourseReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.author,
    required this.mine,
    required this.date,
  });

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse(json['created_at'] as String? ?? '');
    return CourseReview(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      author: json['author'] as String? ?? '',
      mine: json['mine'] as bool? ?? false,
      date: created == null ? '' : thaiDate(created.toLocal()),
    );
  }

  final int id;
  final int rating;
  final String comment;
  final String author;
  final bool mine;
  final String date;
}

class ReviewsPage {
  const ReviewsPage({
    required this.items,
    required this.average,
    required this.count,
  });

  factory ReviewsPage.fromJson(Map<String, dynamic> json) => ReviewsPage(
        items: [
          for (final raw in (json['items'] as List<dynamic>? ?? const []))
            if (raw is Map<String, dynamic>) CourseReview.fromJson(raw),
        ],
        average: (json['rating_avg'] as num?)?.toDouble() ?? 0,
        count: (json['rating_count'] as num?)?.toInt() ?? 0,
      );

  static const empty = ReviewsPage(items: [], average: 0, count: 0);

  final List<CourseReview> items;
  final double average;
  final int count;

  CourseReview? get mine {
    for (final r in items) {
      if (r.mine) return r;
    }
    return null;
  }
}

enum ReviewSubmitResult { saved, notEnrolled, invalid, failed }

abstract class ReviewsRepository {
  bool get bundledOnly;

  /// Throws when the server cannot be reached so the screen can offer a retry.
  Future<ReviewsPage> list(String courseId);

  Future<ReviewSubmitResult> submit(
    String courseId, {
    required int rating,
    required String comment,
  });
}

class ApiReviewsRepository implements ReviewsRepository {
  ApiReviewsRepository(this._client);

  final RestClient _client;

  @override
  bool get bundledOnly => false;

  @override
  Future<ReviewsPage> list(String courseId) async {
    final res = await _client.dio.get<Map<String, dynamic>>(
      '/courses/$courseId/reviews',
      queryParameters: {'limit': 50},
    );
    return ReviewsPage.fromJson(res.data ?? const {});
  }

  @override
  Future<ReviewSubmitResult> submit(
    String courseId, {
    required int rating,
    required String comment,
  }) async {
    try {
      await _client.dio.post<Object?>(
        '/courses/$courseId/reviews',
        data: {'rating': rating, 'comment': comment},
      );
      return ReviewSubmitResult.saved;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      debugPrint('review submit failed: ${status ?? e.type}');
      if (status == 403) return ReviewSubmitResult.notEnrolled;
      if (status == 400) return ReviewSubmitResult.invalid;
      return ReviewSubmitResult.failed;
    }
  }
}

/// Offline stand-in (`USE_MOCK_AUTH`, tests): no reviews, nothing saved.
class OfflineReviewsRepository implements ReviewsRepository {
  const OfflineReviewsRepository();

  @override
  bool get bundledOnly => true;

  @override
  Future<ReviewsPage> list(String courseId) async => ReviewsPage.empty;

  @override
  Future<ReviewSubmitResult> submit(
    String courseId, {
    required int rating,
    required String comment,
  }) async =>
      ReviewSubmitResult.failed;
}
