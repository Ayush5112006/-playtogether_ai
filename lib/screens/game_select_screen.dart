import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';

class GameSelectScreen extends StatefulWidget {
  final VoidCallback onCreateGame;
  final String? lastRemoteCommand;
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final ValueChanged<String>? onCategoryChanged;
  final String selectedDifficulty;
  final ValueChanged<String>? onDifficultyChanged;
  final List<Player> players;

  const GameSelectScreen({
    super.key,
    required this.onCreateGame,
    this.lastRemoteCommand,
    this.categories = const [],
    this.selectedCategory = 'Cinema Clues',
    this.onCategoryChanged,
    this.selectedDifficulty = 'ADAPTIVE',
    this.onDifficultyChanged,
    this.players = const [],
  });

  @override
  State<GameSelectScreen> createState() => _GameSelectScreenState();
}

class _GameSelectScreenState extends State<GameSelectScreen> {
  int selectedCategoryIndex = 0;
  late String currentDifficulty;
  int focusArea = 0; // 0: Categories rail, 1: Difficulty rail, 2: Start button

  final List<String> difficulties = ['EASY', 'MEDIUM', 'HARD', 'ADAPTIVE'];

  @override
  void initState() {
    super.initState();
    currentDifficulty = widget.selectedDifficulty;
    if (widget.categories.isNotEmpty) {
      final idx = widget.categories.indexWhere((c) => c['name'] == widget.selectedCategory);
      if (idx != -1) selectedCategoryIndex = idx;
    }
  }

  @override
  void didUpdateWidget(GameSelectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;
      final catCount = widget.categories.isNotEmpty ? widget.categories.length : 4;

      if (cmd == 'LEFT') {
        if (focusArea == 0) {
          setState(() {
            selectedCategoryIndex = (selectedCategoryIndex - 1 + catCount) % catCount;
          });
          _notifyCategoryChanged();
        } else if (focusArea == 1) {
          final diffIdx = difficulties.indexOf(currentDifficulty);
          final newIdx = (diffIdx - 1 + difficulties.length) % difficulties.length;
          setState(() => currentDifficulty = difficulties[newIdx]);
          widget.onDifficultyChanged?.call(currentDifficulty);
        }
      } else if (cmd == 'RIGHT') {
        if (focusArea == 0) {
          setState(() {
            selectedCategoryIndex = (selectedCategoryIndex + 1) % catCount;
          });
          _notifyCategoryChanged();
        } else if (focusArea == 1) {
          final diffIdx = difficulties.indexOf(currentDifficulty);
          final newIdx = (diffIdx + 1) % difficulties.length;
          setState(() => currentDifficulty = difficulties[newIdx]);
          widget.onDifficultyChanged?.call(currentDifficulty);
        }
      } else if (cmd == 'DOWN') {
        setState(() {
          focusArea = (focusArea + 1).clamp(0, 2);
        });
      } else if (cmd == 'UP') {
        setState(() {
          focusArea = (focusArea - 1).clamp(0, 2);
        });
      } else if (cmd == 'OK') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onCreateGame();
        });
      }
    }
  }

  void _notifyCategoryChanged() {
    if (widget.categories.isNotEmpty && selectedCategoryIndex < widget.categories.length) {
      final name = widget.categories[selectedCategoryIndex]['name'] as String? ?? 'General Knowledge';
      widget.onCategoryChanged?.call(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catList = widget.categories.isNotEmpty
        ? widget.categories
        : [
            {'name': 'Cinema Clues', 'emoji': '🎬', 'questionCount': 7},
            {'name': 'Science & Cosmos', 'emoji': '🚀', 'questionCount': 7},
            {'name': 'Pop Culture & Music', 'emoji': '🎵', 'questionCount': 5},
            {'name': 'Animation & Family', 'emoji': '✨', 'questionCount': 5},
            {'name': 'General Knowledge', 'emoji': '🌍', 'questionCount': 5},
            {'name': 'Surprise Buzzer Blitz', 'emoji': '⚡', 'questionCount': 3},
          ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                      Text('Pick a category loaded directly from the database or let AI adapt to ', style: AppStyles.bodyXl()),
                      Text(
                        widget.players.map((p) => p.name).join(', '),
                        style: AppStyles.labelLg(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        ...widget.players.map((p) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: p.accentColor,
                                child: Text(
                                  p.name.isNotEmpty ? p.name[0] : 'P',
                                  style: AppStyles.labelMd(color: Colors.black),
                                ),
                              ),
                            )),
                        const SizedBox(width: 6),
                        Text('${widget.players.length} Players Synced', style: AppStyles.labelMd()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: widget.onCreateGame,
                    icon: const Icon(Icons.play_arrow, color: Colors.black, size: 22),
                    label: Text('START QUIZ [OK]', style: AppStyles.labelLg(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 8,
                      shadowColor: AppColors.secondary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // DYNAMIC CATEGORY CARDS RAIL
          Row(
            children: catList.take(4).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final cat = entry.value;
              final name = cat['name'] as String? ?? 'General';
              final emoji = cat['emoji'] as String? ?? '🧠';
              final qCount = cat['questionCount'] as int? ?? 5;
              final isFocused = focusArea == 0 && idx == selectedCategoryIndex;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: idx < 3 ? 16 : 0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = idx;
                        focusArea = 0;
                      });
                      _notifyCategoryChanged();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isFocused ? AppColors.surfaceHigh : AppColors.surfaceLow.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFocused ? AppColors.secondary : Colors.white.withValues(alpha: 0.1),
                          width: isFocused ? 3 : 1,
                        ),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.45),
                                  blurRadius: 28,
                                )
                              ]
                            : [
                                const BoxShadow(color: Colors.black26, blurRadius: 10),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 32)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                                ),
                                child: Text('$qCount Qs', style: AppStyles.labelMd(color: AppColors.secondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(name, style: AppStyles.headlineMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Text('Dynamic database quiz bank', style: AppStyles.bodyMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('10 Min', style: AppStyles.bodyMd()),
                              Text(isFocused ? '[OK] Select' : 'Active', style: AppStyles.labelMd(color: isFocused ? AppColors.secondary : AppColors.outline)),
                            ],
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

          // SETTINGS & AI INSIGHT RAIL
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Settings Selectors
              Expanded(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tune, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text('GAME ENGINE PARAMETERS', style: AppStyles.labelMd(color: AppColors.secondary)),
                            ],
                          ),
                          Text('D-Pad: ⬆ Up | Down ⬇ to switch row', style: TextStyle(fontSize: 11, color: AppColors.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Difficulty Chips
                      Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text('Difficulty Level:', style: AppStyles.labelLg()),
                          ),
                          ...difficulties.map((d) {
                            final isSel = currentDifficulty == d;
                            final isRowFocused = focusArea == 1 && isSel;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text(d),
                                selected: isSel,
                                onSelected: (_) {
                                  setState(() {
                                    currentDifficulty = d;
                                    focusArea = 1;
                                  });
                                  widget.onDifficultyChanged?.call(d);
                                },
                                selectedColor: isRowFocused ? AppColors.secondary : AppColors.secondaryContainer,
                                labelStyle: AppStyles.labelMd(color: isSel ? Colors.black : Colors.white),
                                side: BorderSide(color: isRowFocused ? AppColors.secondary : AppColors.outlineVariant, width: isRowFocused ? 2 : 1),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Right: Action Launcher CTA
              Expanded(
                flex: 4,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: focusArea == 2 ? AppColors.secondary : AppColors.primary.withValues(alpha: 0.5),
                      width: focusArea == 2 ? 3 : 1.5,
                    ),
                    boxShadow: focusArea == 2
                        ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.6), blurRadius: 30)]
                        : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 20)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text('READY TO LAUNCH', style: AppStyles.labelMd(color: AppColors.secondary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Start Dynamic Quiz', style: AppStyles.headlineLg()),
                          const SizedBox(height: 4),
                          Text('Database questions loaded and ready for room display.', style: AppStyles.bodyMd()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onCreateGame,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: focusArea == 2 ? AppColors.secondaryContainer : AppColors.primaryContainer,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('START QUIZ [OK]', style: AppStyles.headlineMd(color: Colors.white)),
                              const SizedBox(width: 10),
                              const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                            ],
                          ),
                        ),
                      ),
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
