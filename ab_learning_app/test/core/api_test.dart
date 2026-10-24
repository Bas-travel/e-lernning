import 'dart:typed_data';

import 'package:ab_learning_app/core/network/api_client.dart';
import 'package:ab_learning_app/core/network/api_exception.dart';
import 'package:ab_learning_app/core/network/token_store.dart';
import 'package:ab_learning_app/features/auth/data/auth_repository.dart';
import 'package:ab_learning_app/features/auth/domain/auth_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  RequestOptions get last => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(String body, [int status = 200]) {
  return ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

({ApiAuthRepository repo, _FakeAdapter adapter, MemoryTokenStore tokens})
    _setup(ResponseBody Function(RequestOptions) handler) {
  final adapter = _FakeAdapter(handler);
  final tokens = MemoryTokenStore();
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = adapter;
  final client = ApiClient(tokenStore: tokens, dio: dio);
  return (repo: ApiAuthRepository(client), adapter: adapter, tokens: tokens);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiAuthRepository.login', () {
    test('parses the OpenAPI response and stores tokens', () async {
      final t = _setup(
        (_) => _json(
          '{"access_token":"acc","refresh_token":"ref",'
          '"user":{"id":7,"email":"x@y.z","first_name":"Xe","last_name":"Yo"}}',
        ),
      );

      final session = await t.repo.login(
        identifier: ' x@y.z ',
        password: 'pw',
      );

      expect(session.accessToken, 'acc');
      expect(session.user?.displayName, 'Xe Yo');
      expect(session.user?.initial, 'X');
      expect(await t.tokens.readAccessToken(), 'acc');
      expect(await t.tokens.readRefreshToken(), 'ref');
      expect(await t.repo.hasSession(), isTrue);
      expect(t.repo.currentUser?.id, 7);

      expect(t.adapter.last.path, '/auth/login');
      final body = t.adapter.last.data as Map;
      expect(body['identifier'], 'x@y.z');
      expect(body['email'], 'x@y.z'); // compatibility with the Go stub
      expect(body['password'], 'pw');
      expect(t.adapter.last.headers.containsKey('Authorization'), isFalse);
    });

    test('accepts the stub response shape {"token": ...}', () async {
      final t = _setup((_) => _json('{"token":"stub"}'));
      final session = await t.repo.login(
        identifier: '0812345678',
        password: 'pw',
      );
      expect(session.accessToken, 'stub');
      expect(session.user?.email, '0812345678');
      final body = t.adapter.last.data as Map;
      expect(body.containsKey('email'), isFalse); // phone number, not email
    });

    test('maps 401 to a friendly message and stores nothing', () async {
      final t = _setup((_) => _json('{"error":"invalid credentials"}', 401));
      await expectLater(
        t.repo.login(identifier: 'a@b.c', password: 'bad'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)
              .having((e) => e.message, 'message', contains('ไม่ถูกต้อง')),
        ),
      );
      expect(await t.repo.hasSession(), isFalse);
    });

    test('rejects a response without a token', () async {
      final t = _setup((_) => _json('{"user":{"email":"a@b.c"}}'));
      await expectLater(
        t.repo.login(identifier: 'a@b.c', password: 'pw'),
        throwsA(isA<ApiException>()),
      );
    });

    test('reports connection problems', () async {
      final t = _setup(
        (o) => throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        ),
      );
      await expectLater(
        t.repo.login(identifier: 'a@b.c', password: 'pw'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้'),
          ),
        ),
      );
    });

    test('persist=false is passed to the token store', () async {
      final t = _setup((_) => _json('{"access_token":"a"}'));
      await t.repo.login(identifier: 'a@b.c', password: 'pw', remember: false);
      expect(await t.tokens.readAccessToken(), 'a');
    });
  });

  group('ApiAuthRepository other endpoints', () {
    test('register posts the documented fields', () async {
      final t = _setup(
        (_) => _json('{"id":5,"email":"n@e.w","first_name":"N","last_name":"W"}', 201),
      );
      final user = await t.repo.register(
        firstName: ' N ',
        lastName: 'W',
        email: 'n@e.w',
        phone: '0812345678',
        password: 'pw',
      );
      expect(user.id, 5);
      expect(t.adapter.last.path, '/auth/register');
      final body = t.adapter.last.data as Map;
      expect(body['first_name'], 'N');
      expect(body['phone'], '0812345678');
    });

    test('register omits an empty phone and surfaces server messages', () async {
      final t = _setup((_) => _json('{"message":"email taken"}', 409));
      await expectLater(
        t.repo.register(
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.c',
          phone: '  ',
          password: 'pw',
        ),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'message', 'email taken'),
        ),
      );
      expect((t.adapter.last.data as Map).containsKey('phone'), isFalse);
    });

    test('verifyOtp and forgotPassword hit the right paths', () async {
      final t = _setup((_) => _json('{}'));
      await t.repo.verifyOtp(userId: 3, code: '123456');
      expect(t.adapter.last.path, '/auth/verify-otp');
      expect((t.adapter.last.data as Map)['user_id'], 3);

      await t.repo.forgotPassword(email: ' a@b.c ');
      expect(t.adapter.last.path, '/auth/forgot-password');
      expect((t.adapter.last.data as Map)['email'], 'a@b.c');
    });

    test('authenticated calls carry the bearer token', () async {
      final t = _setup((o) {
        if (o.path == '/auth/login') return _json('{"access_token":"acc"}');
        return _json('{"id":1,"email":"me@x.y","first_name":"Me"}');
      });
      await t.repo.login(identifier: 'me@x.y', password: 'pw');
      final user = await t.repo.fetchProfile();
      expect(user?.firstName, 'Me');
      expect(t.adapter.last.path, '/me');
      expect(t.adapter.last.headers['Authorization'], 'Bearer acc');

      await t.repo.savePreferences(
        interests: ['AI'],
        level: 'Beginner',
        goals: ['Get a Job', 'Upskill'],
      );
      final body = t.adapter.last.data as Map;
      expect(body['level'], 'beginner');
      expect(body['goal'], 'Get a Job');
    });

    test('fetchProfile signs out on 401 and tolerates offline', () async {
      var online = false;
      final t = _setup((o) {
        if (o.path == '/auth/login') return _json('{"access_token":"acc"}');
        if (online) return _json('{"error":"expired"}', 401);
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionTimeout,
        );
      });
      await t.repo.login(identifier: 'me@x.y', password: 'pw');

      // Offline: cached user is kept.
      expect((await t.repo.fetchProfile())?.email, 'me@x.y');
      expect(await t.repo.hasSession(), isTrue);

      // Token rejected: session is cleared.
      online = true;
      expect(await t.repo.fetchProfile(), isNull);
      expect(await t.repo.hasSession(), isFalse);
    });

    test('logout clears tokens and the cached user', () async {
      final t = _setup((_) => _json('{"access_token":"acc"}'));
      await t.repo.login(identifier: 'a@b.c', password: 'pw');
      await t.repo.logout();
      expect(t.repo.currentUser, isNull);
      expect(await t.tokens.readAccessToken(), isNull);
    });
  });

  group('ApiException.fromDio', () {
    DioException err(int? status, Object? data, [DioExceptionType? type]) {
      final options = RequestOptions(path: '/x');
      return DioException(
        requestOptions: options,
        type: type ?? DioExceptionType.badResponse,
        response: status == null
            ? null
            : Response<dynamic>(
                requestOptions: options,
                statusCode: status,
                data: data,
              ),
      );
    }

    test('prefers {message} then {error}, keeps code', () {
      final a = ApiException.fromDio(
        err(400, {'code': 'BAD', 'message': 'nope'}),
      );
      expect(a.message, 'nope');
      expect(a.code, 'BAD');
      expect(ApiException.fromDio(err(400, {'error': 'e'})).message, 'e');
    });

    test('falls back to status based messages', () {
      expect(ApiException.fromDio(err(404, null)).message, contains('404'));
      expect(ApiException.fromDio(err(401, null)).isUnauthorized, isTrue);
      expect(ApiException.fromDio(err(500, 'oops')).message, contains('500'));
    });
  });

  group('AuthUser', () {
    test('derives name and initial from available fields', () {
      const onlyEmail = AuthUserFixture.onlyEmail;
      expect(onlyEmail.displayName, 'a@b.c');
      expect(onlyEmail.initial, 'A');
    });
  });

  group('token stores', () {
    test('MemoryTokenStore round trip', () async {
      final store = MemoryTokenStore();
      await store.save(accessToken: 'a', refreshToken: 'r');
      expect(await store.readAccessToken(), 'a');
      await store.clear();
      expect(await store.readRefreshToken(), isNull);
    });

    test('PersistentTokenStore persists when asked', () async {
      SharedPreferences.setMockInitialValues({});
      await PersistentTokenStore().save(accessToken: 'a', refreshToken: 'r');

      final reopened = PersistentTokenStore();
      expect(await reopened.readAccessToken(), 'a');
      expect(await reopened.readRefreshToken(), 'r');

      await reopened.clear();
      expect(await PersistentTokenStore().readAccessToken(), isNull);
    });

    test('PersistentTokenStore keeps tokens in memory only when persist=false',
        () async {
      SharedPreferences.setMockInitialValues({});
      final store = PersistentTokenStore();
      await store.save(accessToken: 'a', persist: false);
      expect(await store.readAccessToken(), 'a');
      expect(await PersistentTokenStore().readAccessToken(), isNull);
    });
  });

  group('MockAuthRepository', () {
    test('login creates a session and logout ends it', () async {
      final repo = MockAuthRepository(latency: Duration.zero);
      expect(await repo.hasSession(), isFalse);
      final session = await repo.login(identifier: 'a@b.c', password: 'pw');
      expect(session.user?.email, 'a@b.c');
      expect(await repo.hasSession(), isTrue);
      expect((await repo.fetchProfile())?.email, 'a@b.c');
      await repo.logout();
      expect(await repo.hasSession(), isFalse);
    });

    test('other operations complete', () async {
      final repo = MockAuthRepository(latency: Duration.zero);
      final user = await repo.register(
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.c',
        password: 'pw',
      );
      expect(user.displayName, 'A B');
      await repo.verifyOtp(userId: 1, code: '123456');
      await repo.forgotPassword(email: 'a@b.c');
      await repo.savePreferences(interests: [], level: 'x', goals: []);
    });
  });
}

class AuthUserFixture {
  static const onlyEmail = AuthUser(email: 'a@b.c');
}
