import 'package:ab_learning_app/features/auth/presentation/login_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/register_screen.dart';
import 'package:ab_learning_app/features/auth/data/auth_repository.dart';
import 'package:ab_learning_app/core/storage/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

AuthRepository _testAuthRepository() =>
    AuthRepository(tokenStorage: _MemoryTokenStorage());

GoRouter _authRouter() => GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
            path: '/login',
            builder: (_, __) =>
                LoginScreen(authRepository: _testAuthRepository())),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('Learner Home'))),
        GoRoute(
            path: '/instructor',
            builder: (_, __) => const Scaffold(body: Text('Instructor Home'))),
        GoRoute(
            path: '/corporate',
            builder: (_, __) => const Scaffold(body: Text('Corporate Home'))),
        GoRoute(
            path: '/employer',
            builder: (_, __) => const Scaffold(body: Text('Employer Home'))),
        GoRoute(
            path: '/admin',
            builder: (_, __) => const Scaffold(body: Text('Admin Home'))),
      ],
    );

void main() {
  testWidgets(
      'login shows validated form and reaches the selected learner route',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _authRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('ยินดีต้อนรับกลับ'), findsOneWidget);
    expect(find.text('อีเมล'), findsOneWidget);
    expect(find.text('รหัสผ่าน'), findsOneWidget);
    expect(find.text('ทดลองใช้งาน'), findsOneWidget);
    expect(find.text('สมัครสมาชิก'), findsOneWidget);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('กรุณากรอกอีเมล'), findsOneWidget);
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);

    await tester.ensureVisible(find.text('เติมให้'));
    await tester.tap(find.text('เติมให้'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Learner Home'), findsOneWidget);
  });

  testWidgets(
      'login displays an authentication error for incorrect credentials',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _authRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('login-email')), 'learner@ablearning.com');
    await tester.enterText(
        find.byKey(const Key('login-password')), 'incorrect-password');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('อีเมลหรือรหัสผ่านไม่ถูกต้อง'), findsOneWidget);
    expect(find.text('Learner Home'), findsNothing);
  });

  testWidgets('register validates fields and the new account can log in',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _authRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('สมัครสมาชิก'));
    await tester.tap(find.text('สมัครสมาชิก'));
    await tester.pumpAndSettle();

    expect(find.text('สร้างบัญชีใหม่'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();
    expect(find.text('กรอกชื่อ'), findsOneWidget);
    expect(find.text('กรอกนามสกุล'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('register-first-name')), 'Mali');
    await tester.enterText(find.byKey(const Key('register-last-name')), 'Dee');
    await tester.enterText(
        find.byKey(const Key('register-email')), 'mali.dee@example.com');
    await tester.enterText(
        find.byKey(const Key('register-password')), 'Learning123');
    await tester.enterText(
        find.byKey(const Key('register-confirm-password')), 'Learning123');
    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();

    expect(find.text('สร้างบัญชีเรียบร้อย'), findsOneWidget);
    await tester.tap(find.text('ไปหน้าเข้าสู่ระบบ'));
    await tester.pumpAndSettle();
    expect(find.text('ยินดีต้อนรับกลับ'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('login-email')), 'mali.dee@example.com');
    await tester.enterText(
        find.byKey(const Key('login-password')), 'Learning123');
    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Learner Home'), findsOneWidget);
  });

  testWidgets('registration explains when an email is already in use',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _authRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('สมัครสมาชิก'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('register-first-name')), 'Anan');
    await tester.enterText(
        find.byKey(const Key('register-last-name')), 'Example');
    await tester.enterText(
        find.byKey(const Key('register-email')), 'learner@ablearning.com');
    await tester.enterText(
        find.byKey(const Key('register-password')), 'Learning123');
    await tester.enterText(
        find.byKey(const Key('register-confirm-password')), 'Learning123');
    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();

    expect(find.text('อีเมลนี้มีบัญชีแล้ว กรุณาเข้าสู่ระบบ'), findsOneWidget);
  });
}

class _MemoryTokenStorage extends TokenStorage {
  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {}
}
