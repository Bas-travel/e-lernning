import 'package:ab_learning_app/core/network/rest_exception.dart';
import 'package:ab_learning_app/features/auth/data/account_repository.dart';
import 'package:ab_learning_app/features/auth/presentation/login_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _RejectingRepository extends MockAccountRepository {
  _RejectingRepository(this.error) : super(latency: Duration.zero);

  final Object error;

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
    bool remember = true,
  }) async {
    throw error;
  }
}

void main() {
  test('rejects empty credentials without calling the repository', () async {
    final controller = LoginController(
      repository: _RejectingRepository(StateError('must not be called')),
    );
    expect(await controller.login(identifier: ' ', password: ''), isFalse);
    expect(controller.errorMessage, isNotNull);
    expect(controller.isLoading, isFalse);
  });

  test('succeeds with valid input and toggles loading', () async {
    final controller = LoginController(
      repository: MockAccountRepository(latency: Duration.zero),
    );
    final states = <bool>[];
    controller.addListener(() => states.add(controller.isLoading));

    expect(await controller.login(identifier: 'a@b.c', password: 'pw'), isTrue);
    expect(controller.errorMessage, isNull);
    expect(states, [true, false]);
  });

  test('exposes RestException messages', () async {
    final controller = LoginController(
      repository: _RejectingRepository(const RestException('รหัสผิด')),
    );
    expect(await controller.login(identifier: 'a@b.c', password: 'x'), isFalse);
    expect(controller.errorMessage, 'รหัสผิด');

    controller.clearError();
    expect(controller.errorMessage, isNull);
  });

  test('hides unexpected errors behind a generic message', () async {
    final controller = LoginController(
      repository: _RejectingRepository(StateError('boom')),
    );
    expect(await controller.login(identifier: 'a@b.c', password: 'x'), isFalse);
    expect(controller.errorMessage, isNot(contains('boom')));
  });
}
