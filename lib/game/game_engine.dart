import '../models/player.dart';
import '../models/question.dart';
import '../models/game_settings.dart';
import 'score_calculator.dart';
import 'adaptive_difficulty.dart';
import '../services/local_question_service.dart';

enum GameState {
  SPLASH,
  HOME,
  PLAYER_SETUP,
  PLAYER_PICKER,
  GAME_MODE,
  GAME_SETTINGS,
  GAME_CREATION,
  ROUND_INTRO,
  QUESTION,
  ANSWER_RESULT,
  SCORE_UPDATE,
  AI_ADAPTATION,
  SURPRISE_ROUND,
  FINAL_ROUND,
  WINNER,
  RECAP
}

class GameEngine {
  GameState currentState = GameState.HOME;
  List<Player> players = [];
  GameSettings settings = GameSettings();
  List<Question> questions = [];

  int currentQuestionIndex = 0;
  int currentRound = 1;
  int activePlayerIndex = 0;
  Option? selectedOption;
  bool isAnswerSubmitted = false;
  bool isLastAnswerCorrect = false;
  int lastPointsEarned = 0;
  String? adaptationReason;

  final AdaptiveDifficultyEngine adaptiveEngine = AdaptiveDifficultyEngine();

  GameEngine() {
    players = Player.getDefaultPlayers();
    questions = LocalQuestionService.getFallbackQuestions();
  }

  Player get activePlayer => players[activePlayerIndex % players.length];

  Question get currentQuestion =>
      questions[currentQuestionIndex % questions.length];

  void addPlayer(Player player) {
    if (players.length < 4) {
      players.add(player);
    }
  }

  void removePlayer(String playerId) {
    if (players.length > 2) {
      players.removeWhere((p) => p.id == playerId);
    }
  }

  void startNewGame() {
    currentQuestionIndex = 0;
    currentRound = 1;
    activePlayerIndex = 0;
    for (var p in players) {
      p.score = 0;
      p.streak = 0;
      p.correctCount = 0;
      p.totalAnswered = 0;
    }
  }

  bool submitAnswer(Option option, {int remainingSeconds = 15}) {
    if (isAnswerSubmitted) return isLastAnswerCorrect;

    selectedOption = option;
    isAnswerSubmitted = true;
    final q = currentQuestion;
    isLastAnswerCorrect = (option.id == q.correctOptionId);

    activePlayer.totalAnswered++;

    if (isLastAnswerCorrect) {
      activePlayer.correctCount++;
      activePlayer.streak++;
      lastPointsEarned = ScoreCalculator.calculateScore(
        isCorrect: true,
        baseValue: q.pointValue,
        streak: activePlayer.streak,
        isBonusRound: currentState == GameState.SURPRISE_ROUND,
        remainingSeconds: remainingSeconds,
      );
      activePlayer.score += lastPointsEarned;
    } else {
      activePlayer.streak = 0;
      lastPointsEarned = 0;
    }

    if (settings.difficulty == 'Adaptive') {
      final changed = adaptiveEngine.registerAnswer(isCorrect: isLastAnswerCorrect);
      if (changed) {
        adaptationReason = adaptiveEngine.lastReason;
      } else {
        adaptationReason = null;
      }
    }

    return isLastAnswerCorrect;
  }

  void nextQuestion() {
    isAnswerSubmitted = false;
    selectedOption = null;
    activePlayerIndex++;
    currentQuestionIndex++;
  }

  Player getWinner() {
    final sorted = List<Player>.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));
    return sorted.first;
  }

  List<Player> getStandings() {
    final sorted = List<Player>.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }
}
