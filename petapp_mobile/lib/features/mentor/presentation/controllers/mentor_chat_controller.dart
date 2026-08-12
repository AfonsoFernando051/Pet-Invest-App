import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:petrimonium/features/mentor/data/repositories/mentor_chat_repository.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';

const String _fallbackErrorReply =
    'Hmm, algo deu errado ao pensar na resposta 🐾 Vamos tentar de novo daqui a pouco?';

/// Drives the Mentor chat: message list, sending state, and a client-side
/// typewriter reveal that simulates streaming over a normal request/response
/// call (real SSE streaming is a documented future step, not implemented in
/// Phase 1 — see docs/AI_MENTOR.md).
class MentorChatController extends ChangeNotifier {
  MentorChatController({required MentorChatRepository repository}) : _repository = repository;

  final MentorChatRepository _repository;

  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  bool _isLoadingHistory = true;
  Timer? _revealTimer;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  bool get isLoadingHistory => _isLoadingHistory;

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    final history = await _repository.loadHistory();
    _messages
      ..clear()
      ..addAll(history);

    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text, {String? currentScreen}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    final priorMessages = List<ChatMessage>.of(_messages);
    _messages.add(ChatMessage(
      id: _newId(),
      role: ChatRole.user,
      text: trimmed,
      timestamp: DateTime.now(),
    ));
    _isSending = true;
    notifyListeners();
    await _repository.saveHistory(_messages);

    try {
      final reply = await _repository.sendMessage(
        message: trimmed,
        priorMessages: priorMessages,
        currentScreen: currentScreen,
      );
      await _revealReply(reply, isError: false);
    } catch (_) {
      await _revealReply(_fallbackErrorReply, isError: true);
    } finally {
      _isSending = false;
      notifyListeners();
      await _repository.saveHistory(_messages);
    }
  }

  /// Reveals [fullText] a few characters at a time so a normal (non-streamed)
  /// backend reply still reads as "typing" like the ChatGPT/Claude-style
  /// experience the product spec asks for.
  Future<void> _revealReply(String fullText, {required bool isError}) async {
    final messageId = _newId();
    _messages.add(ChatMessage(
      id: messageId,
      role: ChatRole.mentor,
      text: '',
      timestamp: DateTime.now(),
      isError: isError,
    ));
    notifyListeners();

    if (fullText.isEmpty) return;

    final completer = Completer<void>();
    var charIndex = 0;
    const chunkSize = 3;
    const tickDuration = Duration(milliseconds: 16);

    _revealTimer?.cancel();
    _revealTimer = Timer.periodic(tickDuration, (timer) {
      charIndex = min(charIndex + chunkSize, fullText.length);
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(text: fullText.substring(0, charIndex));
        notifyListeners();
      }
      if (charIndex >= fullText.length) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> clearConversation() async {
    _revealTimer?.cancel();
    _messages.clear();
    notifyListeners();
    await _repository.clearHistory();
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${_messages.length}';

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }
}
