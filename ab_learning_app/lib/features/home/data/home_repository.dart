import '../../../core/network/api_client.dart';
import '../models/home_feed.dart';

/// Wraps [ApiClient] calls for screen 08 (Home).
class HomeRepository {
  HomeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// GET /api/v1/home
  Future<HomeFeed> getHomeFeed() async {
    final Map<String, dynamic> json = await _apiClient.getHome();
    return HomeFeed.fromJson(json);
  }
}
