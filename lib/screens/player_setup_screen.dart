import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';

class PlayerSetupScreen extends StatefulWidget {
  final List<Player> players;
  final VoidCallback onContinue;
  final ValueChanged<int> onFocusPlayerChanged;

  const PlayerSetupScreen({
    super.key,
    required this.players,
    required this.onContinue,
    required this.onFocusPlayerChanged,
  });

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int focusedIndex = 2; // Maya focused by default

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      Text('(Add 2–4 players)', style: AppStyles.headlineMd(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select ready status or adjust player profiles with your Fire TV remote',
                    style: AppStyles.bodyXl(),
                  ),
                ],
              ),
              Container(
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
                    Text('Voice Input: Press [MIC] to speak name', style: AppStyles.labelMd()),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // 4 PLAYER CARDS ROW
          Row(
            children: widget.players.asMap().entries.map((entry) {
              final idx = entry.key;
              final player = entry.value;
              final isFocused = idx == focusedIndex;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => focusedIndex = idx);
                      widget.onFocusPlayerChanged(idx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: isFocused ? 430 : 400,
                      padding: const EdgeInsets.all(20),
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
                                  blurRadius: 35,
                                ),
                                BoxShadow(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.35),
                                  blurRadius: 45,
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                                  Text('FOCUSED PLAYER', style: AppStyles.labelMd(color: Colors.white)),
                                ],
                              ),
                            ),

                          // Status Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldReady.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.emeraldReady.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, size: 14, color: AppColors.emeraldReady),
                                    const SizedBox(width: 4),
                                    Text('READY', style: AppStyles.labelMd(color: AppColors.emeraldReady)),
                                  ],
                                ),
                              ),
                              Text(player.deviceName, style: AppStyles.bodyMd()),
                            ],
                          ),

                          // Avatar Circle
                          Container(
                            width: isFocused ? 120 : 100,
                            height: isFocused ? 120 : 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [player.accentColor, AppColors.primaryContainer],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: player.accentColor.withValues(alpha: 0.5),
                                  blurRadius: 25,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: AppColors.surfaceLowest,
                              child: Icon(player.icon, size: isFocused ? 64 : 52, color: player.accentColor),
                            ),
                          ),

                          // Name & Team
                          Column(
                            children: [
                              Text(player.name, style: AppStyles.headlineMd(color: Colors.white)),
                              Text(player.teamName, style: AppStyles.bodyMd(color: AppColors.secondary)),
                            ],
                          ),

                          // Action tool bar
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isFocused ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('[OK] Toggle Ready', style: AppStyles.labelMd(color: isFocused ? AppColors.primary : AppColors.outline)),
                              ],
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

          const Spacer(),

          // BOTTOM CONTROL BAR & CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add, color: AppColors.secondary),
                    label: Text('+ Add Guest Player', style: AppStyles.labelLg()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shuffle, color: AppColors.primary),
                    label: Text('Randomize Teams', style: AppStyles.labelLg()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                  backgroundColor: AppColors.primaryContainer,
                  elevation: 10,
                  shadowColor: AppColors.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  children: [
                    Text('CONTINUE TO GAME SELECT [OK]', style: AppStyles.headlineMd(color: Colors.white)),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
