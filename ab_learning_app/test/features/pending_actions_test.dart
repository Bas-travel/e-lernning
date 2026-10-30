import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/features/auth/data/account_repository.dart';
import 'package:ab_learning_app/features/auth/presentation/hifi_login_screen.dart';
import 'package:ab_learning_app/features/auth/presentation/otp_screen.dart';
import 'package:ab_learning_app/features/course/presentation/hifi_video_player_screen.dart';
import 'package:ab_learning_app/features/profile/presentation/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_helpers.dart';

/// A server that has no resend endpoint (the current Go API).
class _NoResendRepository extends MockAccountRepository {
  _NoResendRepository() : super(latency: Duration.zero);

  @override
  Future<bool> resendOtp({required int userId}) async => false;
}

Widget _router(String initial) {
  Widget stub(String name) => Scaffold(body: Text(name));
  return MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const HifiLoginScreen()),
        GoRoute(
          path: '/profile/edit',
          builder: (_, __) => const EditProfileScreen(),
        ),
        GoRoute(path: '/profile', builder: (_, __) => stub('PROFILE PAGE')),
        GoRoute(
          path: '/otp',
          builder: (_, s) => OtpScreen(args: s.extra as OtpArgs?),
        ),
        GoRoute(
          path: '/player/:id',
          builder: (_, s) => HifiVideoPlayerScreen(
            lessonId: s.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/quiz/:id',
          builder: (_, s) => stub('QUIZ ${s.pathParameters['id']}'),
        ),
        GoRoute(path: '/learn', builder: (_, __) => stub('LEARN PAGE')),
        GoRoute(path: '/home', builder: (_, __) => stub('HOME PAGE')),
        GoRoute(path: '/forgot-password', builder: (_, __) => stub('FORGOT')),
        GoRoute(path: '/register', builder: (_, __) => stub('REGISTER')),
      ],
    ),
  );
}

void main() {
  installMockAuth();

  group('Edit Profile', () {
    testWidgets('saves the new name through the repository', (tester) async {
      useViewport(tester, mobileSize);
      final repo = AppDependencies.authRepository;

      final loginFuture = repo.login(
        identifier: 'anan@example.com',
        password: 'pw',
      );

      await tester.pump(const Duration(milliseconds: 300));
      await loginFuture;

      await tester.pumpWidget(_router('/profile/edit'));
      await tester.pumpAndSettle();

      // Nothing changed yet: saving does nothing.
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();
      expect(find.text('บันทึกโปรไฟล์แล้ว'), findsNothing);

      await tester.enterText(find.byType(TextField).at(0), 'Anan');
      await tester.enterText(find.byType(TextField).at(1), 'Suksawat');
      await tester.pump();
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(repo.currentUser?.displayName, 'Anan Suksawat');
      expect(find.text('บันทึกโปรไฟล์แล้ว'), findsOneWidget);
      expect(find.text('PROFILE PAGE'), findsOneWidget);
    });

    testWidgets('asks the user to sign in when there is no session',
        (tester) async {
      useViewport(tester, mobileSize);

      await tester.pumpWidget(_router('/profile/edit'));
      await tester.pumpAndSettle();
      expect(find.textContaining('กรุณาเข้าสู่ระบบ'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'Anan');
      await tester.enterText(find.byType(TextField).at(1), 'Suksawat');
      await tester.pump();
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();
      expect(find.text('บันทึกโปรไฟล์แล้ว'), findsNothing);
    });
  });

  group('OTP resend', () {
    testWidgets('requests a new code and restarts the countdown',
        (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(
        const MaterialApp(home: OtpScreen(args: OtpArgs(userId: 5))),
      );

      await tester.pump(const Duration(seconds: 60));
      expect(find.text('ส่งรหัสอีกครั้ง'), findsOneWidget);

      await tester.tap(find.text('ส่งรหัสอีกครั้ง'));

      // ปล่อยให้ async callback และการแสดง SnackBar ทำงาน
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ส่งรหัสใหม่แล้ว'), findsOneWidget);
      expect(find.text('ขอรหัสใหม่ได้ใน 01:00'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('says so when the server cannot resend', (tester) async {
      useViewport(tester, mobileSize);
      AppDependencies.authRepository = _NoResendRepository();
      await tester.pumpWidget(
        const MaterialApp(home: OtpScreen(args: OtpArgs(userId: 5))),
      );

      await tester.pump(const Duration(seconds: 60));
      await tester.tap(find.text('ส่งรหัสอีกครั้ง'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('ยังไม่เปิดให้ส่งรหัสซ้ำ'), findsOneWidget);
      expect(find.text('ส่งรหัสอีกครั้ง'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Video player', () {
    testWidgets('next lesson opens the following lesson', (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_router('/player/l3'));
      await tester.pumpAndSettle();

      expect(find.textContaining('บทเรียนถัดไป'), findsOneWidget);
      await tester.tap(find.textContaining('บทเรียนถัดไป'));
      await tester.pumpAndSettle();

      // l4 follows l3 and has no quiz, so it opens in the player, whose
      // "next" button now points at l5.
      expect(find.textContaining('Navigation & Routing'), findsWidgets);
    });

    testWidgets('the demo lesson continues with a real lesson', (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_router('/player/lesson1'));
      await tester.pumpAndSettle();

      expect(find.textContaining('JWT Authentication'), findsWidgets);
      await tester.tap(find.textContaining('บทเรียนถัดไป'));
      await tester.pumpAndSettle();
      expect(find.textContaining('บทเรียนถัดไป'), findsOneWidget);
    });
  });

  testWidgets('social sign-in buttons explain they are unavailable',
      (tester) async {
    useViewport(tester, mobileSize);
    await tester.pumpWidget(_router('/login'));
    await tester.pumpAndSettle();

    for (final provider in ['Google', 'Facebook', 'LINE']) {
      await tester.ensureVisible(find.text(provider));
      await tester.tap(find.text(provider));
      await tester.pump();
      expect(find.textContaining(provider), findsWidgets);
      expect(find.textContaining('ยังไม่เปิดให้บริการ'), findsOneWidget);
      ScaffoldMessenger.of(tester.element(find.byType(HifiLoginScreen)))
          .hideCurrentSnackBar();
      await tester.pumpAndSettle();
    }
  });
}
