import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';

class PlayerSetupScreen extends StatefulWidget {
  final List<Player> players;
  final VoidCallback onContinue;
  final ValueChanged<int> onFocusPlayerChanged;
  final String? lastRemoteCommand;
  final VoidCallback? onAddPlayer;

  const PlayerSetupScreen({
    super.key,
    required this.players,
    required this.onContinue,
    required this.onFocusPlayerChanged,
    this.lastRemoteCommand,
    this.onAddPlayer,
  });

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int focusedIndex = 0; // Focus on first player by default
  bool isContinueFocused = false;

  @override
  void didUpdateWidget(PlayerSetupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;

      if (cmd == 'LEFT') {
        setState(() {
          isContinueFocused = false;
          focusedIndex = (focusedIndex - 1 + widget.players.length) % widget.players.length;
        });
        widget.onFocusPlayerChanged(focusedIndex);
      } else if (cmd == 'RIGHT') {
        setState(() {
          isContinueFocused = false;
          focusedIndex = (focusedIndex + 1) % widget.players.length;
        });
        widget.onFocusPlayerChanged(focusedIndex);
      } else if (cmd == 'DOWN') {
        setState(() {
          isContinueFocused = true;
        });
      } else if (cmd == 'UP') {
        setState(() {
          isContinueFocused = false;
        });
      } else if (cmd == 'OK') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (isContinueFocused) {
            widget.onContinue();
          } else {
            _showEditNameDialog(focusedIndex);
          }
        });
      } else if (cmd == 'MIC') {
        _showEditNameDialog(focusedIndex);
      }
    }
  }

  void _showEditNameDialog(int index) {
    if (index >= widget.players.length) return;
    final player = widget.players[index];
    final controller = TextEditingController(text: player.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        title: Row(
          children: [
            CircleAvatar(backgroundColor: player.accentColor, radius: 14, child: Icon(player.icon, size: 16, color: Colors.white)),
            const SizedBox(width: 10),
            Text('Edit Player Name', style: AppStyles.headlineMd()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter new dynamic name for database session:', style: AppStyles.bodyMd()),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceLowest,
                hintText: 'Player Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppStyles.labelMd(color: AppColors.outline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryContainer),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  player.name = controller.text.trim();
                  player.avatarName = controller.text.trim();
                });
              }
              Navigator.pop(ctx);
            },
            child: Text('Save [OK]', style: AppStyles.labelMd(color: AppColors.onSecondaryContainer)),
          ),
        ],
      ),
    );
  }

  void _addGuestPlayer() {
    if (widget.players.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 6 players per party session.')),
      );
      return;
    }

    final newIdx = widget.players.length + 1;
    final colors = [AppColors.secondary, AppColors.tertiary, AppColors.primary, AppColors.amberWarning, AppColors.emeraldReady];
    final color = colors[newIdx % colors.length];

    setState(() {
      widget.players.add(
        Player(
          id: 'p$newIdx',
          name: 'Player $newIdx',
          avatarName: 'Player $newIdx',
          icon: Icons.person,
          accentColor: color,
          score: 0,
          roleTag: 'Challenger',
        ),
      );
      focusedIndex = widget.players.length - 1;
    });
  }

  void _randomizeTeams() {
    setState(() {
      for (final p in widget.players) {
        final roles = ['Trivia Anchor', 'Speed Demon', 'Wildcard King', 'Brainiac', 'Buzzer Master'];
        roles.shuffle();
        p.roleTag = roles.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Who\'s playing?', style: AppStyles.headlineXl()),
                      const SizedBox(width: 12),
                      Text('(${widget.players.length} players synced with DB)', style: AppStyles.headlineMd(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select any player card to rename or adjust team profiles [OK / MIC]',
                    style: AppStyles.bodyXl(),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showEditNameDialog(focusedIndex),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text('Voice Input: Tap or press [MIC] to rename', style: AppStyles.labelMd()),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // DYNAMIC PLAYER CARDS ROW
          Row(
            children: widget.players.asMap().entries.map((entry) {
              final idx = entry.key;
              final player = entry.value;
              final isFocused = idx == focusedIndex && !isContinueFocused;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        focusedIndex = idx;
                        isContinueFocused = false;
                      });
                      widget.onFocusPlayerChanged(idx);
                      _showEditNameDialog(idx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: isFocused ? 420 : 390,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isFocused
                            ? AppColors.surfaceHigh.withValues(alpha: 0.95)
                            : AppColors.surfaceLow.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFocused ? AppColors.secondary : Colors.white.withValues(alpha: 0.1),
                          width: isFocused ? 3 : 1,
                        ),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.45),
                                  blurRadius: 30,
                                ),
                              ]
                            : [
                                const BoxShadow(color: Colors.black26, blurRadius: 15),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (isFocused)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.secondaryContainer, AppColors.primaryContainer],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.settings_remote, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text('FOCUSED', style: AppStyles.labelMd(color: Colors.white)),
                                ],
                              ),
                            )
                          else
                            const SizedBox(height: 20),

                          // Status Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldReady.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.emeraldReady.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, size: 12, color: AppColors.emeraldReady),
                                    const SizedBox(width: 4),
                                    Text('READY', style: AppStyles.labelMd(color: AppColors.emeraldReady)),
                                  ],
                                ),
                              ),
                              Text(player.deviceName, style: const TextStyle(fontSize: 11, color: AppColors.outlineVariant)),
                            ],
                          ),

                          // Avatar Circle
                          Container(
                            width: isFocused ? 105 : 90,
                            height: isFocused ? 105 : 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [player.accentColor, AppColors.primaryContainer],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: player.accentColor.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: AppColors.surfaceLowest,
                              child: Icon(player.icon, size: isFocused ? 56 : 46, color: player.accentColor),
                            ),
                          ),

                          // Name & Team
                          Column(
                            children: [
                              Text(
                                player.name,
                                style: AppStyles.headlineMd(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                player.roleTag,
                                style: AppStyles.bodyMd(color: AppColors.secondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // Action tool bar
                          InkWell(
                            onTap: () => _showEditNameDialog(idx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isFocused ? AppColors.secondary.withValues(alpha: 0.2) : AppColors.surfaceLowest,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isFocused ? AppColors.secondary : AppColors.outlineVariant),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit, size: 12, color: isFocused ? AppColors.secondary : AppColors.outline),
                                  const SizedBox(width: 4),
                                  Text(
                                    isFocused ? '[OK] Rename' : 'Edit Name',
                                    style: AppStyles.labelMd(color: isFocused ? AppColors.secondary : AppColors.outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // BOTTOM CONTROL BAR & CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _addGuestPlayer,
                    icon: const Icon(Icons.person_add, color: AppColors.secondary),
                    label: Text('+ Add Player (${widget.players.length}/6)', style: AppStyles.labelLg()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _randomizeTeams,
                    icon: const Icon(Icons.shuffle, color: AppColors.primary),
                    label: Text('Shuffle Roles', style: AppStyles.labelLg()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                ],
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isContinueFocused
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.8),
                            blurRadius: 30,
                          ),
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                    backgroundColor: isContinueFocused ? AppColors.secondaryContainer : AppColors.primaryContainer,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isContinueFocused ? AppColors.secondary : Colors.transparent,
                        width: isContinueFocused ? 3 : 0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'CONTINUE TO GAME SELECT [OK]',
                        style: AppStyles.headlineMd(color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
