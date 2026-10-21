import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Translucent back button drawn over hero media. Not in the mockup, but the
/// original screens had an AppBar back arrow, so the way back is preserved.
/// Renders nothing when there is no page to pop.
class CourseBackButton extends StatelessWidget {
  const CourseBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Semantics(
        button: true,
        label: 'Back',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.whiteA25,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
