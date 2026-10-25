import 'package:ab_learning_app/core/di/app_dependencies.dart';
import 'package:ab_learning_app/core/network/api_exception.dart';
import 'package:ab_learning_app/features/checkout/presentation/checkout_screen.dart';
import 'package:ab_learning_app/features/community/presentation/community_screen.dart';
import 'package:ab_learning_app/features/explore/presentation/explore_screen.dart';
import 'package:ab_learning_app/features/profile/presentation/certificates_screen.dart';
import 'package:ab_learning_app/features/profile/presentation/edit_profile_screen.dart';
import 'package:ab_learning_app/features/profile/presentation/help_center_screen.dart';
import 'package:ab_learning_app/features/profile/presentation/portfolio_screen.dart';
import 'package:ab_learning_app/features/profile/presentation/settings_screen.dart';
import 'package:ab_learning_app/features/profile/presentation/wallet_screen.dart';
import 'package:ab_learning_app/features/tutor/data/tutor_repository.dart';
import 'package:ab_learning_app/features/tutor/presentation/ai_tutor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_helpers.dart';

Widget _app(String initial) {
  Widget stub(String name) => Scaffold(body: Text(name));
  return MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(path: '/checkout/:id', builder: (_, s) {
          return CheckoutScreen(courseId: s.pathParameters['id'] ?? '');
        }),
        GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
        GoRoute(path: '/tutor', builder: (_, __) => const AiTutorScreen()),
        GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
        GoRoute(
          path: '/certificates',
          builder: (_, __) => const CertificatesScreen(),
        ),
        GoRoute(path: '/portfolio', builder: (_, __) => const PortfolioScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/help', builder: (_, __) => const HelpCenterScreen()),
        GoRoute(
          path: '/profile/edit',
          builder: (_, __) => const EditProfileScreen(),
        ),
        GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
        GoRoute(path: '/learn', builder: (_, __) => stub('LEARN PAGE')),
        GoRoute(path: '/home', builder: (_, __) => stub('HOME PAGE')),
        GoRoute(path: '/profile', builder: (_, __) => stub('PROFILE PAGE')),
        GoRoute(path: '/course/:id', builder: (_, __) => stub('COURSE PAGE')),
        GoRoute(path: '/search', builder: (_, __) => stub('SEARCH PAGE')),
      ],
    ),
  );
}

void main() {
  installMockAuth();

  setUp(() {
    AppDependencies.tutorRepository =
        MockTutorRepository(latency: Duration.zero);
  });

  group('static sub pages render their title', () {
    const pages = <String, String>{
      '/wallet': 'Wallet',
      '/certificates': 'Certificates',
      '/portfolio': 'Portfolio',
      '/settings': 'Settings',
      '/help': 'Help Center',
      '/profile/edit': 'Edit Profile',
    };
    pages.forEach((route, title) {
      testWidgets(route, (tester) async {
        useViewport(tester, mobileSize);
        await tester.pumpWidget(_app(route));
        await tester.pumpAndSettle();
        expect(find.text(title), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    });
  });

  testWidgets('settings switches toggle in memory', (tester) async {
    useViewport(tester, mobileSize);
    await tester.pumpWidget(_app('/settings'));
    await tester.pumpAndSettle();

    final first = find.byType(Switch).first;
    final before = tester.widget<Switch>(first).value;
    await tester.tap(first);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(first).value, !before);
  });

  testWidgets('community feed renders posts', (tester) async {
    useViewport(tester, mobileSize);
    await tester.pumpWidget(_app('/community'));
    await tester.pumpAndSettle();
    expect(find.text('Community'), findsWidgets);
    expect(find.textContaining('Prompt Engineering'), findsOneWidget);
  });

  group('checkout', () {
    testWidgets('shows the order and completes a test-mode payment',
        (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app('/checkout/unknown-course'));
      await tester.pumpAndSettle();

      expect(find.text('รายการสั่งซื้อ'), findsOneWidget);
      expect(find.text('PromptPay'), findsOneWidget);

      await tester.tap(find.text('บัตรเครดิต / เดบิต'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('ยืนยันชำระเงิน'));
      await tester.pumpAndSettle();

      expect(find.textContaining('โหมดทดสอบ'), findsOneWidget);
      await tester.tap(find.text('ไปที่ My Learning'));
      await tester.pumpAndSettle();
      expect(find.text('LEARN PAGE'), findsOneWidget);
    });
  });

  group('AI tutor', () {
    testWidgets('sends a typed question and shows the reply', (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app('/tutor'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Goroutine คืออะไร');
      await tester.tap(find.byTooltip('ส่ง'));
      await tester.pumpAndSettle();

      expect(find.text('Goroutine คืออะไร'), findsOneWidget);
      expect(find.textContaining('โหมดทดสอบ'), findsOneWidget);
    });

    testWidgets('ignores an empty message', (tester) async {
      useViewport(tester, mobileSize);
      await tester.pumpWidget(_app('/tutor'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('ส่ง'));
      await tester.pumpAndSettle();
      expect(find.textContaining('โหมดทดสอบ'), findsNothing);
    });

    testWidgets('shows the error when the repository fails', (tester) async {
      useViewport(tester, mobileSize);
      AppDependencies.tutorRepository = _FailingTutor();
      await tester.pumpWidget(_app('/tutor'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ทดสอบ');
      await tester.tap(find.byTooltip('ส่ง'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ล้มเหลวทดสอบ'), findsOneWidget);
    });
  });

  testWidgets('explore filter sheet opens and applies', (tester) async {
    useViewport(tester, mobileSize);
    await tester.pumpWidget(_app('/explore'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('☰'));
    await tester.pumpAndSettle();
    expect(find.text('ตัวกรอง'), findsOneWidget);

    await tester.tap(find.text('4.8 ★ ขึ้นไป'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ใช้ตัวกรอง'));
    await tester.pumpAndSettle();

    expect(find.text('ตัวกรอง'), findsNothing);
    expect(find.text('☰ •'), findsOneWidget);
  });
}

class _FailingTutor implements TutorRepository {
  @override
  Future<String> ask(String message, {String? action}) async {
    throw const ApiException('ล้มเหลวทดสอบ');
  }
}
