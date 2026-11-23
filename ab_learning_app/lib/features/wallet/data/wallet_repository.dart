import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/rest_client.dart';
import '../../profile/presentation/profile_sample_data.dart';

class WalletEntry {
  const WalletEntry({
    required this.title,
    required this.date,
    required this.amount,
  });

  final String title;
  final String date;

  /// Signed: negative = spent or withdrawn, positive = received.
  final double amount;
}

class WalletSnapshot {
  const WalletSnapshot({required this.balance, required this.entries});

  final double balance;
  final List<WalletEntry> entries;
}

const _months = <String>[
  'ม.ค.',
  'ก.พ.',
  'มี.ค.',
  'เม.ย.',
  'พ.ค.',
  'มิ.ย.',
  'ก.ค.',
  'ส.ค.',
  'ก.ย.',
  'ต.ค.',
  'พ.ย.',
  'ธ.ค.',
];

String thaiDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String _titleFor(String type) {
  switch (type) {
    case 'topup':
      return 'เติมเงิน (ทดสอบ)';
    case 'purchase':
      return 'ซื้อคอร์ส';
    case 'refund':
      return 'คืนเงิน';
    case 'reward':
      return 'โบนัส';
    case 'withdraw':
      return 'ถอนเงิน';
    default:
      return type;
  }
}

WalletEntry entryFromJson(Map<String, dynamic> json) {
  final type = json['type'] as String? ?? '';
  final raw = (json['amount'] as num?)?.toDouble() ?? 0;
  final spent = type == 'purchase' || type == 'withdraw';
  final created = DateTime.tryParse(json['created_at'] as String? ?? '');
  return WalletEntry(
    title: _titleFor(type),
    date: created == null ? '' : thaiDate(created.toLocal()),
    amount: spent ? -raw.abs() : raw.abs(),
  );
}

abstract class WalletRepository {
  bool get bundledOnly;

  /// Throws when the server cannot be reached, so the screen can offer a retry.
  Future<WalletSnapshot> load();

  /// Credits [baht] in the sandbox. Reuse the same [idempotencyKey] when
  /// retrying a failed request so the wallet is credited at most once.
  Future<bool> topup(int baht, {required String idempotencyKey});
}

String newWalletIdempotencyKey() {
  final r = Random.secure();
  final hex = List.generate(16, (_) => r.nextInt(16).toRadixString(16));
  return 'wal-${hex.join()}';
}

class ApiWalletRepository implements WalletRepository {
  ApiWalletRepository(this._client);

  final RestClient _client;

  @override
  bool get bundledOnly => false;

  @override
  Future<WalletSnapshot> load() async {
    final balance = await _client.dio.get<Map<String, dynamic>>('/wallet');
    final ledger = await _client.dio.get<Map<String, dynamic>>(
      '/wallet/transactions',
      queryParameters: {'limit': 50},
    );
    final items = (ledger.data?['items'] as List<dynamic>? ?? const []);
    return WalletSnapshot(
      balance: (balance.data?['cash_balance'] as num?)?.toDouble() ?? 0,
      entries: [
        for (final raw in items)
          if (raw is Map<String, dynamic>) entryFromJson(raw),
      ],
    );
  }

  @override
  Future<bool> topup(int baht, {required String idempotencyKey}) async {
    try {
      await _client.dio.post<Object?>(
        '/wallet/sandbox/topup',
        data: {'amount': baht},
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      return true;
    } on DioException catch (e) {
      debugPrint('wallet top-up failed: ${e.response?.statusCode ?? e.type}');
      return false;
    }
  }
}

/// Offline stand-in (`USE_MOCK_AUTH`, tests): the mockup's demo wallet.
class OfflineWalletRepository implements WalletRepository {
  const OfflineWalletRepository();

  @override
  bool get bundledOnly => true;

  @override
  Future<WalletSnapshot> load() async => WalletSnapshot(
        balance: ProfileSampleData.walletBalance.toDouble(),
        entries: [
          for (final t in ProfileSampleData.transactions)
            WalletEntry(
              title: t.title,
              date: t.date,
              amount: t.amount.toDouble(),
            ),
        ],
      );

  @override
  Future<bool> topup(int baht, {required String idempotencyKey}) async =>
      false;
}
