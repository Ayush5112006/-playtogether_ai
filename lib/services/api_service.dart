import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../models/question.dart';

class ApiService {
  final http.Client client;
  static List<Question>? _cachedQuestions;
  static List<Map<String, dynamic>>? _cachedCategories;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Creates a session with players in Supabase via backend
  Future<String> createSession({
    required List<Map<String, dynamic>> players,
    String difficulty = 'MEDIUM',
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/sessions');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'players': players,
        'settings': {'difficulty': difficulty},
      }),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['sessionId'] != null) {
        return data['sessionId'] as String;
      }
    }

    throw Exception('Failed to create session on Supabase backend: ${response.body}');
  }

  /// Fetches all active questions from the Supabase database via backend
  Future<List<Question>> fetchAllQuestions({String? category, String? difficulty}) async {
    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (difficulty != null && difficulty.isNotEmpty) queryParams['difficulty'] = difficulty;

    // Return cached if unfiltered and already available
    if (queryParams.isEmpty && _cachedQuestions != null && _cachedQuestions!.isNotEmpty) {
      return _cachedQuestions!;
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/questions').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final response = await client.get(uri).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['questions'] != null) {
        final list = data['questions'] as List<dynamic>;
        final parsed = list.map((q) => Question.fromJson(q as Map<String, dynamic>)).toList();
        if (queryParams.isEmpty) {
          _cachedQuestions = parsed;
        }
        return parsed;
      }
    }

    return _cachedQuestions ?? [];
  }

  /// Fetches categories & counts dynamically from the Supabase database via backend
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    final url = Uri.parse('${AppConfig.baseUrl}/categories');
    final response = await client.get(url).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['categories'] != null) {
        final cats = List<Map<String, dynamic>>.from(data['categories'] as List);
        _cachedCategories = cats;
        return cats;
      }
    }

    return [];
  }

  /// Fetches next question for an active session from Supabase
  Future<Question?> fetchNextQuestion({
    required String sessionId,
    required String difficulty,
    required String category,
    int index = 0,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/sessions/$sessionId/question');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'difficulty': difficulty,
        'category': category,
        'index': index,
      }),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['question'] != null) {
        return Question.fromJson(data['question'] as Map<String, dynamic>);
      }
    }

    return null;
  }

  /// Submits player answer to backend to persist in Supabase player_answers
  Future<Map<String, dynamic>> submitAnswer({
    required String sessionId,
    required String questionId,
    required String selectedOptionId,
    required String playerId,
    double responseTimeSeconds = 2.0,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/sessions/$sessionId/answer');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
        'playerId': playerId,
        'responseTimeSeconds': responseTimeSeconds,
      }),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to submit answer to Supabase backend: ${response.body}');
  }

  /// Fetches surprise challenge round dynamically from backend
  Future<Map<String, dynamic>> fetchSurpriseChallenge(String sessionId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/sessions/$sessionId/surprise');
    final response = await client.post(url).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['challenge'] != null) {
        return Map<String, dynamic>.from(data['challenge'] as Map);
      }
    }

    throw Exception('Failed to fetch surprise challenge from Supabase backend');
  }

  /// Fetches post-game recap and insights calculated directly from Supabase
  Future<Map<String, dynamic>> fetchRecap(String sessionId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/sessions/$sessionId/recap');
    final response = await client.post(url).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['recap'] != null) {
        return Map<String, dynamic>.from(data['recap'] as Map);
      }
    }

    throw Exception('Failed to fetch recap from Supabase backend');
  }
}
