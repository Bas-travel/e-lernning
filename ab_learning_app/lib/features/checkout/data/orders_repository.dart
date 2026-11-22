import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/rest_client.dart';

/// Why a purchase did not go through.
enum CheckoutFailure {
  /// The learner already owns the course (HTTP 409).
  alreadyOwned,

  /// The course cannot be bought, or the coupon was refused (HTTP 422).
  unavailable,

  /// Anything else: no connection, 5xx, an unexpected answer.
  failed,
}

class PaidOrder {
  const PaidOrder({required this.code, required this.status, this.total = 0});

  factory PaidOrder.fromJson(Map<String, dynamic> json) => PaidOrder(
        code: json['order_code'] as String? ?? '',
        status: json['status'] as String? ?? '',
        total: (json['grand_total'] as num?)?.toDouble() ?? 0,
      );

  final String code;
  final String status;
  final double total;

  bool get isPaid => status == 'paid';
}

/// Exactly one of [order] and [failure] is set.
class CheckoutResult {
  const CheckoutResult.success(PaidOrder this.order) : failure = null;
  const CheckoutResult.failure(CheckoutFailure this.failure) : order = null;

  final PaidOrder? order;
  final CheckoutFailure? failure;
}

/// Buying courses. `null`-style availability mirrors `CatalogRepository`: the
/// offline stand-in reports [bundledOnly] so screens keep their demo flow.
abstract class OrdersRepository {
  bool get bundledOnly;

  /// Creates the order and, while the gateway is the sandbox, completes the
  /// simulated payment. [idempotencyKey] makes a retry reuse the same order.
  Future<CheckoutResult> payForCourse(
    int courseId, {
    required String method,
    required String idempotencyKey,
  });
}

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this._client);

  final RestClient _client;

  @override
  bool get bundledOnly => false;

  @override
  Future<CheckoutResult> payForCourse(
    int courseId, {
    required String method,
    required String idempotencyKey,
  }) async {
    try {
      final created = await _client.dio.post<Map<String, dynamic>>(
        '/checkout',
        data: {
          'course_ids': [courseId],
          'method': method,
        },
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      var order = PaidOrder.fromJson(created.data ?? const {});
      if (order.status == 'pending') {
        // Sandbox gateway: simulate the customer paying. A real gateway
        // replaces this with a redirect and waits for the webhook.
        final done = await _client.dio.post<Map<String, dynamic>>(
          '/payments/sandbox/${order.code}/complete',
          data: {'result': 'success'},
        );
        order = PaidOrder.fromJson(done.data ?? const {});
      }
      return order.isPaid
          ? CheckoutResult.success(order)
          : const CheckoutResult.failure(CheckoutFailure.failed);
    } on DioException catch (e) {
      debugPrint('checkout failed: ${e.response?.statusCode ?? e.type}');
      switch (e.response?.statusCode) {
        case 409:
          return const CheckoutResult.failure(CheckoutFailure.alreadyOwned);
        case 422:
          return const CheckoutResult.failure(CheckoutFailure.unavailable);
        default:
          return const CheckoutResult.failure(CheckoutFailure.failed);
      }
    } on Object catch (e) {
      debugPrint('checkout returned an unexpected body: $e');
      return const CheckoutResult.failure(CheckoutFailure.failed);
    }
  }
}

/// Offline stand-in (`USE_MOCK_AUTH`, tests): the screen's demo flow runs.
class OfflineOrdersRepository implements OrdersRepository {
  const OfflineOrdersRepository();

  @override
  bool get bundledOnly => true;

  @override
  Future<CheckoutResult> payForCourse(
    int courseId, {
    required String method,
    required String idempotencyKey,
  }) async =>
      const CheckoutResult.failure(CheckoutFailure.failed);
}
