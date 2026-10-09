class Option {
  final String id; // "A", "B", "C", "D"
  final String text;

  Option({required this.id, required this.text});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
      };
}

class Question {
  final String id;
  final String category;
  final String categoryEmoji;
  final String difficulty; // "EASY", "MEDIUM", "HARD"
  final String questionText;
  final String quoteHighlight;
  final List<Option> options;
  final String correctOptionId;
  final String explanation;
  final int pointValue;

  Question({
    required this.id,
    required this.category,
    this.categoryEmoji = '🧠',
    required this.difficulty,
    required this.questionText,
    this.quoteHighlight = '',
    required this.options,
    required this.correctOptionId,
    required this.explanation,
    required this.pointValue,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'] as List<dynamic>? ?? [];
    List<Option> opts = rawOptions.map((o) => Option.fromJson(o as Map<String, dynamic>)).toList();
    
    return Question(
      id: json['id'] as String? ?? 'q_001',
      category: json['category'] as String? ?? 'General',
      categoryEmoji: json['categoryEmoji'] as String? ?? '🧠',
      difficulty: json['difficulty'] as String? ?? 'MEDIUM',
      questionText: json['question'] as String? ?? json['questionText'] as String? ?? '',
      quoteHighlight: json['quoteHighlight'] as String? ?? '',
      options: opts,
      correctOptionId: json['correctOptionId'] as String? ?? 'A',
      explanation: json['explanation'] as String? ?? '',
      pointValue: json['pointValue'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'categoryEmoji': categoryEmoji,
        'difficulty': difficulty,
        'question': questionText,
        'quoteHighlight': quoteHighlight,
        'options': options.map((o) => o.toJson()).toList(),
        'correctOptionId': correctOptionId,
        'explanation': explanation,
        'pointValue': pointValue,
      };
}
