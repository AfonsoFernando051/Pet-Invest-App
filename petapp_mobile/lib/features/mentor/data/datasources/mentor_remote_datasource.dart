import 'dart:convert';

import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';

/// Thin HTTP layer over `/api/mentor/chat`. The backend builds the real
/// portfolio/pet context server-side from the authenticated user — this only
/// carries the message, recent turns, and mobile-local signals (goal,
/// horizon, current screen, language) the server has no way to know.
class MentorRemoteDataSource {
  final ApiClient apiClient;

  MentorRemoteDataSource({required this.apiClient});

  Future<String> sendMessage({
    required String message,
    required List<Map<String, String>> history,
    required Map<String, String?> context,
  }) async {
    final response = await apiClient.post(ApiConstants.mentorChatEndpoint, {
      'message': message,
      'history': history,
      'context': context,
    });

    if (response.statusCode != 200) {
      throw Exception('Mentor chat request failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['reply'] as String;
  }
}
