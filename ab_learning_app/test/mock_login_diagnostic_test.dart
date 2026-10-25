import 'package:flutter_test/flutter_test.dart';
import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'helpers/test_helpers.dart';

void main() {
  installMockAuth();

  test('mock login completes', () async {
    print('CHECK 1: starting login');

    final repository = AppDependencies.authRepository;
    final session = await repository.login(
      identifier: 'real@user.test',
      password: 'pw',
    );

    print('CHECK 2: login completed');
    expect(session.user?.email, 'real@user.test');
    expect(await repository.hasSession(), isTrue);
    print('CHECK 3: session verified');
  });
}

