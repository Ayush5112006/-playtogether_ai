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

  int get correctIndex {
    final idx = options.indexWhere((o) => o.id == correctOptionId);
    return idx != -1 ? idx : 0;
  }

  int get points => pointValue;

  static List<Question> getSampleQuestions() {
    return [
      Question(
        id: 'q_001',
        category: 'Cinema Clues',
        categoryEmoji: '🎬',
        difficulty: 'MEDIUM',
        questionText: 'Which movie character is famous for the line:',
        quoteHighlight: '"May the Force be with you"',
        options: [
          Option(id: 'A', text: 'Luke Skywalker'),
          Option(id: 'B', text: 'Han Solo'),
          Option(id: 'C', text: 'Obi-Wan Kenobi'),
          Option(id: 'D', text: 'Darth Vader'),
        ],
        correctOptionId: 'B',
        explanation: 'Han Solo says "May the Force be with you" to Luke before the assault on the Death Star.',
        pointValue: 150,
      ),
      Question(
        id: 'q_002',
        category: 'Science & Cosmos',
        categoryEmoji: '🚀',
        difficulty: 'MEDIUM',
        questionText: 'Which planet in our solar system has the highest surface temperature?',
        quoteHighlight: '"Surface temperature reaches 867°F"',
        options: [
          Option(id: 'A', text: 'Mercury'),
          Option(id: 'B', text: 'Venus'),
          Option(id: 'C', text: 'Mars'),
          Option(id: 'D', text: 'Jupiter'),
        ],
        correctOptionId: 'B',
        explanation: 'Venus is the hottest planet due to its dense greenhouse-gas atmosphere trapping heat.',
        pointValue: 100,
      ),
    ];
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
