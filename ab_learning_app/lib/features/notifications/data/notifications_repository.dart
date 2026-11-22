import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/rest_client.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: (json['id'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      );

  final int id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification asRead() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        isRead: true,
        createdAt: createdAt,
      );
}

class NotificationPage {
  const NotificationPage({required this.items, required this.unread});

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      NotificationPage(
        items: [
          for (final raw in (json['items'] as List<dynamic>? ?? const []))
            if (raw is Map<String, dynamic>) AppNotification.fromJson(raw),
        ],
        unread: (json['unread'] as num?)?.toInt() ?? 0,
      );

  static const empty = NotificationPage(items: [], unread: 0);

  final List<AppNotification> items;
  final int unread;
}

/// The signed-in user's inbox. Methods throw on network/server errors so a
/// screen can show an error state with a retry button; [bundledOnly] marks
/// the offline stand-in.
abstract class NotificationsRepository {
  bool get bundledOnly;

  Future<NotificationPage> list({bool unreadOnly = false});

  /// Returns false when the server refused or could not be reached.
  Future<bool> markRead(int id);

  Future<bool> markAllRead();
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._client);

  final RestClient _client;

  @override
  bool get bundledOnly => false;

  @override
  Future<NotificationPage> list({bool unreadOnly = false}) async {
    final res = await _client.dio.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {'limit': 50, if (unreadOnly) 'unread': 'true'},
    );
    return NotificationPage.fromJson(res.data ?? const {});
  }

  @override
  Future<bool> markRead(int id) => _post('/notifications/$id/read');

  @override
  Future<bool> markAllRead() => _post('/notifications/read-all');

  Future<bool> _post(String path) async {
    try {
      await _client.dio.post<Object?>(path);
      return true;
    } on DioException catch (e) {
      debugPrint('POST $path failed: ${e.response?.statusCode ?? e.type}');
      return false;
    }
  }
}

/// Offline stand-in (`USE_MOCK_AUTH`, tests): an always-empty inbox.
class OfflineNotificationsRepository implements NotificationsRepository {
  const OfflineNotificationsRepository();

  @override
  bool get bundledOnly => true;

  @override
  Future<NotificationPage> list({bool unreadOnly = false}) async =>
      NotificationPage.empty;

  @override
  Future<bool> markRead(int id) async => true;

  @override
  Future<bool> markAllRead() async => true;
}
