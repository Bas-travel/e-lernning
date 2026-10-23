import 'package:ab_learning_app/app.dart';
import 'package:ab_learning_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/otp_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/register_screen.dart';
import 'package:ab_learning_app/features/explore/data/course_catalog_sample.dart';
import 'package:ab_learning_app/features/explore/presentation/explore_screen.dart';
import 'package:ab_learning_app/features/explore/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void _useMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('CourseCatalogSample.search', () {
    test('empty query returns everything', () {
      expect(
        CourseCatalogSample.search('  '),
        hasLength(CourseCatalogSample.searchable.length),
      );
    });

    test('matches case-insensitively', () {
      expect(CourseCatalogSample.search('flutter'), hasLength(3));
      expect(CourseCatalogSample.search('FLUTTER'), hasLength(3));
    });

    test('returns nothing for unknown terms', () {
      expect(CourseCatalogSample.search('zzz'), isEmpty);
    });
  });

  testWidgets('register -> otp -> interests -> home', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(const App());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsOneWidget);

    await tester.tap(find.text('Create Account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('ยืนยัน'), findsOneWidget);

    await tester.tap(find.text('ยืนยัน'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Start Learning'), findsOneWidget);

    await tester.tap(find.text('Start Learning'));
    await tester.pumpAndSettle();
    expect(find.textContaining('สวัสดี'), findsOneWidget);
  });

  testWidgets('login links open forgot password', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(const App());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Send Reset Link'), findsOneWidget);
  });

  testWidgets('register flags mismatching passwords', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(4), 'secret-1');
    await tester.enterText(fields.at(5), 'secret-2');
    await tester.pump();
    expect(find.text('รหัสผ่านไม่ตรงกัน'), findsOneWidget);

    await tester.enterText(fields.at(5), 'secret-1');
    await tester.pump();
    expect(find.text('รหัสผ่านไม่ตรงกัน'), findsNothing);
  });

  testWidgets('otp counts down from 01:00', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: OtpScreen()));
    expect(find.text('ขอรหัสใหม่ได้ใน 01:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('ขอรหัสใหม่ได้ใน 00:59'), findsOneWidget);

    // Dispose the tree so the periodic timer is cancelled before the test ends.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('forgot password shows the confirmation state', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    expect(find.text('ส่งลิงก์รีเซ็ตแล้ว'), findsOneWidget);
  });

  testWidgets('explore shows trending and all courses', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: ExploreScreen()));
    expect(find.text('กำลังมาแรง'), findsOneWidget);
    expect(find.text('คอร์สทั้งหมด'), findsOneWidget);

    await tester.tap(find.text('AI'));
    await tester.pump();
    expect(find.text('Home'), findsOneWidget); // bottom nav still present
  });

  testWidgets('search filters results as you type', (tester) async {
    _useMobileViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
    await tester.enterText(find.byType(TextField), 'flutter');
    await tester.pump();
    expect(find.text('ผลการค้นหา (3)'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('ผลการค้นหา (0)'), findsOneWidget);
  });
}
