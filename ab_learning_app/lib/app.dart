import 'package:flutter/material.dart';
// <<<<<<< design/tokens-update
// import 'core/theme/colors.dart';
// import 'core/router/app_router.dart';
// =======
// import 'core/router/app_router.dart';
// import 'core/theme/app_theme.dart';
// >>>>>>> main

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter().router;

    return MaterialApp.router(
      title: 'AB LEARNING',
// <<<<<<< design/tokens-update
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: AppColors.primary,
//           brightness: Brightness.light,
//           surface: Colors.white,
//         ),
//         primaryColor: AppColors.primary,
//         scaffoldBackgroundColor: AppColors.background,
//         useMaterial3: true,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: AppColors.background,
//           foregroundColor: AppColors.text,
//           elevation: 0,
//           centerTitle: false,
//         ),
//         cardTheme: CardThemeData(
//           color: Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: const BorderSide(color: AppColors.cardBorder),
//           ),
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.cardBorder),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.cardBorder),
//           ),
//         ),
//       ),
// =======
//       theme: AppTheme.light,
// >>>>>>> main
      routerConfig: router,
    );
  }
}
