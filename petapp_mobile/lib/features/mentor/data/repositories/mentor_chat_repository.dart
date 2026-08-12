import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/mentor/data/datasources/mentor_remote_datasource.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';
import 'package:petrimonium/features/pet/data/models/investment_horizon_enum.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_preferences_repository.dart';

/// One repository facade (mirrors `PortfolioRepository`'s single-class-per-
/// feature style): sends messages to the backend, and persists the running
/// conversation on-device via SharedPreferences under one JSON-encoded key —
/// same list-persistence pattern as `AchievementsLocalRepository`. No backend
/// chat-history table in Phase 1; the client resends recent turns each call.
class MentorChatRepository {
  MentorChatRepository({
    required MentorRemoteDataSource remoteDataSource,
    required PetPreferencesRepository petPreferencesRepository,
  })  : _remoteDataSource = remoteDataSource,
        _petPreferencesRepository = petPreferencesRepository;

  static const _historyKey = 'mentor_chat_history';
  static const _maxHistoryTurnsSent = 10;

  final MentorRemoteDataSource _remoteDataSource;
  final PetPreferencesRepository _petPreferencesRepository;

  Future<List<ChatMessage>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveHistory(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(messages.map((m) => m.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> priorMessages,
    String? currentScreen,
  }) async {
    final goal = await _petPreferencesRepository.loadGoal();
    final horizon = await _petPreferencesRepository.loadHorizon();

    final recent = priorMessages.length > _maxHistoryTurnsSent
        ? priorMessages.sublist(priorMessages.length - _maxHistoryTurnsSent)
        : priorMessages;

    final history = recent
        .map((m) => {
              'role': m.role == ChatRole.user ? 'user' : 'mentor',
              'text': m.text,
            })
        .toList();

    return _remoteDataSource.sendMessage(
      message: message,
      history: history,
      context: {
        'petGoal': goal.label,
        'investmentHorizon': horizon.label,
        'currentScreen': currentScreen,
        'language': Translator.currentLanguage,
      },
    );
  }
}
