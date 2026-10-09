import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Player {
  final String id;
  String name;
  String teamName;
  String roleTag;
  IconData icon;
  Color accentColor;
  bool isReady;
  int score;
  int streak;
  String deviceName;
  int correctCount;
  int totalAnswered;

  Player({
    required this.id,
    required this.name,
    required this.teamName,
    required this.roleTag,
    required this.icon,
    required this.accentColor,
    this.isReady = true,
    this.score = 0,
    this.streak = 0,
    required this.deviceName,
    this.correctCount = 0,
    this.totalAnswered = 0,
  });

  static List<Player> getDefaultPlayers() {
    return [
      Player(
        id: 'p1',
        name: 'Mom',
        teamName: 'Team Magenta',
        roleTag: 'Trivia Anchor',
        icon: Icons.face_3,
        accentColor: AppColors.tertiary,
        isReady: true,
        score: 390,
        streak: 2,
        deviceName: 'Remote 1',
        correctCount: 5,
        totalAnswered: 10,
      ),
      Player(
        id: 'p2',
        name: 'Dad',
        teamName: 'Team Cyan',
        roleTag: 'Biggest Comeback',
        icon: Icons.face_6,
        accentColor: AppColors.secondary,
        isReady: true,
        score: 420,
        streak: 1,
        deviceName: 'Remote 2',
        correctCount: 6,
        totalAnswered: 10,
      ),
      Player(
        id: 'p3',
        name: 'Maya',
        teamName: 'Captain • Team Violet',
        roleTag: 'Streak Leader',
        icon: Icons.smart_toy,
        accentColor: AppColors.primary,
        isReady: true,
        score: 520,
        streak: 4,
        deviceName: 'Phone App',
        correctCount: 8,
        totalAnswered: 10,
      ),
      Player(
        id: 'p4',
        name: 'Aarav',
        teamName: 'Team Amber',
        roleTag: 'Science Prodigy',
        icon: Icons.sentiment_very_satisfied,
        accentColor: AppColors.amberWarning,
        isReady: true,
        score: 470,
        streak: 3,
        deviceName: 'Remote 4',
        correctCount: 7,
        totalAnswered: 10,
      ),
    ];
  }
}
