import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/rest_client.dart';
import '../../home/models/home_feed.dart';
import 'catalog_models.dart';

/// Read access to the server-side catalog and the signed-in learner's feed.
///
/// Every method returns `null` when the data is **not available** (an id that
/// is not numeric, an unreachable server, a 404 or 5xx). Screens treat `null`
/// as "use the bundled sample data", so the app keeps working offline and the
/// slug-based demo content (`go-backend`, `lesson1`) keeps resolving.
abstract class CatalogRepository {
  Future<HomeFeed?> homeFeed();
  Future<CatalogCourse?> course(String id);
  Future<List<CatalogSection>?> curriculum(String courseId);
  Future<LessonDetail?> lesson(String id);

  /// Reports watch progress; returns whether the server accepted it.
  Future<bool> saveProgress(
    String lessonId, {
    required int watchedSeconds,
    required String status,
  });
}

/// The real thing, over [RestClient].
class ApiCatalogRepository implements CatalogRepository {
  ApiCatalogRepository(this._client);

  final RestClient _client;

  /// Only numeric ids exist on the server.
  static int? numericId(String id) => int.tryParse(id.trim());

  Future<T?> _get<T>(
    String path,
    T Function(Object? data) parse,
  ) async {
    try {
      final response = await _client.dio.get<Object?>(path);
      return parse(response.data);
    } on DioException catch (e) {
      debugPrint('GET $path failed: ${e.response?.statusCode ?? e.type}');
      return null;
    } on Object catch (e) {
      // A malformed payload must not crash the screen.
      debugPrint('GET $path returned an unexpected body: $e');
      return null;
    }
  }

  @override
  Future<HomeFeed?> homeFeed() => _get(
        '/home',
        (data) => HomeFeed.fromJson(data! as Map<String, dynamic>),
      );

  @override
  Future<CatalogCourse?> course(String id) async {
    final n = numericId(id);
    if (n == null) return null;
    return _get(
      '/courses/$n',
      (data) => CatalogCourse.fromJson(data! as Map<String, dynamic>),
    );
  }

  @override
  Future<List<CatalogSection>?> curriculum(String courseId) async {
    final n = numericId(courseId);
    if (n == null) return null;
    return _get(
      '/courses/$n/curriculum',
      (data) => (data! as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(CatalogSection.fromJson)
          .toList(),
    );
  }

  @override
  Future<LessonDetail?> lesson(String id) async {
    final n = numericId(id);
    if (n == null) return null;
    return _get(
      '/lessons/$n',
      (data) => LessonDetail.fromJson(data! as Map<String, dynamic>),
    );
  }

  @override
  Future<bool> saveProgress(
    String lessonId, {
    required int watchedSeconds,
    required String status,
  }) async {
    final n = numericId(lessonId);
    if (n == null) return false;
    try {
      await _client.dio.post<Object?>(
        '/lessons/$n/progress',
        data: {'watched_seconds': watchedSeconds, 'status': status},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('progress for lesson $n failed: ${e.response?.statusCode}');
      return false;
    }
  }
}

/// Offline stand-in used with `USE_MOCK_AUTH` and in tests: nothing is ever
/// available, so every screen shows its bundled sample content.
class OfflineCatalogRepository implements CatalogRepository {
  const OfflineCatalogRepository();

  @override
  Future<HomeFeed?> homeFeed() async => null;

  @override
  Future<CatalogCourse?> course(String id) async => null;

  @override
  Future<List<CatalogSection>?> curriculum(String courseId) async => null;

  @override
  Future<LessonDetail?> lesson(String id) async => null;

  @override
  Future<bool> saveProgress(
    String lessonId, {
    required int watchedSeconds,
    required String status,
  }) async =>
      false;
}
