import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/sub_page_scaffold.dart';

class _Message {
  const _Message(this.text, {required this.fromUser});

  final String text;
  final bool fromUser;
}

/// AI Tutor chat. Talks to `POST /ai/tutor` through [TutorRepository].
class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  static const _quickActions = <({String label, String action})>[
    (label: 'อธิบายให้หน่อย', action: 'explain'),
    (label: 'ขอตัวอย่าง', action: 'example'),
    (label: 'ทดสอบฉัน', action: 'quiz_me'),
    (label: 'แนะนำอาชีพ', action: 'career_advice'),
  ];

  final _controller = TextEditingController();
  final _messages = <_Message>[
    const _Message(
      'สวัสดี! ฉันคือ AI Tutor ถามเรื่องบทเรียนหรือเส้นทางอาชีพได้เลย',
      fromUser: false,
    ),
  ];
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send({String? action, String? text}) async {
    final message = (text ?? _controller.text).trim();
    if (message.isEmpty || _sending) return;
    setState(() {
      _messages.add(_Message(message, fromUser: true));
      _sending = true;
      _error = null;
      _controller.clear();
    });
    try {
      final reply = await AppDependencies.tutorRepository
          .ask(message, action: action);
      if (!mounted) return;
      setState(() => _messages.add(_Message(reply, fromUser: false)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'เกิดข้อผิดพลาด กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _bubble(_Message m) {
    return Align(
      alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: m.fromUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: m.fromUser ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          m.text,
          style: AppTypography.base(
            13,
            height: 1.45,
            color: m.fromUser ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'AI Tutor',
      fallbackRoute: '/home',
      children: [
        for (final m in _messages) _bubble(m),
        if (_sending)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'กำลังพิมพ์...',
              style: AppTypography.base(12, color: AppColors.textSecondary),
            ),
          ),
        if (_error != null) InlineBanner(message: _error!),
      ],
      bottom: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final q in _quickActions) ...[
                    AppChip(
                      label: q.label,
                      onTap: () => _send(action: q.action, text: q.label),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'พิมพ์คำถาม...'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'ส่ง',
                  onPressed: _sending ? null : () => _send(),
                  icon: const Icon(Icons.send, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
