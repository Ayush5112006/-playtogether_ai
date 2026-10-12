enum DifficultyLevel { EASY, MEDIUM, HARD }

class AdaptiveDifficultyEngine {
  DifficultyLevel currentLevel;
  int consecutiveCorrect;
  int consecutiveIncorrect;
  String? lastReason;

  AdaptiveDifficultyEngine({
    this.currentLevel = DifficultyLevel.MEDIUM,
    this.consecutiveCorrect = 0,
    this.consecutiveIncorrect = 0,
  });

  String get currentDifficultyString {
    switch (currentLevel) {
      case DifficultyLevel.EASY:
        return 'EASY';
      case DifficultyLevel.MEDIUM:
        return 'MEDIUM';
      case DifficultyLevel.HARD:
        return 'HARD';
    }
  }

  bool registerAnswer({required bool isCorrect}) {
    bool changed = false;
    lastReason = null;

    if (isCorrect) {
      consecutiveCorrect++;
      consecutiveIncorrect = 0;

      if (consecutiveCorrect >= 2 && currentLevel != DifficultyLevel.HARD) {
        if (currentLevel == DifficultyLevel.EASY) {
          currentLevel = DifficultyLevel.MEDIUM;
          lastReason = "You're building great momentum! Shifting difficulty to Medium.";
        } else if (currentLevel == DifficultyLevel.MEDIUM) {
          currentLevel = DifficultyLevel.HARD;
          lastReason = "You're on fire! The next challenge is getting harder (Hard).";
        }
        consecutiveCorrect = 0;
        changed = true;
      }
    } else {
      consecutiveIncorrect++;
      consecutiveCorrect = 0;

      if (consecutiveIncorrect >= 2 && currentLevel != DifficultyLevel.EASY) {
        if (currentLevel == DifficultyLevel.HARD) {
          currentLevel = DifficultyLevel.MEDIUM;
          lastReason = "Let's tune the pace. Shifting difficulty back to Medium.";
        } else if (currentLevel == DifficultyLevel.MEDIUM) {
          currentLevel = DifficultyLevel.EASY;
          lastReason = "Let's build momentum! The next question will be a little easier (Easy).";
        }
        consecutiveIncorrect = 0;
        changed = true;
      }
    }

    return changed;
  }
}
