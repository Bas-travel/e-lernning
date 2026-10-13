import 'package:ab_learning_app/core/navigation/role_menus.dart';
import 'package:ab_learning_app/core/widgets/role_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  const roles = <AppRole>[
    AppRole.instructor,
    AppRole.corpAdmin,
    AppRole.corpManager,
    AppRole.employer,
    AppRole.admin,
  ];

  test('every business role has a home route and navigable destinations', () {
    for (final role in roles) {
      final menu = sidebarFor(role);
      expect(menu, isNotEmpty, reason: '${labelFor(role)} has no menu');
      expect(menu.every((item) => item.route != null), isTrue,
          reason: '${labelFor(role)} has a disabled menu item');
      expect(homeRouteForRole(role), menu.first.route,
          reason: '${labelFor(role)} home does not match its first menu item');
      expect(menu.map((item) => item.route).toSet().length, menu.length,
          reason: '${labelFor(role)} has duplicate destination routes');
    }

    expect(sidebarFor(AppRole.corpManager), corporateMenu);
    expect(labelFor(AppRole.corpManager), 'Corporate Manager');
  });

  for (final role in roles) {
    testWidgets('${labelFor(role)} can navigate to every menu destination',
        (tester) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final menu = sidebarFor(role);
      final router = GoRouter(
        initialLocation: homeRouteForRole(role),
        routes: [
          for (final item in menu)
            GoRoute(
              path: item.route!,
              builder: (context, state) => RoleScaffold(
                role: role,
                activeRoute: state.location,
                title: item.label,
                child: Scaffold(
                  body: Center(child: Text('Screen ${state.location}')),
                ),
              ),
            ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      for (final item in menu) {
        await tester.tap(find.text(item.label).first);
        await tester.pumpAndSettle();
        expect(find.text('Screen ${item.route}'), findsOneWidget,
            reason: '${labelFor(role)} could not open ${item.label}');
      }
    });
  }
}
