import 'package:ab_learning_app/core/widgets/main_shell.dart';
import 'package:ab_learning_app/data/mock/mock_repository.dart';
import 'package:ab_learning_app/features/course/presentation/course_detail_screen.dart';
import 'package:ab_learning_app/features/course/presentation/curriculum_screen.dart';
import 'package:ab_learning_app/features/course/presentation/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
      'mobile learner shell shows the mockup Home sections and search works',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    expect(find.text('สวัสดี, คุณอนันต์ 👋'), findsOneWidget);
    expect(find.text('วันนี้อยากพัฒนาอะไร?'), findsOneWidget);
    expect(find.text('เรียนต่อ'), findsOneWidget);
    expect(find.text('แนะนำสำหรับคุณ'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Live กำลังจะเริ่ม'), findsOneWidget);

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Marc Delgado');
    await tester.pumpAndSettle();

    expect(find.text('UX Research Fundamentals'), findsOneWidget);
  });

  testWidgets('desktop learner shell uses the functional sidebar layout',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    expect(find.text('AB LEARNING'), findsOneWidget);
    expect(find.text('Career Path Progress'), findsOneWidget);
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('คอร์สทั้งหมด'), findsOneWidget);
  });

  testWidgets('community tab supports creating posts and liking them',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();

    expect(find.text('ชุมชนการเรียนรู้'), findsOneWidget);
    await tester.tap(find.text('สร้างโพสต์'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextField), 'แชร์โปรเจกต์ที่เพิ่งทำเสร็จ');
    await tester.tap(find.text('โพสต์'));
    await tester.pumpAndSettle();

    expect(find.text('แชร์โปรเจกต์ที่เพิ่งทำเสร็จ'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.byIcon(Icons.mode_comment_outlined).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ขอบคุณที่แชร์ครับ');
    await tester.tap(find.text('ส่ง'));
    await tester.pumpAndSettle();
    expect(find.text('คุณอนันต์: ขอบคุณที่แชร์ครับ'), findsOneWidget);
  });

  testWidgets('mobile navigation includes the mockup Profile destination',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('โปรไฟล์'), findsOneWidget);
    expect(find.text('คุณอนันต์'), findsOneWidget);
  });

  testWidgets('course purchase enrolls learner and opens its curriculum',
      (tester) async {
    expect(MockRepository.isEnrolled('c3'), isFalse);
    final router = GoRouter(
      initialLocation: '/course/c3',
      routes: [
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
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
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
  });
}
