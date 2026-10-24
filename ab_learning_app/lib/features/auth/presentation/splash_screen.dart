import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), _route);
  }

  /// Spec 01: session found -> Home, otherwise -> Onboarding.
  Future<void> _route() async {
    var signedIn = false;
    try {
      signedIn = await AppDependencies.authRepository.hasSession();
    } catch (_) {
      // Storage unavailable: treat as signed out.
    }
    if (!mounted) return;
    context.go(signedIn ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile: (_) => const _SplashMobile(),
        desktop: (_) => const _SplashDesktop(),
      ),
    );
  }
}

const _tagline = 'Learn · Live · Community · Career';

class _SplashProgress extends StatelessWidget {
  const _SplashProgress({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: width,
          height: 4,
          color: AppColors.whiteA25,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.6,
            child: Container(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _SplashMobile extends StatelessWidget {
  const _SplashMobile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.splash),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(
                size: 72,
                radius: 20,
                color: AppColors.whiteA15,
                borderColor: AppColors.whiteA40,
              ),
              const SizedBox(height: 16),
              Text(
                'AB LEARNING',
                style: AppTypography.base(
                  20,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _tagline,
                style: AppTypography.base(12, color: AppColors.whiteA85),
              ),
              const SizedBox(height: 40),
              const _SplashProgress(width: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashDesktop extends StatelessWidget {
  const _SplashDesktop();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.splash),
      child: Center(
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(60),
          decoration: BoxDecoration(
            color: AppColors.whiteA08,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.whiteA25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(
                size: 64,
                radius: 18,
                color: AppColors.whiteA15,
                borderWidth: 0,
              ),
              const SizedBox(height: 18),
              Text(
                'AB LEARNING',
                style: AppTypography.base(
                  22,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _tagline,
                style: AppTypography.base(13, color: AppColors.whiteA85),
              ),
              const SizedBox(height: 34),
              const _SplashProgress(width: 160),
            ],
          ),
        ),
      ),
    );
  }
}
