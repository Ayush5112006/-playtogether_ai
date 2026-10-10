import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GameSelectScreen extends StatefulWidget {
  final VoidCallback onCreateGame;
  final String? lastRemoteCommand;

  const GameSelectScreen({
    super.key,
    required this.onCreateGame,
    this.lastRemoteCommand,
  });

  @override
  State<GameSelectScreen> createState() => _GameSelectScreenState();
}

class _GameSelectScreenState extends State<GameSelectScreen> {
  int selectedCategoryIndex = 1; // Movie Guess selected
  String selectedDifficulty = 'ADAPTIVE';
  String selectedDuration = '10 Min';
  String selectedMode = 'Individual FFA';

  @override
  void didUpdateWidget(GameSelectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final cmd = widget.lastRemoteCommand!;
      if (cmd == 'LEFT' || cmd == 'UP') {
        setState(() => selectedCategoryIndex = (selectedCategoryIndex - 1 + 4) % 4);
      } else if (cmd == 'RIGHT' || cmd == 'DOWN') {
        setState(() => selectedCategoryIndex = (selectedCategoryIndex + 1) % 4);
      } else if (cmd == 'OK') {
        widget.onCreateGame();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What should we play?', style: AppStyles.headlineXl()),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Pick a game or let AI adapt to ', style: AppStyles.bodyXl()),
                      Text('Mom, Dad, Maya, ', style: AppStyles.labelLg(color: AppColors.secondary)),
                      Text('and ', style: AppStyles.bodyXl()),
                      Text('Aarav', style: AppStyles.labelLg(color: AppColors.secondary)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: AppColors.tertiary, child: Text('M', style: AppStyles.labelMd(color: Colors.black))),
                    const SizedBox(width: 4),
                    CircleAvatar(radius: 12, backgroundColor: AppColors.secondary, child: Text('D', style: AppStyles.labelMd(color: Colors.black))),
                    const SizedBox(width: 4),
                    CircleAvatar(radius: 12, backgroundColor: AppColors.primary, child: Text('M', style: AppStyles.labelMd(color: Colors.black))),
                    const SizedBox(width: 4),
                    CircleAvatar(radius: 12, backgroundColor: AppColors.amberWarning, child: Text('A', style: AppStyles.labelMd(color: Colors.black))),
                    const SizedBox(width: 10),
                    Text('4 Phones Connected', style: AppStyles.labelMd()),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4 GAME CATEGORY CARDS RAIL
          Row(
            children: [
              _buildCategoryCard(0, 'General Trivia', '🧠', 'Test what everyone knows across science & pop culture.', '10m', 'Family Favorite', AppColors.secondary, isFocused: selectedCategoryIndex == 0),
              const SizedBox(width: 16),
              _buildCategoryCard(1, 'MOVIE GUESS', '🎬', 'Audio soundbites, quote mashups, and AI poster clues.', '10m', 'Popular', AppColors.secondary, isFocused: selectedCategoryIndex == 1),
              const SizedBox(width: 16),
              _buildCategoryCard(2, 'AI WILDCARD', '🎯', 'Dynamic live rule shifts and spontaneous mini-games.', '15m', 'AI Curated', AppColors.primary, isFocused: selectedCategoryIndex == 2),
              const SizedBox(width: 16),
              _buildCategoryCard(3, 'LET AI CHOOSE', '✨', 'CORTEX-9 synthesizes the perfect custom challenge.', 'Custom', 'Recommended', AppColors.tertiary, isFocused: selectedCategoryIndex == 3),
            ],
          ),

          const SizedBox(height: 20),

          // SETTINGS & AI INSIGHT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left 8 Cols: Settings Selectors
              Expanded(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildSettingRow('DIFFICULTY', ['Easy', 'Medium', 'Hard', 'ADAPTIVE (Recommended)'], selectedDifficulty, (val) => setState(() => selectedDifficulty = val)),
                      const Divider(color: AppColors.outlineVariant, height: 20),
                      _buildSettingRow('DURATION', ['5 Min', '10 Min (Standard)', '20 Min'], selectedDuration, (val) => setState(() => selectedDuration = val)),
                      const Divider(color: AppColors.outlineVariant, height: 20),
                      _buildSettingRow('MODE', ['Individual FFA', 'Co-op Teams'], selectedMode, (val) => setState(() => selectedMode = val)),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Right 4 Cols: Cortex Insight & CTA
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.surfaceHigh.withOpacity(0.9), AppColors.surface.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.smart_toy, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CORTEX-9 Recommends:', style: AppStyles.labelMd(color: AppColors.secondary)),
                                const SizedBox(height: 4),
                                Text(
                                  'Adaptive Difficulty with Movie Guess for this group. Maya has a 4-game movie winning streak!',
                                  style: AppStyles.bodyMd(color: AppColors.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: widget.onCreateGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        backgroundColor: AppColors.primaryContainer,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 12,
                        shadowColor: AppColors.secondary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_fix_high, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Text('CREATE GAME WITH AI [OK]', style: AppStyles.headlineMd(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(int index, String title, String emoji, String desc, String time, String tag, Color color, {bool isFocused = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCategoryIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isFocused ? AppColors.surface.withOpacity(0.95) : AppColors.surfaceLow.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFocused ? AppColors.secondary : AppColors.outlineVariant.withOpacity(0.3),
              width: isFocused ? 3 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(color: AppColors.secondary.withOpacity(0.4), blurRadius: 25),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(tag, style: AppStyles.labelMd(color: color)),
                  ),
                ],
              ),
              Text(title, style: AppStyles.headlineMd(color: isFocused ? Colors.white : AppColors.onSurface)),
              Text(desc, style: AppStyles.bodyMd(), maxLines: 2, overflow: TextOverflow.ellipsis),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('⏱ $time', style: AppStyles.bodyMd()),
                  if (isFocused)
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text('Selected', style: AppStyles.labelMd(color: AppColors.secondary)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, List<String> options, String currentVal, ValueChanged<String> onSelect) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.labelMd(color: AppColors.onSurfaceVariant)),
        Row(
          children: options.map((opt) {
            final isSelected = opt.contains(currentVal) || opt == currentVal;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(opt, style: AppStyles.labelMd(color: isSelected ? Colors.white : AppColors.onSurfaceVariant)),
                selected: isSelected,
                selectedColor: AppColors.secondaryContainer,
                backgroundColor: AppColors.surfaceContainer,
                onSelected: (selected) {
                  if (selected) onSelect(opt);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
