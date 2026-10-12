import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/player.dart';

class FinalRoundScreen extends StatelessWidget {
  final List<Player> standings;
  final VoidCallback onStartFinal;

  const FinalRoundScreen({
    super.key,
    required this.standings,
    required this.onStartFinal,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldAccent),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: AppColors.goldAccent, size: 20),
                const SizedBox(width: 8),
                Text('THE FINAL SHOWDOWN', style: AppTextStyles.labelMd(color: AppColors.goldAccent)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('FINAL ROUND — DOUBLE STAKES!', style: AppTextStyles.heroTitle(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            '500 Bonus Points available on the final question. Anyone can still win!',
            style: AppTextStyles.bodyXl(color: AppColors.secondary),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: standings.map((p) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.accentColor),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: p.accentColor,
                      child: Icon(p.icon, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 10),
                    Text(p.name, style: AppTextStyles.headlineMd(color: Colors.white)),
                    Text('${p.score} PTS', style: AppTextStyles.labelLg(color: p.accentColor)),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: onStartFinal,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 22),
              backgroundColor: AppColors.goldContainer,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ENTER FINAL QUESTION [OK]', style: AppTextStyles.headlineMd(color: Colors.white)),
                const SizedBox(width: 12),
                const Icon(Icons.bolt, color: AppColors.goldAccent, size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
