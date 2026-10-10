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
  // 2D Spatial Focus Grid for D-Pad Remote:
  // Row 0: Top Header Actions (0: Rename [MIC], 1: CONTINUE [OK])
  // Row 1: Player Cards (0 .. players.length - 1)
  // Row 2: "Edit Name" Button on each Card (0 .. players.length - 1)
  // Row 3: Bottom Control Bar (0: + Add Player, 1: Shuffle Roles, 2: CONTINUE TO GAME SELECT [OK])
  int focusRow = 1;
  int focusCol = 0;

  @override
  void didUpdateWidget(PlayerSetupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;
      final playerCount = widget.players.isNotEmpty ? widget.players.length : 1;

      if (cmd == 'LEFT') {
        setState(() {
          if (focusRow == 0) {
            focusCol = (focusCol - 1).clamp(0, 1);
          } else if (focusRow == 1 || focusRow == 2) {
            focusCol = (focusCol - 1 + playerCount) % playerCount;
            widget.onFocusPlayerChanged(focusCol);
          } else if (focusRow == 3) {
            focusCol = (focusCol - 1).clamp(0, 2);
          }
        });
      } else if (cmd == 'RIGHT') {
        setState(() {
          if (focusRow == 0) {
            focusCol = (focusCol + 1).clamp(0, 1);
          } else if (focusRow == 1 || focusRow == 2) {
            focusCol = (focusCol + 1) % playerCount;
            widget.onFocusPlayerChanged(focusCol);
          } else if (focusRow == 3) {
            focusCol = (focusCol + 1).clamp(0, 2);
          }
        });
      } else if (cmd == 'UP') {
        setState(() {
          if (focusRow == 3) {
            focusRow = 2;
            focusCol = focusCol.clamp(0, playerCount - 1);
          } else if (focusRow == 2) {
            focusRow = 1;
          } else if (focusRow == 1) {
            focusRow = 0;
            focusCol = focusCol >= (playerCount / 2) ? 1 : 0;
          } else if (focusRow == 0) {
            focusRow = 3;
            focusCol = 2; // Wrap around to bottom continue
          }
        });
      } else if (cmd == 'DOWN') {
        setState(() {
          if (focusRow == 0) {
            focusRow = 1;
            focusCol = (focusCol == 1) ? (playerCount - 1) : 0;
          } else if (focusRow == 1) {
            focusRow = 2;
          } else if (focusRow == 2) {
            focusRow = 3;
            focusCol = (focusCol >= (playerCount / 2)) ? 2 : 0;
          } else if (focusRow == 3) {
            focusRow = 0;
            focusCol = 1; // Wrap around to header continue
          }
        });
      } else if (cmd == 'OK') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (focusRow == 0) {
            if (focusCol == 0) {
              _showEditNameDialog(focusCol.clamp(0, playerCount - 1));
            } else {
              widget.onContinue();
            }
          } else if (focusRow == 1) {
            _showEditNameDialog(focusCol.clamp(0, playerCount - 1));
          } else if (focusRow == 2) {
            _showEditNameDialog(focusCol.clamp(0, playerCount - 1));
          } else if (focusRow == 3) {
            if (focusCol == 0) {
              _addGuestPlayer();
            } else if (focusCol == 1) {
              _randomizeTeams();
            } else {
              widget.onContinue();
            }
          }
        });
      } else if (cmd == 'MIC') {
        final activePlayer = (focusRow == 1 || focusRow == 2) ? focusCol : 0;
        _showEditNameDialog(activePlayer.clamp(0, playerCount - 1));
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
      focusRow = 1;
      focusCol = widget.players.length - 1;
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
    final isRenameFocused = focusRow == 0 && focusCol == 0;
    final isHeaderContinueFocused = focusRow == 0 && focusCol == 1;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Column(
        children: [
          // 1. TOP HEADER ROW (With Focusable Action Buttons)
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
                    'Use remote D-Pad [Arrows] to navigate any button • Press [OK] to activate',
                    style: AppStyles.bodyXl(),
                  ),
                ],
              ),
              Row(
                children: [
                  // Header Button 0: Rename [MIC]
                  InkWell(
                    onTap: () {
                      setState(() {
                        focusRow = 0;
                        focusCol = 0;
                      });
                      _showEditNameDialog(focusCol.clamp(0, widget.players.length - 1));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isRenameFocused ? AppColors.surfaceHigh : AppColors.surfaceHigh.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRenameFocused ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.3),
                          width: isRenameFocused ? 3 : 1,
                        ),
                        boxShadow: isRenameFocused
                            ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.7), blurRadius: 20)]
                            : [],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mic, color: AppColors.secondary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            isRenameFocused ? 'Rename [MIC / OK] ◄' : 'Rename [MIC]',
                            style: AppStyles.labelMd(color: isRenameFocused ? AppColors.secondary : AppColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Header Button 1: CONTINUE [OK]
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isHeaderContinueFocused
                          ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.8), blurRadius: 28)]
                          : [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 10)],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          focusRow = 0;
                          focusCol = 1;
                        });
                        widget.onContinue();
                      },
                      icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                      label: Text(
                        isHeaderContinueFocused ? 'CONTINUE [OK] ◄' : 'CONTINUE [OK]',
                        style: AppStyles.labelLg(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHeaderContinueFocused ? Colors.white : AppColors.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isHeaderContinueFocused ? AppColors.secondary : Colors.transparent,
                            width: isHeaderContinueFocused ? 3 : 0,
                          ),
                        ),
                        elevation: isHeaderContinueFocused ? 14 : 6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. DYNAMIC PLAYER CARDS ROW (Rows 1 & 2 Focusable)
          Row(
            children: widget.players.asMap().entries.map((entry) {
              final idx = entry.key;
              final player = entry.value;
              final isCardFocused = (focusRow == 1 && focusCol == idx);
              final isEditBtnFocused = (focusRow == 2 && focusCol == idx);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        focusRow = 1;
                        focusCol = idx;
                      });
                      widget.onFocusPlayerChanged(idx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: (isCardFocused || isEditBtnFocused) ? 335 : 300,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCardFocused
                            ? AppColors.surfaceHigh.withValues(alpha: 0.95)
                            : (isEditBtnFocused ? AppColors.surfaceHigh.withValues(alpha: 0.90) : AppColors.surfaceLow.withValues(alpha: 0.85)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCardFocused
                              ? AppColors.secondary
                              : (isEditBtnFocused ? AppColors.secondary.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.1)),
                          width: isCardFocused ? 3.5 : (isEditBtnFocused ? 2 : 1),
                        ),
                        boxShadow: isCardFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.55),
                                  blurRadius: 28,
                                ),
                              ]
                            : [
                                const BoxShadow(color: Colors.black26, blurRadius: 12),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (isCardFocused)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.secondaryContainer, AppColors.primaryContainer],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.settings_remote, size: 13, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text('FOCUSED [OK]', style: AppStyles.labelMd(color: Colors.white)),
                                ],
                              ),
                            )
                          else
                            const SizedBox(height: 16),

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
                            width: (isCardFocused || isEditBtnFocused) ? 84 : 72,
                            height: (isCardFocused || isEditBtnFocused) ? 84 : 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [player.accentColor, AppColors.primaryContainer],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: player.accentColor.withValues(alpha: 0.5),
                                  blurRadius: 16,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: AppColors.surfaceLowest,
                              child: Icon(player.icon, size: (isCardFocused || isEditBtnFocused) ? 42 : 36, color: player.accentColor),
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

                          // Focusable Row 2: "Edit Name" Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                focusRow = 2;
                                focusCol = idx;
                              });
                              _showEditNameDialog(idx);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isEditBtnFocused
                                    ? AppColors.secondary
                                    : (isCardFocused ? AppColors.secondary.withValues(alpha: 0.25) : AppColors.surfaceLowest),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isEditBtnFocused
                                      ? Colors.white
                                      : (isCardFocused ? AppColors.secondary : AppColors.outlineVariant),
                                  width: isEditBtnFocused ? 2.5 : 1,
                                ),
                                boxShadow: isEditBtnFocused
                                    ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.8), blurRadius: 18)]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 13,
                                    color: isEditBtnFocused ? Colors.black : (isCardFocused ? AppColors.secondary : AppColors.outline),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isEditBtnFocused ? 'Edit Name [OK] ◄' : 'Edit Name',
                                    style: AppStyles.labelMd(
                                      color: isEditBtnFocused ? Colors.black : (isCardFocused ? AppColors.secondary : AppColors.outline),
                                    ),
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

          const SizedBox(height: 24),

          // 3. BOTTOM CONTROL BAR (Row 3 Focusable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Bottom Button 0: + Add Player
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: (focusRow == 3 && focusCol == 0)
                          ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.7), blurRadius: 25)]
                          : [],
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          focusRow = 3;
                          focusCol = 0;
                        });
                        _addGuestPlayer();
                      },
                      icon: Icon(
                        Icons.person_add,
                        color: (focusRow == 3 && focusCol == 0) ? Colors.white : AppColors.secondary,
                      ),
                      label: Text(
                        (focusRow == 3 && focusCol == 0)
                            ? '+ Add Player (${widget.players.length}/6) [OK] ◄'
                            : '+ Add Player (${widget.players.length}/6)',
                        style: AppStyles.labelLg(
                          color: (focusRow == 3 && focusCol == 0) ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        backgroundColor: (focusRow == 3 && focusCol == 0) ? AppColors.surfaceHigh : Colors.transparent,
                        side: BorderSide(
                          color: (focusRow == 3 && focusCol == 0) ? AppColors.secondary : AppColors.outlineVariant,
                          width: (focusRow == 3 && focusCol == 0) ? 3 : 1,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bottom Button 1: Shuffle Roles
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: (focusRow == 3 && focusCol == 1)
                          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.7), blurRadius: 25)]
                          : [],
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          focusRow = 3;
                          focusCol = 1;
                        });
                        _randomizeTeams();
                      },
                      icon: Icon(
                        Icons.shuffle,
                        color: (focusRow == 3 && focusCol == 1) ? Colors.white : AppColors.primary,
                      ),
                      label: Text(
                        (focusRow == 3 && focusCol == 1) ? 'Shuffle Roles [OK] ◄' : 'Shuffle Roles',
                        style: AppStyles.labelLg(
                          color: (focusRow == 3 && focusCol == 1) ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        backgroundColor: (focusRow == 3 && focusCol == 1) ? AppColors.surfaceHigh : Colors.transparent,
                        side: BorderSide(
                          color: (focusRow == 3 && focusCol == 1) ? AppColors.primary : AppColors.outlineVariant,
                          width: (focusRow == 3 && focusCol == 1) ? 3 : 1,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Button 2: CONTINUE TO GAME SELECT [OK]
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: (focusRow == 3 && focusCol == 2)
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.9),
                            blurRadius: 35,
                          ),
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      focusRow = 3;
                      focusCol = 2;
                    });
                    widget.onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                    backgroundColor: (focusRow == 3 && focusCol == 2)
                        ? AppColors.secondaryContainer
                        : AppColors.primaryContainer,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: (focusRow == 3 && focusCol == 2) ? AppColors.secondary : Colors.transparent,
                        width: (focusRow == 3 && focusCol == 2) ? 3.5 : 0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        (focusRow == 3 && focusCol == 2)
                            ? 'CONTINUE TO GAME SELECT [OK] ◄'
                            : 'CONTINUE TO GAME SELECT [OK]',
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
