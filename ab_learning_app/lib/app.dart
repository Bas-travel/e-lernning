import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/hifi_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _AppRouterHost());
  }
}

class _AppRouterHost extends ConsumerWidget {
  const _AppRouterHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'AB LEARNING',
      debugShowCheckedModeBanner: false,
      theme: HifiTheme.light,
      routerConfig: router,
    );
  }
}