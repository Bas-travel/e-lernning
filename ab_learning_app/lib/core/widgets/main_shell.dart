import 'package:flutter/material.dart';
import '../../features/ai_tutor/presentation/ai_tutor_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/my_learning/presentation/my_learning_screen.dart';
import '../theme/colors.dart';

/// Hosts the 4 primary Phase 1 tabs (Home, Explore, My Learning, AI Tutor)
/// behind one bottom navigation bar so each tab's scroll position / chat
/// state survives switching tabs. Rendered at the `/home` route.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    ExploreScreen(),
    MyLearningScreen(),
    AiTutorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'My Learning'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'AI Tutor'),
        ],
      ),
    );
  }
}
