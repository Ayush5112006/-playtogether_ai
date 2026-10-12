class AppConfig {
  static const String appName = 'PlayTogether AI';
  static const String tagline = 'ONE TV. EVERYONE PLAYS.';
  static const String defaultHostCode = '8942';

  // Live Cloud Supabase URL
  static const String supabaseUrl = 'https://xwgslqfpymsysastllnk.supabase.co';

  // Game Master Backend API URL (Express server connected to Live Cloud Supabase)
  // When testing on TV or physical Android device, change 'localhost' to your PC IP (e.g., http://10.45.142.200:3000/api)
  static String baseUrl = 'http://localhost:3000/api';

  static const int minPlayers = 2;
  static const int maxPlayers = 4;
  static const int defaultQuestionCount = 10;
  static const int defaultTimePerQuestion = 15; // seconds
}
