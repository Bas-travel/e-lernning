import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// `POST /ai/tutor` ({message, action?} -> {reply, conversation_id}).
abstract class TutorRepository {
  Future<String> ask(String message, {String? action});
}

class ApiTutorRepository implements TutorRepository {
  ApiTutorRepository(this._client);

  final ApiClient _client;

  @override
  Future<String> ask(String message, {String? action}) async {
    try {
      final response = await _client.dio.post<dynamic>(
        '/ai/tutor',
        data: {'message': message, if (action != null) 'action': action},
      );
      final data = response.data;
      final reply = data is Map ? data['reply'] : null;
      if (reply is String && reply.isNotEmpty) return reply;
      throw const ApiException('ไม่ได้รับคำตอบจากเซิร์ฟเวอร์');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

/// Offline stand-in used with `USE_MOCK_AUTH` and in tests.
class MockTutorRepository implements TutorRepository {
  MockTutorRepository({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  @override
  Future<String> ask(String message, {String? action}) async {
    await Future<void>.delayed(latency);
    return 'นี่คือคำตอบตัวอย่างสำหรับ "$message" (โหมดทดสอบ ยังไม่ได้เชื่อมต่อ AI)';
  }
}
