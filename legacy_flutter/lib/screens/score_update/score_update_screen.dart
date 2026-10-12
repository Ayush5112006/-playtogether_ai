import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/player.dart';

class ScoreUpdateScreen extends StatelessWidget {
  final List<Player> standings;
  final VoidCallback onContinue;

  const ScoreUpdateScreen({
    super.key,
    required this.standings,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        children: [
          Text('ROUND STANDINGS', style: AppTextStyles.labelLg(color: AppColors.secondary)),
          const SizedBox(height: 6),
          Text('Leaderboard Update', style: AppTextStyles.headlineLg()),

          const SizedBox(height: 28),

          Column(
            children: standings.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final p = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.accentColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('#$rank', style: AppTextStyles.headlineMd(color: AppColors.secondary)),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          backgroundColor: p.accentColor,
                          child: Icon(p.icon, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: AppTextStyles.headlineMd(color: Colors.white)),
                            Text('${p.streak}x Active Streak', style: AppTextStyles.bodyMd(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                    Text('${p.score} PTS', style: AppTextStyles.displayLg(color: p.accentColor)),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 20),
              backgroundColor: AppColors.primaryContainer,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NEXT QUESTION [OK]', style: AppTextStyles.headlineMd(color: Colors.white)),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
