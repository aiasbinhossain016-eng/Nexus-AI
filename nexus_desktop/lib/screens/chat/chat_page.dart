import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/chat_message.dart';
import '../../providers/chat/chat_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/chat/chat_message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) => ChatMessageBubble(
                  message: chatState.messages[index],
                  onApprove: (id) => ref
                      .read(chatProvider.notifier)
                      .handleConfirmation(confirmationId: id, approved: true),
                  onReject: (id) => ref
                      .read(chatProvider.notifier)
                      .handleConfirmation(confirmationId: id, approved: false),
                ),
              ),
            ),
          ),
        ),
        if (chatState.isSending)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.gold,
              ),
            ),
          ),
        ChatInputBar(
          hint: 'Message NexusAI...',
          enabled: !chatState.isSending,
          onSend: (text) => ref.read(chatProvider.notifier).sendMessage(text),
        ),
      ],
    );
  }
}
