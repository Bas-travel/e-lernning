import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/ai_tutor/presentation/ai_tutor_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/my_learning/presentation/my_learning_screen.dart';
import '../theme/colors.dart';
import 'role_switcher_sheet.dart';

/// Hosts the learner destinations behind persistent mobile and desktop navigation.
/// behind one bottom navigation bar so each tab's scroll position / chat
/// state survives switching tabs. Rendered at the `/home` route.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0, this.tutorContext});

  final int initialIndex;
  final String? tutorContext;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  List<Widget> get _tabs => [
        const HomeScreen(),
        const ExploreScreen(),
        const MyLearningScreen(),
        const _CommunityScreen(),
        AiTutorScreen(
            contextTitle: widget.tutorContext ?? 'your learning journey'),
        const _ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final content = IndexedStack(index: _index, children: _tabs);
    final selectedMobileIndex = switch (_index) {
      4 => 2,
      5 => 4,
      _ => _index,
    };

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                _DesktopSidebar(
                  selectedIndex: _index,
                  onSelected: (index) => setState(() => _index = index),
                ),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: selectedMobileIndex,
              onDestinationSelected: (i) =>
                  setState(() => _index = i == 4 ? 5 : i),
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primary.withValues(alpha: 0.12),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore),
                    label: 'Explore'),
                NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: 'Learn'),
                NavigationDestination(
                    icon: Icon(Icons.forum_outlined),
                    selectedIcon: Icon(Icons.forum),
                    label: 'Community'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile'),
              ],
            ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar(
      {required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.explore_outlined, 'Explore'),
    (Icons.menu_book_outlined, 'My Learning'),
    (Icons.forum_outlined, 'Community'),
    (Icons.smart_toy_outlined, 'AI Tutor'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.cardBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 28),
            child: Text(
              'AB LEARNING',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ),
          for (var index = 0; index < _items.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SidebarItem(
                icon: _items[index].$1,
                label: _items[index].$2,
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            children: [
              Icon(icon,
                  size: 19,
                  color:
                      selected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 11),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityScreen extends StatefulWidget {
  const _CommunityScreen();

  @override
  State<_CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<_CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  final List<_CommunityPost> _posts = [
    _CommunityPost(
      author: 'Nina Sato',
      topic: 'Flutter Developers',
      time: '20 นาทีที่แล้ว',
      message:
          'เพิ่งทำแอปแรกเสร็จจากบทเรียนเรื่อง Navigation มีใครอยากช่วยรีวิว flow บ้างครับ',
      likes: 12,
    ),
    _CommunityPost(
      author: 'Marc Delgado',
      topic: 'Design Learners',
      time: '2 ชั่วโมงที่แล้ว',
      message:
          'แชร์ checklist สั้น ๆ สำหรับเตรียมสัมภาษณ์ผู้ใช้ครั้งแรก ใครมีคำถามถามได้เลย',
      likes: 8,
    ),
  ];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สร้างโพสต์'),
        content: TextField(
          controller: _postController,
          autofocus: true,
          maxLines: 4,
          decoration:
              const InputDecoration(hintText: 'อยากแบ่งปันอะไรกับชุมชน?'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก')),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _postController.text.trim()),
              child: const Text('โพสต์')),
        ],
      ),
    );
    if (!mounted || message == null || message.isEmpty) return;
    setState(() {
      _posts.insert(
          0,
          _CommunityPost(
            author: 'คุณอนันต์',
            topic: 'Learning Community',
            time: 'เมื่อสักครู่',
            message: message,
          ));
      _postController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ชุมชนการเรียนรู้')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('แลกเปลี่ยนความรู้และเติบโตไปด้วยกัน',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          for (final post in _posts) ...[
            _PostCard(post: post),
            const SizedBox(height: 12),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('สร้างโพสต์'),
      ),
    );
  }
}

class _CommunityPost {
  _CommunityPost({
    required this.author,
    required this.topic,
    required this.time,
    required this.message,
    this.likes = 0,
  });

  final String author;
  final String topic;
  final String time;
  final String message;
  int likes;
  int comments = 0;
  final List<String> commentMessages = [];
  bool liked = false;
}

class _PostCard extends StatefulWidget {
  const _PostCard({required this.post});

  final _CommunityPost post;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _showComments() async {
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ความคิดเห็น (${widget.post.comments})'),
        content: TextField(
          controller: _commentController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'เขียนความคิดเห็น'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก')),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _commentController.text.trim()),
              child: const Text('ส่ง')),
        ],
      ),
    );
    if (!mounted || comment == null || comment.isEmpty) return;
    setState(() {
      widget.post.comments++;
      widget.post.commentMessages.add(comment);
      _commentController.clear();
    });
  }

  void _reportPost() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: const Text('รายงานโพสต์'),
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('รับรายงานโพสต์แล้ว')));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${post.topic} · ${post.time}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                  tooltip: 'ตัวเลือกโพสต์',
                  onPressed: _reportPost,
                  icon: const Icon(Icons.more_horiz)),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.message),
          for (final comment in post.commentMessages)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text('คุณอนันต์: $comment',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
          const Divider(height: 24),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() {
                  post.liked = !post.liked;
                  post.likes += post.liked ? 1 : -1;
                }),
                icon: Icon(post.liked ? Icons.favorite : Icons.favorite_border,
                    color:
                        post.liked ? AppColors.error : AppColors.textSecondary),
                label: Text('${post.likes}'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                  onPressed: _showComments,
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: Text('${post.comments}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.primary,
            child: Text('A',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          const Center(
              child: Text('คุณอนันต์',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
          const Center(
              child: Text('learner@ablearning.com',
                  style: TextStyle(color: AppColors.textSecondary))),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('การเรียนของฉัน'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/my-learning'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('เปลี่ยนบทบาท'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showRoleSwitcherSheet(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('ออกจากระบบ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
