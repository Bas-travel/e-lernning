import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/colors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter().router;

    return MaterialApp.router(
      title: 'AB LEARNING',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
      ),
      routerConfig: router,
    );
  }
}
