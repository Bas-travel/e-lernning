import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 820;
            if (!desktop) {
              return Column(
                children: [
                  const _BrandPanel(compact: true),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: _AuthFormContent(
                            title: title,
                            subtitle: subtitle,
                            form: form,
                            footer: footer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(
                  flex: 7,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(48),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: _AuthFormContent(
                          title: title,
                          subtitle: subtitle,
                          form: form,
                          footer: footer,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuthFormContent extends StatelessWidget {
  const _AuthFormContent({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: AppTypography.display
                .copyWith(fontSize: 27, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Text(subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 26),
        form,
        const SizedBox(height: 22),
        footer,
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      width: double.infinity,
      height: compact ? 178 : null,
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 24 : 54, vertical: compact ? 22 : 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF172554), Color(0xFF312E81), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: compact ? -4 : 8,
            bottom: compact ? -36 : 54,
            child: Container(
              width: compact ? 145 : 280,
              height: compact ? 145 : 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12), width: 1.5),
              ),
              child: Center(
                child: Container(
                  width: compact ? 98 : 184,
                  height: compact ? 98 : 184,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Icon(Icons.auto_stories_rounded,
                      size: compact ? 40 : 78, color: const Color(0xFFB7F3E1)),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.school_rounded,
                        color: Color(0xFFB7F3E1), size: 22),
                  ),
                  const SizedBox(width: 11),
                  const Text('AB LEARNING',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              if (!compact) ...[
                const Spacer(),
                const SizedBox(
                  width: 440,
                  child: Text(
                    'เรียนรู้ทักษะใหม่\nเติบโตในแบบของคุณ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        height: 1.3,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 14),
                const SizedBox(
                  width: 380,
                  child: Text(
                    'คอร์สที่ออกแบบเพื่อการลงมือทำ พร้อมชุมชนและเครื่องมือที่ช่วยให้คุณไปถึงเป้าหมาย',
                    style: TextStyle(
                        color: Color(0xFFD7DCF9), fontSize: 15, height: 1.7),
                  ),
                ),
                const SizedBox(height: 34),
                const _TrustNote(
                    icon: Icons.verified_outlined,
                    text: 'เรียนตามจังหวะของคุณ'),
                const SizedBox(height: 14),
                const _TrustNote(
                    icon: Icons.workspace_premium_outlined,
                    text: 'สะสมทักษะที่นำไปใช้ได้จริง'),
                const Spacer(),
                const Text('LEARN  ·  BUILD  ·  GROW',
                    style: TextStyle(
                        color: Color(0xFFB7F3E1),
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ],
      ),
    );

    if (compact) return panel;
    return SizedBox.expand(child: panel);
  }
}

class _TrustNote extends StatelessWidget {
  const _TrustNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB7F3E1), size: 20),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}
