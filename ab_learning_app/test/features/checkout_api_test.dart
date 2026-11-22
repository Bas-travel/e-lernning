import 'dart:convert';
import 'dart:typed_data';

import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/core/network/rest_client.dart';
import 'package:ab_learning_app/core/network/token_store.dart';
import 'package:ab_learning_app/features/catalog/data/catalog_models.dart';
import 'package:ab_learning_app/features/catalog/data/catalog_repository.dart';
import 'package:ab_learning_app/features/checkout/data/orders_repository.dart';
import 'package:ab_learning_app/features/course/presentation/payment_screen.dart';
import 'package:ab_learning_app/features/home/models/home_feed.dart';
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

({ApiOrdersRepository repo, _FakeAdapter adapter}) _setup(
  ResponseBody Function(RequestOptions) handler,
) {
  final adapter = _FakeAdapter(handler);
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = adapter;
  final client = RestClient(tokenStore: MemoryTokenStore(), dio: dio);
  return (repo: ApiOrdersRepository(client), adapter: adapter);
}

class _FakeCatalog implements CatalogRepository {
  @override
  bool get bundledOnly => false;

  @override
  Future<HomeFeed?> homeFeed() async => null;

  @override
  Future<CatalogCourse?> course(String id) async => id == '7'
      ? const CatalogCourse(
          id: 7,
          title: 'Server Course',
          price: 1500,
          discountPrice: 1000,
          instructorName: 'Dr. Krit',
        )
      : null;

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

class _FakeOrders implements OrdersRepository {
  _FakeOrders(this.result);

  CheckoutResult result;
  final calls = <String>[];

  @override
  bool get bundledOnly => false;

  @override
  Future<CheckoutResult> payForCourse(
    int courseId, {
    required String method,
    required String idempotencyKey,
  }) async {
    calls.add('$courseId:$method:$idempotencyKey');
    return result;
  }
}

Widget _app() => MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/checkout/7',
        routes: [
          GoRoute(
            path: '/checkout/:id',
            builder: (_, s) =>
                PaymentScreen(courseId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: '/course/:id/curriculum',
            builder: (_, __) => const Scaffold(body: Text('CURRICULUM')),
          ),
        ],
      ),
    );

void main() {
  group('ApiOrdersRepository', () {
    test('creates the order, then completes the sandbox payment', () async {
      final t = _setup((o) {
        if (o.path == '/checkout') {
          return _json(
              '{"order_code":"ORD-1","status":"pending","grand_total":1000}',
              201);
        }
        return _json(
            '{"order_code":"ORD-1","status":"paid","grand_total":1000}');
      });

      final r = await t.repo.payForCourse(
        7,
        method: 'card',
        idempotencyKey: 'key-12345678',
      );

      expect(r.order!.isPaid, isTrue);
      expect(r.order!.code, 'ORD-1');
      expect(t.adapter.requests.map((o) => o.path), [
        '/checkout',
        '/payments/sandbox/ORD-1/complete',
      ]);
      final first = t.adapter.requests.first;
      expect(first.headers['Idempotency-Key'], 'key-12345678');
      expect(first.data, {
        'course_ids': [7],
        'method': 'card',
      });
      expect(jsonEncode(t.adapter.requests.last.data), '{"result":"success"}');
    });

    test('a free course is paid at once and needs no second call', () async {
      final t = _setup(
        (_) => _json('{"order_code":"ORD-2","status":"paid","grand_total":0}'),
      );
      final r = await t.repo.payForCourse(
        3,
        method: 'promptpay',
        idempotencyKey: 'key-free-0001',
      );
      expect(r.order!.isPaid, isTrue);
      expect(t.adapter.requests, hasLength(1));
    });

    test('maps HTTP errors to a failure', () async {
      Future<CheckoutFailure?> failure(int status) async {
        final t = _setup((_) => _json('{"message":"x"}', status));
        final r = await t.repo.payForCourse(
          7,
          method: 'card',
          idempotencyKey: 'key-12345678',
        );
        return r.failure;
      }

      expect(await failure(409), CheckoutFailure.alreadyOwned);
      expect(await failure(422), CheckoutFailure.unavailable);
      expect(await failure(500), CheckoutFailure.failed);
    });
  });

  group('PaymentScreen with the API', () {
    late _FakeOrders orders;

    setUp(() {
      AppDependencies.catalogRepository = _FakeCatalog();
      orders = _FakeOrders(
        const CheckoutResult.success(
          PaidOrder(code: 'ORD-TEST-1', status: 'paid', total: 1000),
        ),
      );
      AppDependencies.ordersRepository = orders;
    });
    tearDown(AppDependencies.reset);

    testWidgets('shows the server price and only supported methods',
        (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Server Course'), findsOneWidget);
      expect(find.textContaining('ชำระเงิน ฿1,000'), findsOneWidget);
      expect(find.text('พร้อมเพย์'), findsOneWidget);
      expect(find.text('โมบายแบงก์กิ้ง'), findsNothing);
      expect(find.text('AB Wallet'), findsNothing);
    });

    testWidgets('paying creates one order and shows its code', (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('ชำระเงิน ฿1,000'));
      await tester.pumpAndSettle();

      expect(orders.calls, hasLength(1));
      expect(orders.calls.single, startsWith('7:promptpay:app-'));
      expect(find.text('ชำระเงินสำเร็จ'), findsOneWidget);
      expect(find.textContaining('ORD-TEST-1'), findsOneWidget);

      await tester.tap(find.text('เริ่มเรียนเลย'));
      await tester.pumpAndSettle();
      expect(find.text('CURRICULUM'), findsOneWidget);
    });

    testWidgets('a refused payment tells the learner and stays put',
        (tester) async {
      orders.result = const CheckoutResult.failure(CheckoutFailure.failed);
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('ชำระเงิน ฿1,000'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('ชำระเงินไม่สำเร็จ กรุณาลองใหม่อีกครั้ง'),
          findsOneWidget);
      expect(find.text('ชำระเงินสำเร็จ'), findsNothing);
      expect(find.text('CURRICULUM'), findsNothing);
    });

    testWidgets('owning the course already goes straight to it',
        (tester) async {
      orders.result =
          const CheckoutResult.failure(CheckoutFailure.alreadyOwned);
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('ชำระเงิน ฿1,000'));
      await tester.pumpAndSettle();

      expect(find.text('CURRICULUM'), findsOneWidget);
    });
  });
}
