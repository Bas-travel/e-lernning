import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const mobileSize = Size(375, 812);
const desktopSize = Size(1440, 900);

void useViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Replaces the real (network) auth repository with an instant in-memory one
/// for the current test file.
void installMockAuth() {
  setUp(() {
    AppDependencies.authRepository = MockAuthRepository(latency: Duration.zero);
  });
  tearDown(AppDependencies.reset);
}
