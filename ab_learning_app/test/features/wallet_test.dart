import 'dart:typed_data';

import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/core/format/baht.dart';
import 'package:ab_learning_app/core/network/rest_client.dart';
import 'package:ab_learning_app/core/network/token_store.dart';
import 'package:ab_learning_app/features/profile/presentation/wallet_screen.dart';
import 'package:ab_learning_app/features/wallet/data/wallet_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

class _FakeWallet implements WalletRepository {
  _FakeWallet({this.failLoads = 0, this.failTopups = 0});

  int failLoads;
  int failTopups;
  double balance = 100;
  final List<String> keys = [];

  @override
  bool get bundledOnly => false;

  @override
  Future<WalletSnapshot> load() async {
    if (failLoads > 0) {
      failLoads--;
      throw Exception('offline');
    }
    return WalletSnapshot(
      balance: balance,
      entries: const [
        WalletEntry(
          title: 'เติมเงิน (ทดสอบ)',
          date: '1 ม.ค. 2026',
          amount: 100,
        ),
      ],
    );
  }

  @override
  Future<bool> topup(int baht, {required String idempotencyKey}) async {
    keys.add(idempotencyKey);
    if (failTopups > 0) {
      failTopups--;
      return false;
    }
    balance += baht;
    return true;
  }
}

Future<void> _pump(WidgetTester tester) async {
  useViewport(tester, mobileSize);
  await tester.pumpWidget(const MaterialApp(home: WalletScreen()));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(AppDependencies.reset);

  test('formatBahtExact keeps zero, satang and the sign', () {
    expect(formatBahtExact(0), '฿0');
    expect(formatBahtExact(1250), '฿1,250');
    expect(formatBahtExact(1250.5), '฿1,250.50');
    expect(formatBahtExact(-40), '-฿40');
    expect(formatBahtExact(1234567.05), '฿1,234,567.05');
  });

  test('ledger rows get a Thai title and the right sign', () {
    final spent = entryFromJson({
      'type': 'purchase',
      'amount': 1490,
      'created_at': '2026-10-10T08:00:00Z',
    });
    expect(spent.amount, -1490);
    expect(spent.title, 'ซื้อคอร์ส');
    final topup = entryFromJson({'type': 'topup', 'amount': 20.5});
    expect(topup.amount, 20.5);
    expect(topup.date, '');
  });

  test('ApiWalletRepository reads balance and ledger, sends the key', () async {
    final adapter = _FakeAdapter((o) {
      if (o.path == '/wallet') {
        return _json('{"coin_balance":0,"cash_balance":110.5}');
      }
      if (o.path == '/wallet/transactions') {
        return _json(
          '{"items":[{"id":1,"type":"topup","amount":110.5,'
          '"balance_after":110.5,"created_at":"2026-11-23T10:00:00Z"}]}',
        );
      }
      return _json('{"applied":true}', 201);
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
      ..httpClientAdapter = adapter;
    final repo = ApiWalletRepository(
      RestClient(tokenStore: MemoryTokenStore(), dio: dio),
    );

    final snap = await repo.load();
    expect(snap.balance, 110.5);
    expect(snap.entries.single.amount, 110.5);

    expect(await repo.topup(500, idempotencyKey: 'wal-key-1'), isTrue);
    final post = adapter.requests.last;
    expect(post.path, '/wallet/sandbox/topup');
    expect(post.headers['Idempotency-Key'], 'wal-key-1');
    expect(post.data, {'amount': 500});
  });

  testWidgets('shows balance, ledger and top-up buttons', (tester) async {
    AppDependencies.walletRepository = _FakeWallet();
    await _pump(tester);
    expect(find.text('฿100'), findsWidgets);
    expect(find.text('เติมเงิน (ทดสอบ)'), findsOneWidget);
    expect(find.text('+฿500'), findsOneWidget);
  });

  testWidgets('a zero balance reads ฿0, not "free"', (tester) async {
    final repo = _FakeWallet()..balance = 0;
    AppDependencies.walletRepository = repo;
    await _pump(tester);
    expect(find.text('฿0'), findsOneWidget);
    expect(find.text('ฟรี'), findsNothing);
  });

  testWidgets('error state has a working retry', (tester) async {
    AppDependencies.walletRepository = _FakeWallet(failLoads: 1);
    await _pump(tester);
    expect(find.text('โหลดข้อมูล Wallet ไม่สำเร็จ'), findsOneWidget);
    await tester.tap(find.text('ลองใหม่'));
    await tester.pumpAndSettle();
    expect(find.text('เติมเงิน (ทดสอบ)'), findsOneWidget);
  });

  testWidgets('a failed top-up is retried with the same key', (tester) async {
    final repo = _FakeWallet(failTopups: 1);
    AppDependencies.walletRepository = repo;
    await _pump(tester);

    await tester.tap(find.text('+฿500'));
    await tester.pumpAndSettle();
    expect(find.text('เติมเงินไม่สำเร็จ ลองอีกครั้ง'), findsOneWidget);

    await tester.tap(find.text('+฿500'));
    await tester.pumpAndSettle();
    expect(repo.keys.length, 2);
    expect(repo.keys[0], repo.keys[1]);
    expect(find.text('฿600'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, '+฿100'));
    await tester.pumpAndSettle();
    expect(repo.keys[2], isNot(repo.keys[1]));
  });
}
