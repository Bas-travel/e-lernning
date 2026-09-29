import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';

/// Screen 21 — AI Tutor. Chat thread with suggested-question chips and a
/// quick-action row. Uses a canned mock responder until the AI backend
/// (`POST /api/v1/ai/tutor`) is wired up.
class AiTutorScreen extends StatefulWidget {
  final String contextTitle;

  const AiTutorScreen({super.key, this.contextTitle = 'your learning journey'});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  late final List<ChatMessage> _messages =
      List.of(MockRepository.initialTutorThread(widget.contextTitle));
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  static const _quickActions = ['Explain', 'Give Example', 'Quiz Me', 'Career Advice'];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: trimmed, fromUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: MockRepository.mockTutorReply(trimmed), fromUser: false));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Tutor')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                for (final message in _messages) _ChatBubble(message: message),
                if (_isTyping) const _TypingIndicator(),
              ],
            ),
          ),
          if (_messages.length <= 1)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: MockRepository.tutorSuggestedQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final question = MockRepository.tutorSuggestedQuestions[i];
                  return ActionChip(label: Text(question), onPressed: () => _send(question));
                },
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickActions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final action = _quickActions[i];
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.btnOutlineBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => _send(action),
                  child: Text(action, style: AppTypography.caption),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: 'Ask your AI Tutor...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _send(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: isUser ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          message.text,
          style: AppTypography.body.copyWith(color: isUser ? Colors.white : AppColors.text),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text('AI Tutor is typing...', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }
}
