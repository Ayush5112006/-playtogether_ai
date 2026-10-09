import '../models/question.dart';

class LocalQuestionService {
  static List<Question> getFallbackQuestions() {
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
      Question(
        id: 'q_003',
        category: 'Pop Culture & Music',
        categoryEmoji: '🎵',
        difficulty: 'EASY',
        questionText: 'Which famous band performed an impromptu concert on the roof of Apple Records in 1969?',
        quoteHighlight: '"Get Back to where you once belonged"',
        options: [
          Option(id: 'A', text: 'The Rolling Stones'),
          Option(id: 'B', text: 'The Beatles'),
          Option(id: 'C', text: 'Queen'),
          Option(id: 'D', text: 'Led Zeppelin'),
        ],
        correctOptionId: 'B',
        explanation: 'The Beatles gave their final public performance on the roof of Apple Corps in London.',
        pointValue: 100,
      ),
      Question(
        id: 'q_004',
        category: 'Surprise Buzzer Blitz',
        categoryEmoji: '⚡',
        difficulty: 'HARD',
        questionText: 'Which mammal has a bite force exceeding 1,200 PSI?',
        quoteHighlight: '"Surprise Double Points Round!"',
        options: [
          Option(id: 'A', text: 'Grizzly Bear'),
          Option(id: 'B', text: 'Hippopotamus'),
          Option(id: 'C', text: 'African Lion'),
          Option(id: 'D', text: 'Jaguar'),
        ],
        correctOptionId: 'B',
        explanation: 'Hippos possess one of the strongest bite forces recorded among land mammals.',
        pointValue: 300,
      ),
      Question(
        id: 'q_005',
        category: 'Animation & Family',
        categoryEmoji: '✨',
        difficulty: 'EASY',
        questionText: 'In Disney\'s Toy Story, what is the name of Woody\'s dog?',
        quoteHighlight: '"You\'ve got a friend in me"',
        options: [
          Option(id: 'A', text: 'Slinky'),
          Option(id: 'B', text: 'Buster'),
          Option(id: 'C', text: 'Rex'),
          Option(id: 'D', text: 'Scud'),
        ],
        correctOptionId: 'B',
        explanation: 'Buster is Andy\'s real pet Dachshund who obeys Woody\'s commands.',
        pointValue: 100,
      ),
    ];
  }
}
