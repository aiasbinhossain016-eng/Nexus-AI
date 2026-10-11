import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/api.dart';

/// Connects to nexus-core (ws://127.0.0.1:8000/ws), auto-reconnects, and
/// speaks the backend protocol: send {"type":"chat","instruction":...},
/// receive streamed JSON steps ({"type":"text"|"tool_result"|"error",...}).
class WebSocketService {
  WebSocketChannel? _channel;
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  final _status = StreamController<bool>.broadcast();
  Timer? _retry;
  bool _connected = false;
  bool _disposed = false;

  Stream<Map<String, dynamic>> get events => _events.stream;
  Stream<bool> get connection => _status.stream;
  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_disposed || _channel != null) return;
    try {
      final ch = WebSocketChannel.connect(Uri.parse(ApiConfig.websocket));
      await ch.ready;
      _channel = ch;
      _setConnected(true);
      ch.stream.listen(
        _onData,
        onDone: _closed,
        onError: (_) => _closed(),
        cancelOnError: true,
      );
    } catch (_) {
      _closed();
    }
  }

  void _onData(dynamic data) {
    final text = data.toString();
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        _events.add(Map<String, dynamic>.from(decoded));
        return;
      }
    } catch (_) {}
    _events.add({'type': 'text', 'content': text});
  }

  void _closed() {
    _channel = null;
    _setConnected(false);
    if (_disposed) return;
    _retry?.cancel();
    _retry = Timer(const Duration(seconds: 3), connect);
  }

  void _setConnected(bool v) {
    _connected = v;
    if (!_status.isClosed) _status.add(v);
  }

  /// Returns false when the server is not connected.
  bool sendChat(String instruction, {String sessionId = 'desktop'}) {
    final ch = _channel;
    if (ch == null || !_connected) return false;
    ch.sink.add(jsonEncode({
      'type': 'chat',
      'instruction': instruction,
      'session_id': sessionId,
    }));
    return true;
  }

  void dispose() {
    _disposed = true;
    _retry?.cancel();
    _channel?.sink.close();
    _events.close();
    _status.close();
  }
}
