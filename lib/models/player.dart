import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class Player {
  final String id;
  String name;
  String avatarName;
  IconData icon;
  Color accentColor;
  int score;
  int streak;
  int correctCount;
  int totalAnswered;
  String roleTag;

  Player({
    required this.id,
    required this.name,
    required this.avatarName,
    required this.icon,
    required this.accentColor,
    this.score = 0,
    this.streak = 0,
    this.correctCount = 0,
    this.totalAnswered = 0,
    this.roleTag = 'Player',
  });

  double get accuracy => totalAnswered == 0 ? 0.0 : (correctCount / totalAnswered) * 100;

  bool get isReady => true;
  String get deviceName => 'Fire TV Remote #1';
  String get teamName => name;

  Map<String, dynamic> toSessionMap() => {
    'id': id,
    'name': name,
    'avatarName': avatarName,
  };

  static List<Player> getDefaultPlayers() {
    return [
      Player(
        id: 'p1',
        name: 'Mom',
        avatarName: 'Mom',
        icon: Icons.face_3,
        accentColor: AppColors.tertiary,
        score: 390,
        streak: 2,
        correctCount: 5,
        totalAnswered: 10,
        roleTag: 'Trivia Anchor',
      ),
      Player(
        id: 'p2',
        name: 'Dad',
        avatarName: 'Dad',
        icon: Icons.face_6,
        accentColor: AppColors.secondary,
        score: 420,
        streak: 1,
        correctCount: 6,
        totalAnswered: 10,
        roleTag: 'Biggest Comeback',
      ),
      Player(
        id: 'p3',
        name: 'Maya',
        avatarName: 'Maya',
        icon: Icons.smart_toy,
        accentColor: AppColors.primary,
        score: 520,
        streak: 4,
        correctCount: 8,
        totalAnswered: 10,
        roleTag: 'Streak Leader',
      ),
      Player(
        id: 'p4',
        name: 'Aarav',
        avatarName: 'Aarav',
        icon: Icons.sentiment_very_satisfied,
        accentColor: AppColors.goldAccent,
        score: 470,
        streak: 3,
        correctCount: 7,
        totalAnswered: 10,
        roleTag: 'Science Prodigy',
      ),
    ];
  }
}
