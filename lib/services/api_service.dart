import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../models/question.dart';
import 'local_question_service.dart';

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<Question> fetchNextQuestion({
    required String sessionId,
    required String difficulty,
    required String category,
    int index = 0,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/sessions/$sessionId/question');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'difficulty': difficulty,
          'category': category,
          'index': index,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['question'] != null) {
          return Question.fromJson(data['question'] as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Fallback gracefully on timeout/error
    }

    // Return fallback question from local bank
    final fallbacks = LocalQuestionService.getFallbackQuestions();
    return fallbacks[index % fallbacks.length];
  }

  Future<Map<String, dynamic>> submitAnswer({
    required String sessionId,
    required String questionId,
    required String selectedOptionId,
    required String playerId,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/sessions/$sessionId/answer');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'questionId': questionId,
          'selectedOptionId': selectedOptionId,
          'playerId': playerId,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}

    return {'success': true};
  }
}
