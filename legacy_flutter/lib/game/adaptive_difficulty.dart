enum DifficultyLevel { easy, medium, hard }

class AdaptiveDifficultyEngine {
  DifficultyLevel currentLevel;
  int consecutiveCorrect;
  int consecutiveIncorrect;
  String? lastReason;

  AdaptiveDifficultyEngine({
    this.currentLevel = DifficultyLevel.medium,
    this.consecutiveCorrect = 0,
    this.consecutiveIncorrect = 0,
  });

  String get currentDifficultyString {
    switch (currentLevel) {
      case DifficultyLevel.easy:
        return 'EASY';
      case DifficultyLevel.medium:
        return 'MEDIUM';
      case DifficultyLevel.hard:
        return 'HARD';
    }
  }

  bool registerAnswer({required bool isCorrect}) {
    bool changed = false;
    lastReason = null;

    if (isCorrect) {
      consecutiveCorrect++;
      consecutiveIncorrect = 0;

      if (consecutiveCorrect >= 2 && currentLevel != DifficultyLevel.hard) {
        if (currentLevel == DifficultyLevel.easy) {
          currentLevel = DifficultyLevel.medium;
          lastReason = "You're building great momentum! Shifting difficulty to Medium.";
        } else if (currentLevel == DifficultyLevel.medium) {
          currentLevel = DifficultyLevel.hard;
          lastReason = "You're on fire! The next challenge is getting harder (Hard).";
        }
        consecutiveCorrect = 0;
        changed = true;
      }
    } else {
      consecutiveIncorrect++;
      consecutiveCorrect = 0;

      if (consecutiveIncorrect >= 2 && currentLevel != DifficultyLevel.easy) {
        if (currentLevel == DifficultyLevel.hard) {
          currentLevel = DifficultyLevel.medium;
          lastReason = "Let's tune the pace. Shifting difficulty back to Medium.";
        } else if (currentLevel == DifficultyLevel.medium) {
          currentLevel = DifficultyLevel.easy;
          lastReason = "Let's build momentum! The next question will be a little easier (Easy).";
        }
        consecutiveIncorrect = 0;
        changed = true;
      }
    }

    return changed;
  }
}
