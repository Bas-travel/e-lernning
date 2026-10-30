import 'package:ab_learning_app/core/widgets/main_shell.dart';
import 'package:ab_learning_app/data/mock/mock_repository.dart';
import 'package:ab_learning_app/features/course/presentation/course_detail_screen.dart';
import 'package:ab_learning_app/features/course/presentation/curriculum_screen.dart';
import 'package:ab_learning_app/features/course/presentation/payment_screen.dart';
import 'package:ab_learning_app/features/explore/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter createLearnerRouter({String initialLocation = '/home'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(initialIndex: 0),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const MainShell(initialIndex: 1),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => SearchScreen(
          initialQuery: Uri.parse(
                state.location,
              ).queryParameters['q'] ??
              '',
        ),
      ),
      GoRoute(
        path: '/learn',
        builder: (context, state) => const MainShell(initialIndex: 2),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const MainShell(initialIndex: 3),
      ),
      GoRoute(
        path: '/ai-tutor',
        builder: (context, state) => const MainShell(initialIndex: 4),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainShell(initialIndex: 5),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) =>
            CourseDetailScreen(courseId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'curriculum',
            builder: (context, state) =>
                CurriculumScreen(courseId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/checkout/:id',
        builder: (context, state) => PaymentScreen(
          courseId: state.pathParameters['id']!,
          courseTitle: state.extra as String?,
        ),
      ),
    ],
  );
}

void configureTestViewport(
  WidgetTester tester, {
  required Size size,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
}

void main() {
  testWidgets(
    'mobile learner shell shows Home sections and Explore search works',
    (tester) async {
      configureTestViewport(tester, size: const Size(390, 844));
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = createLearnerRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();

      expect(find.text('สวัสดี, คุณอนันต์ 👋'), findsOneWidget);
      expect(find.text('วันนี้อยากพัฒนาอะไร?'), findsOneWidget);
      expect(find.text('เรียนต่อ'), findsWidgets);
      expect(find.text('แนะนำสำหรับคุณ'), findsOneWidget);

      // Home uses a vertical SingleChildScrollView, not a ListView.
      final homeScroll = find
          .descendant(
            of: find.byType(Scaffold).first,
            matching: find.byType(SingleChildScrollView),
          )
          .first;

      await tester.drag(homeScroll, const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Live กำลังจะเริ่ม'), findsOneWidget);

      // Navigate to Explore.
      await tester.tap(find.text('Explore').first);
      await tester.pumpAndSettle();

      // Open the actual Search screen from Explore's read-only search field.
      final exploreSearch = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.readOnly &&
            widget.decoration?.hintText == 'ค้นหาคอร์ส, สกิล, อาจารย์...',
      );

      expect(exploreSearch, findsOneWidget);

      await tester.tap(exploreSearch);
      await tester.pumpAndSettle();

      // Search for a course that exists in the sample catalog.
      final searchField = find.byType(TextField).first;
      expect(searchField, findsOneWidget);

      await tester.enterText(
        searchField,
        'Flutter Professional',
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Flutter Professional'),
        findsNWidgets(2),
      );
    },
  );

  testWidgets(
    'desktop learner shell uses the functional sidebar layout',
    (tester) async {
      configureTestViewport(tester, size: const Size(1280, 900));
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = createLearnerRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();

      expect(find.text('AB LEARNING'), findsWidgets);
      expect(find.text('Career Path Progress'), findsOneWidget);

      // MainShell's desktop sidebar is built before HomeScreen's sidebar.
      await tester.tap(find.text('Explore').first);
      await tester.pumpAndSettle();

      expect(find.text('คอร์สทั้งหมด'), findsOneWidget);
    },
  );

  testWidgets(
    'community tab supports creating posts and liking them',
    (tester) async {
      configureTestViewport(tester, size: const Size(390, 844));
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = createLearnerRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Community').first);
      await tester.pumpAndSettle();

      expect(find.text('ชุมชนการเรียนรู้'), findsOneWidget);

      await tester.tap(find.text('สร้างโพสต์'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'แชร์โปรเจกต์ที่เพิ่งทำเสร็จ',
      );
      await tester.tap(find.text('โพสต์'));
      await tester.pumpAndSettle();

      expect(find.text('แชร์โปรเจกต์ที่เพิ่งทำเสร็จ'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);

      await tester.tap(find.byIcon(Icons.mode_comment_outlined).first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'ขอบคุณที่แชร์ครับ',
      );
      await tester.tap(find.text('ส่ง'));
      await tester.pumpAndSettle();

      expect(find.text('คุณอนันต์: ขอบคุณที่แชร์ครับ'), findsOneWidget);
    },
  );

  testWidgets(
    'mobile navigation opens the mockup Profile destination',
    (tester) async {
      configureTestViewport(tester, size: const Size(390, 844));
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = createLearnerRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile').first);
      await tester.pumpAndSettle();

      expect(find.text('โปรไฟล์'), findsOneWidget);
      expect(find.text('คุณอนันต์'), findsOneWidget);
    },
  );

  testWidgets(
    'course purchase enrolls learner and opens its curriculum',
    (tester) async {
      expect(MockRepository.isEnrolled('c3'), isFalse);

      final router = createLearnerRouter(
        initialLocation: '/course/c3',
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('ซื้อคอร์สนี้เลย — ฿1,590'));
      await tester.pumpAndSettle();

      expect(find.text('เลือกวิธีชำระเงิน'), findsOneWidget);
      expect(find.text('พร้อมเพย์'), findsOneWidget);
      expect(find.text('บัตรเครดิต / เดบิต'), findsOneWidget);
      expect(find.text('โมบายแบงก์กิ้ง'), findsOneWidget);
      expect(find.text('AB Wallet'), findsOneWidget);
      expect(MockRepository.isEnrolled('c3'), isFalse);

      await tester.tap(find.text('โมบายแบงก์กิ้ง'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ชำระเงิน ฿1,590'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('ชำระเงินสำเร็จ'), findsOneWidget);
      expect(find.text('ช่องทาง: โมบายแบงก์กิ้ง'), findsOneWidget);
      expect(MockRepository.isEnrolled('c3'), isTrue);

      await tester.tap(find.text('เริ่มเรียนเลย'));
      await tester.pumpAndSettle();

      expect(find.text('Go Backend Essentials'), findsOneWidget);
    },
  );
}
