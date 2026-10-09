import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/player.dart';

class RoundIntroScreen extends StatelessWidget {
  final int roundNumber;
  final String category;
  final String difficulty;
  final List<Player> players;
  final VoidCallback onStartRound;

  const RoundIntroScreen({
    super.key,
    required this.roundNumber,
    required this.category,
    required this.difficulty,
    required this.players,
    required this.onStartRound,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
              ),
              child: Text('ROUND $roundNumber', style: AppTextStyles.labelLg(color: AppColors.secondary)),
            ),
            const SizedBox(height: 12),
            Text(category, style: AppTextStyles.heroTitle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Difficulty: $difficulty', style: AppTextStyles.bodyXl(color: AppColors.primary)),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: players.map((p) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: p.accentColor,
                        child: Icon(p.icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(p.name, style: AppTextStyles.labelMd(color: Colors.white)),
                      Text('${p.score} PTS', style: AppTextStyles.bodyMd()),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: onStartRound,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 22),
                backgroundColor: AppColors.primaryContainer,
                elevation: 12,
                shadowColor: AppColors.secondary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('START ROUND [OK]', style: AppTextStyles.headlineMd(color: Colors.white)),
                  const SizedBox(width: 12),
                  const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
