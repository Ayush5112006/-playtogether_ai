import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';
import '../services/api_service.dart';

class WinnerRecapScreen extends StatefulWidget {
  final List<Player> players;
  final VoidCallback onPlayAgain;
  final VoidCallback onReturnHub;
  final String? lastRemoteCommand;
  final String sessionId;

  const WinnerRecapScreen({
    super.key,
    required this.players,
    required this.onPlayAgain,
    required this.onReturnHub,
    this.lastRemoteCommand,
    this.sessionId = 'session_live_4892',
  });

  @override
  State<WinnerRecapScreen> createState() => _WinnerRecapScreenState();
}

class _WinnerRecapScreenState extends State<WinnerRecapScreen> {
  int focusedCtaIndex = 0; // 0: Play Again, 1: Return to Hub
  Map<String, dynamic>? dynamicRecap;
  bool isLoadingRecap = true;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadRecap();
  }

  Future<void> _loadRecap() async {
    final recap = await _apiService.fetchRecap(widget.sessionId);
    if (mounted) {
      setState(() {
        dynamicRecap = recap;
        isLoadingRecap = false;
      });
    }
  }

  @override
  void didUpdateWidget(WinnerRecapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;

      if (cmd == 'LEFT' || cmd == 'UP') {
        setState(() => focusedCtaIndex = 0);
      } else if (cmd == 'RIGHT' || cmd == 'DOWN') {
        setState(() => focusedCtaIndex = 1);
      } else if (cmd == 'OK') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (focusedCtaIndex == 0) {
            widget.onPlayAgain();
          } else {
            widget.onReturnHub();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort players by score descending to get true winner
    final sorted = List<Player>.from(widget.players)..sort((a, b) => b.score.compareTo(a.score));
    final winner = sorted.isNotEmpty ? sorted.first : widget.players.first;

    final hostInsight = dynamicRecap?['hostInsight'] as String? ??
        '"Sensational team play! Your family excelled at Cinema & Science trivia. Next game suggestion: Space & Soundtracks with adaptive team co-op."';
    final synergy = dynamicRecap?['familySynergyPercent']?.toString() ?? '96%';
    final speed = dynamicRecap?['avgSpeedSec']?.toString() ?? '1.8s';
    final recommendation = dynamicRecap?['nextGameRecommendation'] as String? ?? 'Space & Soundtracks';

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
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
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
                                  Text('${winner.correctCount} Correct', style: AppStyles.labelMd(color: AppColors.secondary)),
                                  const SizedBox(width: 12),
                                  const Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                                  const SizedBox(width: 12),
                                  Text('${winner.streak}x Peak Streak', style: AppStyles.labelMd(color: AppColors.primary)),
                                  const SizedBox(width: 12),
                                  const Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                                  const SizedBox(width: 12),
                                  Text(winner.roleTag, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${winner.score}', style: AppStyles.displayHero(color: AppColors.primary)),
                          Text('POINTS', style: AppStyles.labelLg(color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text('Family Podium Standings (Database Session)', style: AppStyles.labelLg(color: AppColors.onSurfaceVariant)),

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
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: rank == 1
                                        ? AppColors.amberWarning.withValues(alpha: 0.2)
                                        : (rank == 2 ? Colors.grey.withValues(alpha: 0.2) : Colors.brown.withValues(alpha: 0.2)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text('#$rank', style: AppStyles.labelMd(color: rank == 1 ? AppColors.amberWarning : Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                CircleAvatar(backgroundColor: p.accentColor, radius: 14, child: Icon(p.icon, size: 16, color: Colors.white)),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(p.name, style: AppStyles.headlineMd()),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: p.accentColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(p.roleTag, style: AppStyles.labelMd(color: p.accentColor)),
                                        ),
                                      ],
                                    ),
                                    Text('${p.correctCount} Correct Answers', style: AppStyles.bodyMd()),
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
                              Text('Supabase Database Session Insights', style: AppStyles.bodyMd()),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.outlineVariant, height: 24),
                      if (isLoadingRecap)
                        const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: AppColors.secondary)))
                      else
                        Text(
                          hostInsight,
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
                                  Text(synergy, style: AppStyles.headlineLg(color: AppColors.secondary)),
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
                                  Text('Avg Speed', style: AppStyles.bodyMd()),
                                  Text(speed, style: AppStyles.headlineLg(color: AppColors.tertiary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.recommend, color: AppColors.secondary, size: 18),
                            const SizedBox(width: 8),
                            Text('Next Game: $recommendation', style: AppStyles.labelMd(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CTA Buttons Stack with D-Pad focus indicators
                Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: focusedCtaIndex == 0
                              ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.6), blurRadius: 25)]
                              : [],
                        ),
                        child: ElevatedButton(
                          onPressed: widget.onPlayAgain,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: focusedCtaIndex == 0 ? AppColors.secondaryContainer : AppColors.primaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: focusedCtaIndex == 0 ? AppColors.secondary : Colors.transparent, width: 2),
                            ),
                          ),
                          child: Text('PLAY AGAIN [OK]', style: AppStyles.headlineMd(color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: focusedCtaIndex == 1
                              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.6), blurRadius: 25)]
                              : [],
                        ),
                        child: OutlinedButton(
                          onPressed: widget.onReturnHub,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            side: BorderSide(
                              color: focusedCtaIndex == 1 ? AppColors.primary : AppColors.outlineVariant,
                              width: focusedCtaIndex == 1 ? 2.5 : 1,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('RETURN TO HUB', style: AppStyles.headlineMd(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
