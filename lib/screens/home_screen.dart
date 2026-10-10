import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onStartGame;
  final VoidCallback onContinueSession;
  final List<Player> players;

  const HomeScreen({
    super.key,
    required this.onStartGame,
    required this.onContinueSession,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO ARENA
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left 8 Cols: Action Canvas & Headline
                Expanded(
                  flex: 8,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 25,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'PARTY SESSION #4892 ACTIVE',
                              style: AppStyles.labelMd(color: AppColors.secondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFFE9A8), Color(0xFFFFD76A), Color(0xFFD6A63D)],
                          ).createShader(bounds),
                          child: Text(
                            'ONE TV. EVERYONE PLAYS.',
                            style: AppStyles.displayHero(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Let the dynamic game engine craft an interactive session for the whole room.',
                          style: AppStyles.bodyXl(),
                        ),
                        const SizedBox(height: 32),
                        // D-Pad Remote Focus Button
                        Wrap(
                          spacing: 20,
                          runSpacing: 16,
                          children: [
                            ElevatedButton(
                              onPressed: onStartGame,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                                backgroundColor: AppColors.surfaceLowest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: AppColors.secondary.withValues(alpha: 0.8),
                                    width: 3,
                                  ),
                                ),
                                shadowColor: AppColors.secondary,
                                elevation: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'START A GAME',
                                    style: AppStyles.headlineMd(color: AppColors.onSurface),
                                  ),
                                  const SizedBox(width: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '[OK]',
                                      style: AppStyles.labelMd(color: AppColors.onSecondaryContainer),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: onContinueSession,
                              icon: const Icon(Icons.history, color: AppColors.onSurfaceVariant),
                              label: Text(
                                'CONTINUE SESSION',
                                style: AppStyles.headlineMd(color: AppColors.onSurface),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Right 4 Cols: AI Host Telemetry Card
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                      ),
                                    ),
                                    child: const Icon(Icons.graphic_eq, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('CORTEX-9', style: AppStyles.labelLg()),
                                        Text('Adaptive Co-Host', style: AppStyles.labelMd(color: AppColors.secondary), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.emeraldReady,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Live', style: AppStyles.labelMd()),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.outlineVariant, height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text('CONNECTED PLAYERS (4)', style: AppStyles.labelMd(color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
                            Text('Phones Synced', style: AppStyles.labelMd(color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.8,
                          physics: const NeverScrollableScrollPhysics(),
                          children: players.map((p) => _buildPlayerTile(p)).toList(),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.timelapse, size: 18, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Text('Session: 32 min', style: AppStyles.bodyMd()),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Text('Difficulty: Dynamic', style: AppStyles.labelMd(color: AppColors.secondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // QUICK MODES RAIL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SELECT EXPERIENCE', style: AppStyles.labelMd(color: AppColors.secondary)),
                    Text('Quick Modes', style: AppStyles.headlineLg()),
                  ],
                ),
                Text('D-Pad: ◀ Left | Right ▶', style: AppStyles.labelMd(color: AppColors.onSurfaceVariant)),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildModeCard('Knowledge Quiz', 'Adaptive trivia tailored for all ages.', Icons.psychology, 'Popular', '15 Min', AppColors.secondary),
                const SizedBox(width: 16),
                _buildModeCard('Cinema Quotes', 'Audio & scene challenges from blockbusters.', Icons.movie, 'Audio Clips', '10 Min', AppColors.tertiary),
                const SizedBox(width: 16),
                _buildModeCard('Wildcard Rounds', 'Real-time rule shifts and surprise swaps.', Icons.shuffle, 'AI Chaos', '20 Min', AppColors.primary),
                const SizedBox(width: 16),
                _buildModeCard('Smart Mix', 'Automated family trivia synthesis.', Icons.auto_fix_high, 'Curated', 'Custom', AppColors.onSurface),
              ],
            ),

            const SizedBox(height: 28),

            // DAILY CO-OP MISSION BANNER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surfaceHigh, AppColors.surface, AppColors.surfaceLow],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.sailing, color: AppColors.secondary, size: 36),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('DAILY CO-OP MISSION', style: AppStyles.labelMd(color: AppColors.onSecondaryContainer)),
                                  ),
                                  Text('🔥 4-Day Team Streak!', style: AppStyles.labelMd(color: AppColors.primary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Oceanic Wonders', style: AppStyles.headlineLg()),
                              Text('5 min team challenge — Coordinate deep sea trivia to unlock Atlantis Badge.', style: AppStyles.bodyLg()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      backgroundColor: AppColors.surfaceHighest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View Challenge', style: AppStyles.labelLg()),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Player p) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: p.accentColor,
            radius: 14,
            child: Icon(p.icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.name, style: AppStyles.labelMd(), overflow: TextOverflow.ellipsis),
                Text(p.isReady ? 'Ready' : 'Waiting', style: AppStyles.bodyMd(), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(String title, String desc, IconData icon, String tag, String duration, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(tag, style: AppStyles.labelMd(color: color)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: AppStyles.headlineMd()),
            const SizedBox(height: 6),
            Text(desc, style: AppStyles.bodyMd(), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('3-8 Players', style: AppStyles.bodyMd()),
                Text(duration, style: AppStyles.labelMd(color: AppColors.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
