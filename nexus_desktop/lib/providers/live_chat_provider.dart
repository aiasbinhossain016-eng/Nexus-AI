import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/websocket_service.dart';

final webSocketProvider = Provider<WebSocketService>((ref) {
  final s = WebSocketService()..connect();
  ref.onDispose(s.dispose);
  return s;
});

/// true = connected to nexus-core.
final connectionProvider = StreamProvider<bool>((ref) async* {
  final s = ref.watch(webSocketProvider);
  yield s.isConnected;
  yield* s.connection;
});

class LiveChatNotifier extends StateNotifier<List<ChatMessage>> {
  final WebSocketService _ws;
  late final StreamSubscription<Map<String, dynamic>> _sub;

  LiveChatNotifier(this._ws) : super(const []) {
    _sub = _ws.events.listen(_onEvent);
  }

  void _addAi(String text) {
    state = [...state, ChatMessage(text, fromUser: false)];
  }

  void _onEvent(Map<String, dynamic> e) {
    switch (e['type']) {
      case 'text':
        final c = (e['content'] ?? '').toString().trim();
        if (c.isNotEmpty) _addAi(c);
        break;
      case 'error':
        _addAi('Error: ${e['content'] ?? 'unknown error'}');
        break;
      case 'tool_result':
        final content = e['content'];
        if (content is Map && content['status'] == 'confirmation_required') {
          _addAi('This action needs your confirmation.');
        }
        break;
      default:
        break; // connected / pong / other steps
    }
  }

  void send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    state = [...state, ChatMessage(t, fromUser: true)];
    if (!_ws.sendChat(t)) {
      _addAi('Server offline. Start nexus-core on port 8000, then try again.');
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final liveChatProvider =
    StateNotifierProvider<LiveChatNotifier, List<ChatMessage>>(
  (ref) => LiveChatNotifier(ref.watch(webSocketProvider)),
);
