import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/player.dart';

class ScoreboardWidget extends StatelessWidget {
  final List<Player> players;
  final String activePlayerId;

  const ScoreboardWidget({
    super.key,
    required this.players,
    required this.activePlayerId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('LIVE SCORES', style: AppTextStyles.labelMd(color: AppColors.outline)),
            ],
          ),
          Row(
            children: players.map((p) {
              final isActive = p.id == activePlayerId;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(radius: 5, backgroundColor: p.accentColor),
                    const SizedBox(width: 6),
                    Text('${p.name}: ', style: AppTextStyles.bodyMd()),
                    Text(
                      '${p.score}',
                      style: AppTextStyles.labelLg(
                        color: isActive ? AppColors.primary : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Row(
            children: [
              const Icon(Icons.wifi, color: AppColors.secondary, size: 18),
              const SizedBox(width: 6),
              Text('4 Remotes Active', style: AppTextStyles.bodyMd()),
            ],
          ),
        ],
      ),
    );
  }
}
