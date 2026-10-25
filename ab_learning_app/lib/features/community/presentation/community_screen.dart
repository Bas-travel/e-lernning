import 'package:flutter/material.dart';

import '../../../core/router/nav_targets.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/responsive.dart';

class _Post {
  const _Post(this.author, this.content, this.likes, this.comments);

  final String author;
  final String content;
  final int likes;
  final int comments;
}

/// Demo feed. TODO(api): `GET /community/posts`, `POST /community/posts`.
const _posts = <_Post>[
  _Post('Nattaya P.', 'เพิ่งเรียน Go จบบทที่ 5 ใครมีเทคนิคจัดโครงสร้างโปรเจกต์ แนะนำหน่อยครับ', 12, 4),
  _Post('Somchai K.', 'แชร์โน้ต SQL JOIN แบบเข้าใจง่าย ใช้ตัวอย่างร้านกาแฟ', 31, 9),
  _Post('Pim W.', 'มีใครตั้งกลุ่มติว Prompt Engineering สัปดาห์นี้บ้าง?', 7, 2),
];

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Widget _feed() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('Community', style: AppTypography.base(18, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (final p in _posts) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppAvatar(initial: p.author.substring(0, 1)),
                    const SizedBox(width: 8),
                    Text(
                      p.author,
                      style: AppTypography.base(13, weight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(p.content, style: AppTypography.base(13, height: 1.5)),
                const SizedBox(height: 8),
                Text(
                  '♥ ${p.likes}   💬 ${p.comments}',
                  style: AppTypography.base(11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context) => Scaffold(
        body: SafeArea(bottom: false, child: CenteredContent(child: _feed())),
        bottomNavigationBar: AppBottomNav(
          currentIndex: 3,
          onTap: (i) => NavTargets.onTab(context, i),
        ),
      ),
      desktop: (context) => Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSidebar(
              activeKey: 'community',
              onSelect: (k) => NavTargets.onSidebar(context, k),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.background,
                child: CenteredContent(maxWidth: 720, child: _feed()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
