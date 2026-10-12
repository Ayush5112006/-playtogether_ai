import 'player.dart';

class SessionRecap {
  final Player winner;
  final List<Player> standings;
  final String hostInsightText;
  final String familySynergyPercent;
  final String avgSpeedSec;
  final String nextGameRecommendation;

  SessionRecap({
    required this.winner,
    required this.standings,
    required this.hostInsightText,
    required this.familySynergyPercent,
    required this.avgSpeedSec,
    required this.nextGameRecommendation,
  });
}
