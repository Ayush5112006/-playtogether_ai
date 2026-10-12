class GameSettings {
  String difficulty; // "EASY", "MEDIUM", "HARD", "ADAPTIVE"
  int durationMinutes; // 5, 10, 15
  int questionCount; // 5, 10, 15
  int timerSeconds; // 10, 15, 20, 30
  String category;
  bool familyFriendly;
  bool adaptiveHandicap; // AI rebalancing for younger/trailing players
  bool wildcardRound; // Surprise double-point buzzer round
  bool aiVoiceHost; // CORTEX-9 spoken commentary
  bool soundEffects; // Buzzers, ticking & fanfare
  bool ambientMusic; // Living room ambient audio
  String aiPersona; // "Playful Host", "Game Show Host", "Strict Master"

  GameSettings({
    this.difficulty = 'ADAPTIVE',
    this.durationMinutes = 10,
    this.questionCount = 10,
    this.timerSeconds = 15,
    this.category = 'Cinema Clues',
    this.familyFriendly = true,
    this.adaptiveHandicap = true,
    this.wildcardRound = true,
    this.aiVoiceHost = true,
    this.soundEffects = true,
    this.ambientMusic = true,
    this.aiPersona = 'Playful Host',
  });

  GameSettings copyWith({
    String? difficulty,
    int? durationMinutes,
    int? questionCount,
    int? timerSeconds,
    String? category,
    bool? familyFriendly,
    bool? adaptiveHandicap,
    bool? wildcardRound,
    bool? aiVoiceHost,
    bool? soundEffects,
    bool? ambientMusic,
    String? aiPersona,
  }) {
    return GameSettings(
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      questionCount: questionCount ?? this.questionCount,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      category: category ?? this.category,
      familyFriendly: familyFriendly ?? this.familyFriendly,
      adaptiveHandicap: adaptiveHandicap ?? this.adaptiveHandicap,
      wildcardRound: wildcardRound ?? this.wildcardRound,
      aiVoiceHost: aiVoiceHost ?? this.aiVoiceHost,
      soundEffects: soundEffects ?? this.soundEffects,
      ambientMusic: ambientMusic ?? this.ambientMusic,
      aiPersona: aiPersona ?? this.aiPersona,
    );
  }
}
