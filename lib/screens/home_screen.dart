import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onStartGame;
  final VoidCallback onContinueSession;
  final List<Player> players;
  final String? lastRemoteCommand;
  final String sessionId;
  final int totalQuestionsCount;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<String>? onSelectCategory;

  const HomeScreen({
    super.key,
    required this.onStartGame,
    required this.onContinueSession,
    required this.players,
    this.lastRemoteCommand,
    this.sessionId = 'session_live_4892',
    this.totalQuestionsCount = 32,
    this.categories = const [],
    this.onSelectCategory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int focusedActionIndex = 0; // 0: Start Game, 1: Continue Session, 2..: Quick modes

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;
      final maxActions = 2 + (widget.categories.isNotEmpty ? widget.categories.length.clamp(1, 4) : 4);

      if (cmd == 'LEFT' || cmd == 'UP') {
        setState(() {
          focusedActionIndex = (focusedActionIndex - 1 + maxActions) % maxActions;
        });
      } else if (cmd == 'RIGHT' || cmd == 'DOWN') {
        setState(() {
          focusedActionIndex = (focusedActionIndex + 1) % maxActions;
        });
      } else if (cmd == 'OK') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (focusedActionIndex == 0) {
            widget.onStartGame();
          } else if (focusedActionIndex == 1) {
            widget.onContinueSession();
          } else {
            final catIndex = focusedActionIndex - 2;
            if (widget.categories.isNotEmpty && catIndex < widget.categories.length) {
              final catName = widget.categories[catIndex]['name'] as String? ?? 'General Knowledge';
              widget.onSelectCategory?.call(catName);
            } else {
              widget.onStartGame();
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanSessionTag = widget.sessionId.replaceAll('session_', '').toUpperCase();

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
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, color: AppColors.secondary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'DATABASE SESSION #$cleanSessionTag ACTIVE',
                                  style: AppStyles.labelMd(color: AppColors.secondary),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldReady.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.emeraldReady.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.emeraldReady,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.totalQuestionsCount}+ DB Questions Live',
                                    style: AppStyles.labelMd(color: AppColors.emeraldReady),
                                  ),
                                ],
                              ),
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
                        // D-Pad Remote Focus Buttons
                        Wrap(
                          spacing: 20,
                          runSpacing: 16,
                          children: [
                            // 0: Start Game
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: focusedActionIndex == 0
                                    ? [
                                        BoxShadow(
                                          color: AppColors.secondary.withValues(alpha: 0.6),
                                          blurRadius: 25,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ElevatedButton(
                                onPressed: widget.onStartGame,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                                  backgroundColor: focusedActionIndex == 0 ? AppColors.surfaceHigh : AppColors.surfaceLowest,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: focusedActionIndex == 0 ? AppColors.secondary : AppColors.secondary.withValues(alpha: 0.5),
                                      width: focusedActionIndex == 0 ? 3 : 1.5,
                                    ),
                                  ),
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
                            ),
                            // 1: Continue Session
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: focusedActionIndex == 1
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.6),
                                          blurRadius: 25,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: OutlinedButton.icon(
                                onPressed: widget.onContinueSession,
                                icon: const Icon(Icons.history, color: AppColors.onSurfaceVariant),
                                label: Text(
                                  'CONTINUE SESSION',
                                  style: AppStyles.headlineMd(color: AppColors.onSurface),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                  side: BorderSide(
                                    color: focusedActionIndex == 1 ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.5),
                                    width: focusedActionIndex == 1 ? 3 : 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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
                                        Text('Supabase Live Engine', style: AppStyles.labelMd(color: AppColors.secondary), overflow: TextOverflow.ellipsis),
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
                                  Text('Online', style: AppStyles.labelMd()),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.outlineVariant, height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'ACTIVE PLAYERS (${widget.players.length})',
                                style: AppStyles.labelMd(color: AppColors.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('Remotes Synced', style: AppStyles.labelMd(color: AppColors.primary)),
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
                          children: widget.players.map((p) => _buildPlayerTile(p)).toList(),
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
                                  Text('Session: Dynamic', style: AppStyles.bodyMd()),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Text('Difficulty: Adaptive DB', style: AppStyles.labelMd(color: AppColors.secondary)),
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

            // QUICK MODES / DYNAMIC DATABASE CATEGORIES RAIL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SELECT EXPERIENCE', style: AppStyles.labelMd(color: AppColors.secondary)),
                    Text('Database Quiz Categories', style: AppStyles.headlineLg()),
                  ],
                ),
                Text('D-Pad: ◀ Left | Right ▶ • [OK] Select', style: AppStyles.labelMd(color: AppColors.onSurfaceVariant)),
              ],
            ),

            const SizedBox(height: 16),

            _buildDynamicCategoriesRail(),

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
                              Text('Oceanic Wonders & Space Odyssey', style: AppStyles.headlineLg()),
                              Text('5 min team challenge — Coordinate science and cinema trivia to unlock Atlantis Badge.', style: AppStyles.bodyLg()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: widget.onStartGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      backgroundColor: AppColors.surfaceHighest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Launch Mission [OK]', style: AppStyles.labelLg()),
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

  Widget _buildDynamicCategoriesRail() {
    final list = widget.categories.isNotEmpty
        ? widget.categories
        : [
            {'name': 'Cinema Clues', 'emoji': '🎬', 'questionCount': 7},
            {'name': 'Science & Cosmos', 'emoji': '🚀', 'questionCount': 7},
            {'name': 'Pop Culture & Music', 'emoji': '🎵', 'questionCount': 5},
            {'name': 'Animation & Family', 'emoji': '✨', 'questionCount': 5},
          ];

    final displayList = list.take(4).toList();

    return Row(
      children: displayList.asMap().entries.map((entry) {
        final idx = entry.key;
        final cat = entry.value;
        final name = cat['name'] as String? ?? 'General';
        final emoji = cat['emoji'] as String? ?? '🧠';
        final count = cat['questionCount'] as int? ?? 5;
        final isFocused = focusedActionIndex == (idx + 2);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: idx < displayList.length - 1 ? 16 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() => focusedActionIndex = idx + 2);
                widget.onSelectCategory?.call(name);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isFocused ? AppColors.surfaceHigh : AppColors.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFocused ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.3),
                    width: isFocused ? 2.5 : 1,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.5),
                            blurRadius: 20,
                          )
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 28)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$count Qs', style: AppStyles.labelMd(color: AppColors.secondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: AppStyles.headlineMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('Direct from Supabase database', style: AppStyles.bodyMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dynamic', style: AppStyles.bodyMd()),
                        Text(isFocused ? '[OK] Select' : 'Tap to Play', style: AppStyles.labelMd(color: isFocused ? AppColors.secondary : AppColors.outline)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
}
