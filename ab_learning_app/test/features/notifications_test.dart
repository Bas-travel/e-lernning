import 'dart:typed_data';

import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/core/network/rest_client.dart';
import 'package:ab_learning_app/core/network/token_store.dart';
import 'package:ab_learning_app/features/notifications/data/notifications_repository.dart';
import 'package:ab_learning_app/features/notifications/presentation/notification_bell.dart';
import 'package:ab_learning_app/features/notifications/presentation/notifications_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_helpers.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

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

ResponseBody _json(String body, [int status = 200]) => ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class _FakeRepo implements NotificationsRepository {
  _FakeRepo(this.page, {this.failFirst = false});

  NotificationPage page;
  bool failFirst;
  final List<String> calls = [];

  @override
  bool get bundledOnly => false;

  @override
  Future<NotificationPage> list({bool unreadOnly = false}) async {
    calls.add('list');
    if (failFirst) {
      failFirst = false;
      throw Exception('offline');
    }
    return page;
  }

  @override
  Future<bool> markRead(int id) async {
    calls.add('read:$id');
    return true;
  }

  @override
  Future<bool> markAllRead() async {
    calls.add('read-all');
    return true;
  }
}

const _two = NotificationPage(
  unread: 2,
  items: [
    AppNotification(
      id: 2,
      type: 'order_paid',
      title: 'ชำระเงินสำเร็จ',
      body: 'เริ่มเรียนได้ทันที',
      isRead: false,
    ),
    AppNotification(
      id: 1,
      type: 'order_failed',
      title: 'ชำระเงินไม่สำเร็จ',
      body: '',
      isRead: false,
    ),
  ],
);

Future<void> _pump(WidgetTester tester) async {
  useViewport(tester, mobileSize);
  await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(AppDependencies.reset);
  bellTests();

  group('ApiNotificationsRepository', () {
    test('parses the page and sends paging params', () async {
      final adapter = _FakeAdapter((o) => _json('''
{"items":[{"id":7,"type":"order_paid","title":"t","body":"b",
"is_read":false,"created_at":"2026-11-22T10:00:00Z"}],"unread":1,
"limit":50,"offset":0}'''));
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter;
      final repo = ApiNotificationsRepository(
        RestClient(tokenStore: MemoryTokenStore(), dio: dio),
      );

      final page = await repo.list(unreadOnly: true);

      expect(page.unread, 1);
      expect(page.items.single.id, 7);
      expect(page.items.single.createdAt, isNotNull);
      expect(adapter.requests.single.path, '/notifications');
      expect(adapter.requests.single.queryParameters['unread'], 'true');
    });

    test('markRead is false on a server error, true on success', () async {
      var status = 404;
      final adapter = _FakeAdapter((o) => _json('{"ok":true}', status));
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter;
      final repo = ApiNotificationsRepository(
        RestClient(tokenStore: MemoryTokenStore(), dio: dio),
      );

      expect(await repo.markRead(3), isFalse);
      status = 200;
      expect(await repo.markRead(3), isTrue);
      expect(adapter.requests.last.path, '/notifications/3/read');
    });
  });

  group('NotificationsScreen', () {
    testWidgets('shows the empty state', (tester) async {
      AppDependencies.notificationsRepository =
          _FakeRepo(NotificationPage.empty);
      await _pump(tester);
      expect(find.textContaining('ยังไม่มีการแจ้งเตือน'), findsOneWidget);
    });

    testWidgets('lists notifications and marks one read on tap',
        (tester) async {
      final repo = _FakeRepo(_two);
      AppDependencies.notificationsRepository = repo;
      await _pump(tester);

      expect(find.text('ชำระเงินสำเร็จ'), findsOneWidget);
      expect(find.text('อ่านทั้งหมด (2)'), findsOneWidget);

      await tester.tap(find.text('ชำระเงินสำเร็จ'));
      await tester.pumpAndSettle();

      expect(repo.calls, contains('read:2'));
      expect(find.text('อ่านทั้งหมด (1)'), findsOneWidget);
    });

    testWidgets('read all clears the unread counter', (tester) async {
      final repo = _FakeRepo(_two);
      AppDependencies.notificationsRepository = repo;
      await _pump(tester);

      await tester.tap(find.text('อ่านทั้งหมด (2)'));
      await tester.pumpAndSettle();

      expect(repo.calls, contains('read-all'));
      expect(find.textContaining('อ่านทั้งหมด'), findsNothing);
    });

    testWidgets('shows an error with a working retry', (tester) async {
      final repo = _FakeRepo(_two, failFirst: true);
      AppDependencies.notificationsRepository = repo;
      await _pump(tester);

      expect(find.text('โหลดการแจ้งเตือนไม่สำเร็จ'), findsOneWidget);
      await tester.tap(find.text('ลองใหม่'));
      await tester.pumpAndSettle();

      expect(find.text('ชำระเงินสำเร็จ'), findsOneWidget);
      expect(repo.calls.where((c) => c == 'list').length, 2);
    });
  });
}

class _CountingRepo extends _FakeRepo {
  _CountingRepo(super.page);

  int unreadCalls = 0;

  @override
  Future<NotificationPage> list({bool unreadOnly = false}) async {
    if (unreadOnly) unreadCalls++;
    return super.list(unreadOnly: unreadOnly);
  }
}

Widget _bellApp() => MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Center(child: NotificationBell())),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) =>
                const Scaffold(body: Text('inbox page')),
          ),
        ],
      ),
    );

void bellTests() {
  group('NotificationBell', () {
    testWidgets('shows the unread count', (tester) async {
      AppDependencies.notificationsRepository = _CountingRepo(_two);
      await tester.pumpWidget(_bellApp());
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows no badge when nothing is unread', (tester) async {
      AppDependencies.notificationsRepository =
          _CountingRepo(NotificationPage.empty);
      await tester.pumpWidget(_bellApp());
      await tester.pumpAndSettle();
      expect(find.text('0'), findsNothing);
    });

    testWidgets('tap opens the inbox and refreshes the count on return',
        (tester) async {
      final repo = _CountingRepo(_two);
      AppDependencies.notificationsRepository = repo;
      await tester.pumpWidget(_bellApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotificationBell));
      await tester.pumpAndSettle();
      expect(find.text('inbox page'), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      expect(repo.unreadCalls, 2);
    });
  });
}
