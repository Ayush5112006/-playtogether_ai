import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';

class WinnerRecapScreen extends StatelessWidget {
  final List<Player> players;
  final VoidCallback onPlayAgain;
  final VoidCallback onReturnHub;

  const WinnerRecapScreen({
    super.key,
    required this.players,
    required this.onPlayAgain,
    required this.onReturnHub,
  });

  @override
  Widget build(BuildContext context) {
    // Sort players by score descending
    final sorted = List<Player>.from(players)..sort((a, b) => b.score.compareTo(a.score));
    final winner = sorted.isNotEmpty ? sorted.first : players.first;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left 7 Cols: Winner Spotlight & Podium
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Winner Spotlight Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLowest.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 40,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Trophy Emblem
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.amberWarning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.amberWarning.withValues(alpha: 0.6), width: 2),
                            ),
                            child: const Icon(Icons.emoji_events, color: AppColors.amberWarning, size: 64),
                          ),
                          const SizedBox(width: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AND THE WINNER IS...', style: AppStyles.labelMd(color: AppColors.secondary)),
                              Text(winner.name.toUpperCase(), style: AppStyles.displayHero(color: Colors.white)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text('8/10 Correct', style: AppStyles.labelMd(color: AppColors.secondary)),
                                  const SizedBox(width: 12),
                                  Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                                  const SizedBox(width: 12),
                                  Text('4x Best Streak', style: AppStyles.labelMd(color: AppColors.primary)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('920', style: AppStyles.displayHero(color: AppColors.primary)),
                          Text('POINTS', style: AppStyles.labelLg(color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text('Family Podium Standings', style: AppStyles.labelLg(color: AppColors.onSurfaceVariant)),

                const SizedBox(height: 10),

                // Standings List
                Column(
                  children: sorted.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final p = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text('$rank', style: AppStyles.labelLg(color: AppColors.onSurfaceVariant)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                CircleAvatar(
                                  backgroundColor: p.accentColor.withValues(alpha: 0.2),
                                  child: Icon(p.icon, color: p.accentColor, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(p.name, style: AppStyles.headlineMd(color: Colors.white)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: p.accentColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(p.roleTag, style: AppStyles.labelMd(color: p.accentColor)),
                                        ),
                                      ],
                                    ),
                                    Text('${p.correctCount}/10 Correct Answers', style: AppStyles.bodyMd()),
                                  ],
                                ),
                              ],
                            ),
                            Text('${p.score} PTS', style: AppStyles.headlineMd(color: p.accentColor)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Right 5 Cols: AI Post-Game Insights & CTAs
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology, color: AppColors.secondary, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CORTEX-9 AI HOST', style: AppStyles.labelMd(color: AppColors.primary)),
                              Text('Post-Game Insight & Recommendation', style: AppStyles.bodyMd()),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.outlineVariant, height: 24),
                      Text(
                        '"Your family excelled at 90s cinema and science trivia! Next game suggestion: Space & Soundtracks with adaptive team co-op."',
                        style: AppStyles.bodyLg(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Family Synergy', style: AppStyles.bodyMd()),
                                  Text('94%', style: AppStyles.headlineLg(color: AppColors.secondary)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Speed Index', style: AppStyles.bodyMd()),
                                  Text('1.9s', style: AppStyles.headlineLg(color: AppColors.tertiary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CTA Buttons Stack
                ElevatedButton(
                  onPressed: onPlayAgain,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: AppColors.secondaryContainer,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 12,
                    shadowColor: AppColors.secondary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text('PLAY AGAIN [OK]', style: AppStyles.headlineMd(color: Colors.white)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: onReturnHub,
                  icon: const Icon(Icons.home, color: AppColors.onSurfaceVariant),
                  label: Text('Return to Party Hub', style: AppStyles.headlineMd(color: AppColors.onSurface)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    minimumSize: const Size(double.infinity, 60),
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
