class Question {
  final String id;
  final String category;
  final String categoryEmoji;
  final String questionText;
  final String quoteHighlight;
  final List<String> options; // [Left, Up, Down, Right]
  final int correctIndex;
  final int points;
  final String hintText;

  Question({
    required this.id,
    required this.category,
    required this.categoryEmoji,
    required this.questionText,
    this.quoteHighlight = '',
    required this.options,
    required this.correctIndex,
    required this.points,
    required this.hintText,
  });

  static List<Question> getSampleQuestions() {
    return [
      Question(
        id: 'q1',
        category: 'Cinema Clues',
        categoryEmoji: '🎬',
        questionText: 'Which movie character is famous for the line:',
        quoteHighlight: '"May the Force be with you"',
        options: ['Luke Skywalker', 'Han Solo', 'Obi-Wan Kenobi', 'Darth Vader'],
        correctIndex: 1, // Han Solo
        points: 150,
        hintText: 'A famous space smuggler and pilot of the Millennium Falcon.',
      ),
      Question(
        id: 'q2',
        category: 'Science & Cosmos',
        categoryEmoji: '🚀',
        questionText: 'What is the hottest planet in our solar system?',
        quoteHighlight: '"Surface temperature exceeds 860°F"',
        options: ['Mercury', 'Venus', 'Mars', 'Jupiter'],
        correctIndex: 1, // Venus
        points: 200,
        hintText: 'Its dense atmosphere traps heat in a runaway greenhouse effect.',
      ),
      Question(
        id: 'q3',
        category: 'Pop Culture & Music',
        categoryEmoji: '🎵',
        questionText: 'Which legendary band performed live on the roof of Apple Records in 1969?',
        quoteHighlight: '"Get Back to where you once belonged"',
        options: ['The Rolling Stones', 'The Beatles', 'Queen', 'Led Zeppelin'],
        correctIndex: 1, // The Beatles
        points: 180,
        hintText: 'The iconic Fab Four from Liverpool.',
      ),
      Question(
        id: 'q4',
        category: 'Wildcard Buzzer Blitz',
        categoryEmoji: '⚡',
        questionText: 'Which mammal is known to have the powerful bite force of over 1,000 PSI?',
        quoteHighlight: '"Surprise Double Points Round!"',
        options: ['Grizzly Bear', 'Hippopotamus', 'Lion', 'Jaguar'],
        correctIndex: 1, // Hippopotamus
        points: 300,
        hintText: 'Native to Sub-Saharan Africa, loves freshwater lakes and rivers.',
      ),
    ];
  }
}
