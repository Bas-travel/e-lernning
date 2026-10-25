import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/responsive.dart';

class _Slide {
  const _Slide({
    required this.title,
    required this.description,
    required this.desktopDescription,
    required this.gradient,
  });

  final String title;
  final String description;
  final String desktopDescription;
  final Gradient gradient;
}

// Slide 1 copy is taken from the hi-fi mockup. Slides 2-3 follow the spec's
// "Learn / Build Skills / Get Career" themes; their wording is a draft that
// still needs product/design sign-off (no source copy exists in the repo).
const _slides = <_Slide>[
  _Slide(
    title: 'Build real skills, not just watch videos',
    description: 'ลงมือทำโปรเจกต์จริงในทุกหลักสูตร พร้อม AI ที่คอยช่วยตลอดทาง',
    desktopDescription:
        'ลงมือทำโปรเจกต์จริงในทุกหลักสูตร พร้อม AI ที่คอยช่วยตลอดทาง ตั้งแต่เรียนจนถึงหางาน',
    gradient: AppGradients.brandAccent,
  ),
  _Slide(
    title: 'Learn live, learn together',
    description: 'เรียนสดกับผู้สอน ถามตอบทันที และเติบโตไปพร้อมคอมมูนิตี้',
    desktopDescription:
        'เรียนสดกับผู้สอน ถามตอบทันที และเติบโตไปพร้อมคอมมูนิตี้ของผู้เรียน',
    gradient: AppGradients.accentPrimary,
  ),
  _Slide(
    title: 'Turn skills into a career',
    description: 'วางเส้นทางอาชีพ สร้างพอร์ตโฟลิโอ และหางานที่ตรงกับสกิลของคุณ',
    desktopDescription:
        'วางเส้นทางอาชีพ สร้างพอร์ตโฟลิโอ และหางานที่ตรงกับสกิลของคุณ',
    gradient: AppGradients.brand,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      context.go('/login');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _skip() => context.go('/login');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveBuilder(
        mobile: _buildMobile,
        desktop: _buildDesktop,
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return SafeArea(
      child: CenteredContent(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _skip,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Skip',
                        style: AppTypography.base(
                          12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final slide = _slides[i];
                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: slide.gradient,
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              Text(
                                slide.title,
                                textAlign: TextAlign.center,
                                style: AppTypography.base(
                                  17,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                slide.description,
                                textAlign: TextAlign.center,
                                style: AppTypography.base(
                                  12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _Dots(
                  count: _slides.length,
                  index: _index,
                  alignment: MainAxisAlignment.center,
                ),
              ),
              AppButton.primary(
                label: _isLast ? 'Get Started' : 'Next',
                onPressed: _next,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final slide = _slides[_index];
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(gradient: slide.gradient),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: AppTypography.base(
                    26,
                    weight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Text(
                    slide.desktopDescription,
                    style: AppTypography.base(
                      14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _Dots(
                  count: _slides.length,
                  index: _index,
                  alignment: MainAxisAlignment.start,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton.ghost(label: 'Skip', onPressed: _skip),
                    const SizedBox(width: 10),
                    AppButton.primary(
                      label: _isLast ? 'Get Started' : 'Next',
                      onPressed: () {
                        if (_isLast) {
                          context.go('/login');
                        } else {
                          setState(() => _index++);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Page indicator drawn as in the mockup: 20×20 rounded squares, 6px apart.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.index,
    required this.alignment,
  });

  final int count;
  final int index;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: i == index ? AppColors.primary : AppColors.track,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ],
    );
  }
}
