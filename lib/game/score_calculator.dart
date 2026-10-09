class ScoreCalculator {
  static const int baseTriviaPoints = 100;
  static const int bonusRoundPoints = 300;
  static const int streakBonusMultiplier = 25; // +25 points per streak count

  static int calculateScore({
    required bool isCorrect,
    required int baseValue,
    required int streak,
    bool isBonusRound = false,
    int remainingSeconds = 15,
  }) {
    if (!isCorrect) return 0;

    int points = isBonusRound ? bonusRoundPoints : (baseValue > 0 ? baseValue : baseTriviaPoints);

    // Speed bonus (+50 if answered under 5 seconds)
    if (remainingSeconds >= 10) {
      points += 50;
    }

    // Streak bonus
    if (streak > 1) {
      points += (streak * streakBonusMultiplier);
    }

    return points;
  }
}
