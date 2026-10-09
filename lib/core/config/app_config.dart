class AppConfig {
  static const String appName = 'PlayTogether AI';
  static const String tagline = 'ONE TV. EVERYONE PLAYS.';
  static const String defaultHostCode = '8942';

  // Backend API URL (configurable)
  static String baseUrl = 'http://localhost:3000/api';

  static const int minPlayers = 2;
  static const int maxPlayers = 4;
  static const int defaultQuestionCount = 10;
  static const int defaultTimePerQuestion = 15; // seconds
}
