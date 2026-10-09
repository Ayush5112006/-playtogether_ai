class GameSettings {
  String difficulty; // "Easy", "Medium", "Hard", "Adaptive"
  int durationMinutes; // 5, 10, 15
  String category; // "General Trivia", "Movie Guess", "AI Wildcard", "Smart Mix"
  bool familyFriendly;

  GameSettings({
    this.difficulty = 'Adaptive',
    this.durationMinutes = 10,
    this.category = 'General Trivia',
    this.familyFriendly = true,
  });
}
