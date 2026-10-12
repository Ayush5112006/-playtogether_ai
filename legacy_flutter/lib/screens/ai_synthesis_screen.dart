import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_orb.dart';
import '../models/game_settings.dart';
import '../models/player.dart';

class AiSynthesisScreen extends StatefulWidget {
  final ValueChanged<GameSettings>? onStartGame;
  final String? lastRemoteCommand;
  final GameSettings? initialSettings;
  final List<Player> players;
  final String selectedCategory;
  final String selectedDifficulty;

  const AiSynthesisScreen({
    super.key,
    this.onStartGame,
    this.lastRemoteCommand,
    this.initialSettings,
    this.players = const [],
    this.selectedCategory = 'Cinema Clues',
    this.selectedDifficulty = 'ADAPTIVE',
  });

  @override
  State<AiSynthesisScreen> createState() => _AiSynthesisScreenState();
}

class _AiSynthesisScreenState extends State<AiSynthesisScreen> with TickerProviderStateMixin {
  late GameSettings _settings;

  // Active Tab:
  // 0: Match Pace (Questions, Timer, Difficulty)
  // 1: AI Dynamics (Handicap, Wildcard, Persona)
  // 2: Audio & Immersion (Voice Host, SFX, Ambience)
  // 3: Players & Handicaps (Player Profiles, Individual Tuning)
  int currentTab = 0;

  // Focus Area:
  // 0: Tab Selector Bar (cols 0..3)
  // 1: Tab Content Options (subRow, subCol)
  // 2: Bottom Action Bar (0: Start Game [OK], 1: Reset Defaults)
  int focusArea = 0;
  int subRow = 0;
  int subCol = 0;

  final List<Map<String, dynamic>> tabs = [
    {'title': 'Match Pace', 'icon': Icons.tune},
    {'title': 'AI Dynamics', 'icon': Icons.auto_awesome},
    {'title': 'Audio & Sound', 'icon': Icons.volume_up},
    {'title': 'Players & Roles', 'icon': Icons.group},
  ];

  final List<int> questionOptions = [5, 10, 15];
  final List<int> timerOptions = [10, 15, 20, 30];
  final List<String> difficultyOptions = ['EASY', 'MEDIUM', 'HARD', 'ADAPTIVE'];
  final List<String> personaOptions = ['Playful Host', 'Game Show Host', 'Strict Master'];

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings?.copyWith() ?? GameSettings();
  }

  @override
  void didUpdateWidget(AiSynthesisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;
      // Handle D-Pad command safely
      _handleRemoteDpad(cmd);
    }
  }

  void _handleRemoteDpad(String cmd) {
    setState(() {
      if (focusArea == 0) {
        // --- FOCUS AREA 0: TAB BAR ---
        if (cmd == 'LEFT') {
          currentTab = (currentTab - 1 + tabs.length) % tabs.length;
        } else if (cmd == 'RIGHT') {
          currentTab = (currentTab + 1) % tabs.length;
        } else if (cmd == 'DOWN' || cmd == 'OK') {
          focusArea = 1;
          subRow = 0;
          subCol = 0;
        }
      } else if (focusArea == 1) {
        // --- FOCUS AREA 1: ACTIVE TAB OPTIONS ---
        final maxR = _maxSubRowForTab(currentTab);

        if (cmd == 'UP') {
          if (subRow > 0) {
            subRow--;
            subCol = _clampSubCol(currentTab, subRow, subCol);
          } else {
            // Return to Tab Selector Bar
            focusArea = 0;
          }
        } else if (cmd == 'DOWN') {
          if (subRow < maxR) {
            subRow++;
            subCol = _clampSubCol(currentTab, subRow, subCol);
          } else {
            // Drop to Bottom Action Bar
            focusArea = 2;
            subCol = 0;
          }
        } else if (cmd == 'LEFT') {
          final maxC = _maxSubColForTab(currentTab, subRow);
          subCol = (subCol - 1 + (maxC + 1)) % (maxC + 1);
        } else if (cmd == 'RIGHT') {
          final maxC = _maxSubColForTab(currentTab, subRow);
          subCol = (subCol + 1) % (maxC + 1);
        } else if (cmd == 'OK') {
          _activateOptionInTab(currentTab, subRow, subCol);
        }
      } else if (focusArea == 2) {
        // --- FOCUS AREA 2: BOTTOM ACTION BAR ---
        if (cmd == 'UP') {
          focusArea = 1;
          subRow = _maxSubRowForTab(currentTab);
          subCol = 0;
        } else if (cmd == 'LEFT' || cmd == 'RIGHT') {
          subCol = (subCol == 0) ? 1 : 0;
        } else if (cmd == 'OK') {
          if (subCol == 0) {
            _triggerStartGame();
          } else {
            _resetDefaults();
          }
        }
      }
    });
  }

  int _maxSubRowForTab(int tab) {
    switch (tab) {
      case 0: // Match Pace: 0: Questions, 1: Timer, 2: Difficulty
        return 2;
      case 1: // AI Dynamics: 0: Handicap, 1: Wildcard, 2: Persona
        return 2;
      case 2: // Audio: 0: Voice Host, 1: SFX, 2: Ambient
        return 2;
      case 3: // Players: 0: Row 1, 1: Row 2, 2: Reset Streaks
        return 2;
      default:
        return 0;
    }
  }

  int _maxSubColForTab(int tab, int row) {
    if (tab == 0) {
      if (row == 0) return questionOptions.length - 1; // 0..2
      if (row == 1) return timerOptions.length - 1; // 0..3
      if (row == 2) return difficultyOptions.length - 1; // 0..3
    } else if (tab == 1) {
      if (row == 0) return 0; // Toggle
      if (row == 1) return 0; // Toggle
      if (row == 2) return personaOptions.length - 1; // 0..2
    } else if (tab == 2) {
      return 0; // Each row is 1 toggle card
    } else if (tab == 3) {
      if (row == 0) return (widget.players.length >= 2) ? 1 : 0;
      if (row == 1) return (widget.players.length >= 4) ? 1 : 0;
      if (row == 2) return 0;
    }
    return 0;
  }

  int _clampSubCol(int tab, int row, int col) {
    final maxC = _maxSubColForTab(tab, row);
    return col.clamp(0, maxC);
  }

  void _activateOptionInTab(int tab, int row, int col) {
    if (tab == 0) {
      // Match Pace
      if (row == 0) {
        _settings = _settings.copyWith(questionCount: questionOptions[col]);
      } else if (row == 1) {
        _settings = _settings.copyWith(timerSeconds: timerOptions[col]);
      } else if (row == 2) {
        _settings = _settings.copyWith(difficulty: difficultyOptions[col]);
      }
    } else if (tab == 1) {
      // AI Dynamics
      if (row == 0) {
        _settings = _settings.copyWith(adaptiveHandicap: !_settings.adaptiveHandicap);
      } else if (row == 1) {
        _settings = _settings.copyWith(wildcardRound: !_settings.wildcardRound);
      } else if (row == 2) {
        _settings = _settings.copyWith(aiPersona: personaOptions[col]);
      }
    } else if (tab == 2) {
      // Audio
      if (row == 0) {
        _settings = _settings.copyWith(aiVoiceHost: !_settings.aiVoiceHost);
      } else if (row == 1) {
        _settings = _settings.copyWith(soundEffects: !_settings.soundEffects);
      } else if (row == 2) {
        _settings = _settings.copyWith(ambientMusic: !_settings.ambientMusic);
      }
    } else if (tab == 3) {
      // Players
      if (row == 2) {
        for (var p in widget.players) {
          p.streak = 0;
        }
      }
    }
  }

  void _resetDefaults() {
    setState(() {
      _settings = GameSettings();
    });
  }

  void _triggerStartGame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onStartGame?.call(_settings);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerNames = widget.players.isNotEmpty
        ? widget.players.map((p) => p.name).join(', ')
        : 'Mom, Dad, Maya, Aarav';

    final estimatedMinutes = ((_settings.questionCount * _settings.timerSeconds) / 60).ceil() + 2;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP HEADER ROW (Overflow-Safe)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Game Settings & AI Studio', style: AppStyles.headlineXl()),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                          ),
                          child: Text('STEP 3 OF 4', style: AppStyles.labelMd(color: AppColors.secondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fine-tune match pace, timer, sound immersion, and adaptive AI balancing before starting.',
                      style: AppStyles.bodyXl(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.settings_remote, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      focusArea == 0
                          ? 'D-Pad: ◄/► Switch Tab • ▼ Enter Options'
                          : (focusArea == 1 ? 'D-Pad: ▲/▼ Rows • ◄/► Options • [OK] Toggle' : 'D-Pad: [OK] Start Game'),
                      style: AppStyles.labelMd(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. REMOTE-ACCESSIBLE TAB BAR (Focus Area 0)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (focusArea == 0) ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.35),
                width: (focusArea == 0) ? 2.5 : 1,
              ),
              boxShadow: (focusArea == 0)
                  ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.4), blurRadius: 20)]
                  : [],
            ),
            child: Row(
              children: [
                for (int i = 0; i < tabs.length; i++) ...[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          currentTab = i;
                          focusArea = 1;
                          subRow = 0;
                          subCol = 0;
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: (currentTab == i)
                              ? (focusArea == 0 ? Colors.white : AppColors.secondaryContainer)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (focusArea == 0 && currentTab == i)
                                ? AppColors.secondary
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: (currentTab == i)
                              ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 10)]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tabs[i]['icon'] as IconData,
                              size: 18,
                              color: (currentTab == i)
                                  ? (focusArea == 0 ? Colors.black : Colors.white)
                                  : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (focusArea == 0 && currentTab == i)
                                  ? '${tabs[i]['title']} [OK]'
                                  : tabs[i]['title'] as String,
                              style: AppStyles.labelMd(
                                color: (currentTab == i)
                                    ? (focusArea == 0 ? Colors.black : Colors.white)
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (i < tabs.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. MAIN WORKSPACE: 2-COLUMN VIEW (Left: AI Orb & Status • Right: Active Tab Controls)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (Flex 5): CORTEX-9 AI Orb & Dynamic Insight Console
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 24, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const AiOrbWidget(size: 180, label: 'CORTEX-9'),
                      const SizedBox(height: 14),
                      Text('Dynamic Match Synthesizer', style: AppStyles.headlineMd()),
                      const SizedBox(height: 4),
                      Text(
                        'Engine calibrated for $playerNames',
                        style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),

                      // Live Parameters Chip Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _buildInfoBadge(Icons.quiz, '${_settings.questionCount} Questions'),
                            _buildDotSeparator(),
                            _buildInfoBadge(Icons.timer, '${_settings.timerSeconds}s / Q'),
                            _buildDotSeparator(),
                            _buildInfoBadge(Icons.hourglass_bottom, '~$estimatedMinutes Min'),
                            _buildDotSeparator(),
                            _buildInfoBadge(Icons.tune, _settings.difficulty),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // AI Host Observation Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLowest.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.psychology, color: AppColors.secondary, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CORTEX-9 HOST LOGIC', style: AppStyles.labelMd(color: AppColors.secondary)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"Persona: ${_settings.aiPersona}. Category: ${widget.selectedCategory}. '
                                    '${_settings.adaptiveHandicap ? "Adaptive handicap will dynamically balance point weights" : "Standard point weights applied"}. '
                                    '${_settings.wildcardRound ? "Surprise buzzer round enabled!" : "Standard mode."}"',
                                    style: AppStyles.bodyMd(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Status Checklist
                      _buildSynthesisPill('AI Question Bank', 'LOADED (Supabase)', AppColors.emeraldReady),
                      const SizedBox(height: 6),
                      _buildSynthesisPill(
                        'Adaptive Handicap',
                        _settings.adaptiveHandicap ? 'ACTIVE' : 'DISABLED',
                        _settings.adaptiveHandicap ? AppColors.secondary : AppColors.outlineVariant,
                      ),
                      const SizedBox(height: 6),
                      _buildSynthesisPill(
                        'Voice Host & SFX Engines',
                        _settings.aiVoiceHost ? 'CORTEX-9 ONLINE' : 'MUTED',
                        _settings.aiVoiceHost ? AppColors.primary : AppColors.outlineVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // RIGHT COLUMN (Flex 7): ACTIVE TAB CONTENT (Focus Area 1 & 2)
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    // Dynamic Content per Tab
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildActiveTabContent(),
                    ),

                    const SizedBox(height: 18),

                    // BOTTOM ACTION BAR (Focus Area 2)
                    Row(
                      children: [
                        // Secondary Action: Reset Defaults (col 1)
                        Expanded(
                          flex: 4,
                          child: InkWell(
                            onTap: _resetDefaults,
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: (focusArea == 2 && subCol == 1)
                                    ? Colors.white
                                    : AppColors.surfaceHigh.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: (focusArea == 2 && subCol == 1)
                                      ? AppColors.secondary
                                      : AppColors.outlineVariant.withValues(alpha: 0.3),
                                  width: (focusArea == 2 && subCol == 1) ? 2.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 20,
                                    color: (focusArea == 2 && subCol == 1) ? Colors.black : AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    (focusArea == 2 && subCol == 1) ? 'Reset [OK]' : 'Reset Defaults',
                                    style: AppStyles.labelMd(
                                      color: (focusArea == 2 && subCol == 1) ? Colors.black : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Primary Action: START GAME [OK] (col 0)
                        Expanded(
                          flex: 8,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: (focusArea == 2 && subCol == 0)
                                  ? [
                                      BoxShadow(
                                        color: AppColors.secondary.withValues(alpha: 0.9),
                                        blurRadius: 36,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: AppColors.secondary.withValues(alpha: 0.35),
                                        blurRadius: 16,
                                      ),
                                    ],
                            ),
                            child: ElevatedButton(
                              onPressed: _triggerStartGame,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                backgroundColor: (focusArea == 2 && subCol == 0)
                                    ? Colors.white
                                    : AppColors.secondaryContainer,
                                minimumSize: const Size(double.infinity, 64),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color: (focusArea == 2 && subCol == 0) ? AppColors.secondary : Colors.transparent,
                                    width: (focusArea == 2 && subCol == 0) ? 3.5 : 0,
                                  ),
                                ),
                                elevation: (focusArea == 2 && subCol == 0) ? 16 : 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_fill,
                                    color: (focusArea == 2 && subCol == 0) ? Colors.black : Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    (focusArea == 2 && subCol == 0) ? 'START GAME [OK] ◄' : 'START GAME [OK]',
                                    style: AppStyles.headlineMd(
                                      color: (focusArea == 2 && subCol == 0) ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }

  // --- TAB CONTENT BUILDERS ---

  Widget _buildActiveTabContent() {
    switch (currentTab) {
      case 0:
        return _buildTabMatchPace();
      case 1:
        return _buildTabAiDynamics();
      case 2:
        return _buildTabAudio();
      case 3:
        return _buildTabPlayers();
      default:
        return _buildTabMatchPace();
    }
  }

  // TAB 0: MATCH PACE
  Widget _buildTabMatchPace() {
    return Column(
      key: const ValueKey(0),
      children: [
        // Row 0: Question Count
        _buildSettingsSectionCard(
          icon: Icons.format_list_numbered,
          title: 'MATCH LENGTH (QUESTION COUNT)',
          subtitle: 'Number of questions to play before the Winner Celebration',
          isRowActive: focusArea == 1 && subRow == 0,
          content: Row(
            children: [
              for (int i = 0; i < questionOptions.length; i++) ...[
                Expanded(
                  child: _buildSelectablePill(
                    label: '${questionOptions[i]} Questions',
                    tag: i == 0 ? 'Blitz' : (i == 1 ? 'Standard' : 'Championship'),
                    isSelected: _settings.questionCount == questionOptions[i],
                    isFocused: focusArea == 1 && subRow == 0 && subCol == i,
                    onTap: () {
                      setState(() {
                        focusArea = 1;
                        subRow = 0;
                        subCol = i;
                        _settings = _settings.copyWith(questionCount: questionOptions[i]);
                      });
                    },
                  ),
                ),
                if (i < questionOptions.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Row 1: Countdown Timer
        _buildSettingsSectionCard(
          icon: Icons.alarm,
          title: 'COUNTDOWN TIMER PER QUESTION',
          subtitle: 'Response window for sofa buzzers and answer selection',
          isRowActive: focusArea == 1 && subRow == 1,
          content: Row(
            children: [
              for (int i = 0; i < timerOptions.length; i++) ...[
                Expanded(
                  child: _buildSelectablePill(
                    label: '${timerOptions[i]} Seconds',
                    tag: i == 0 ? 'Speed' : (i == 1 ? 'Standard' : (i == 2 ? 'Relaxed' : 'Party')),
                    isSelected: _settings.timerSeconds == timerOptions[i],
                    isFocused: focusArea == 1 && subRow == 1 && subCol == i,
                    onTap: () {
                      setState(() {
                        focusArea = 1;
                        subRow = 1;
                        subCol = i;
                        _settings = _settings.copyWith(timerSeconds: timerOptions[i]);
                      });
                    },
                  ),
                ),
                if (i < timerOptions.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Row 2: Difficulty Level
        _buildSettingsSectionCard(
          icon: Icons.tune,
          title: 'DIFFICULTY ENGINE LEVEL',
          subtitle: 'Baseline challenge rating across all trivia question categories',
          isRowActive: focusArea == 1 && subRow == 2,
          content: Row(
            children: [
              for (int i = 0; i < difficultyOptions.length; i++) ...[
                Expanded(
                  child: _buildSelectablePill(
                    label: difficultyOptions[i],
                    tag: difficultyOptions[i] == 'ADAPTIVE' ? 'Dynamic' : 'Fixed',
                    isSelected: _settings.difficulty == difficultyOptions[i],
                    isFocused: focusArea == 1 && subRow == 2 && subCol == i,
                    onTap: () {
                      setState(() {
                        focusArea = 1;
                        subRow = 2;
                        subCol = i;
                        _settings = _settings.copyWith(difficulty: difficultyOptions[i]);
                      });
                    },
                  ),
                ),
                if (i < difficultyOptions.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // TAB 1: AI DYNAMICS
  Widget _buildTabAiDynamics() {
    return Column(
      key: const ValueKey(1),
      children: [
        // Row 0: Adaptive Handicap
        _buildSettingsSectionCard(
          icon: Icons.balance,
          title: 'ADAPTIVE CATCH-UP HANDICAP',
          subtitle: 'Real-time AI assistance for younger or trailing players',
          isRowActive: focusArea == 1 && subRow == 0,
          content: _buildToggleCard(
            title: 'Dynamic Catch-Up Balance',
            desc: 'CORTEX-9 boosts hints and balances points to keep the living room match close and exciting.',
            icon: Icons.auto_awesome,
            isEnabled: _settings.adaptiveHandicap,
            isFocused: focusArea == 1 && subRow == 0,
            onTap: () {
              setState(() {
                focusArea = 1;
                subRow = 0;
                subCol = 0;
                _settings = _settings.copyWith(adaptiveHandicap: !_settings.adaptiveHandicap);
              });
            },
          ),
        ),

        const SizedBox(height: 12),

        // Row 1: Wildcard Round
        _buildSettingsSectionCard(
          icon: Icons.electric_bolt,
          title: 'SURPRISE WILDCARD BUZZER SPRINT',
          subtitle: 'High-stakes lightning round injected into match midpoint',
          isRowActive: focusArea == 1 && subRow == 1,
          content: _buildToggleCard(
            title: 'Mid-Game Wildcard Round',
            desc: 'Double-point buzzer sprint where quick fingers trigger dramatic score turnarounds.',
            icon: Icons.flash_on,
            isEnabled: _settings.wildcardRound,
            isFocused: focusArea == 1 && subRow == 1,
            onTap: () {
              setState(() {
                focusArea = 1;
                subRow = 1;
                subCol = 0;
                _settings = _settings.copyWith(wildcardRound: !_settings.wildcardRound);
              });
            },
          ),
        ),

        const SizedBox(height: 12),

        // Row 2: AI Host Persona
        _buildSettingsSectionCard(
          icon: Icons.psychology,
          title: 'CORTEX-9 HOST COMMENTARY STYLE',
          subtitle: 'Select how the AI Host speaks and interacts with players',
          isRowActive: focusArea == 1 && subRow == 2,
          content: Row(
            children: [
              for (int i = 0; i < personaOptions.length; i++) ...[
                Expanded(
                  child: _buildSelectablePill(
                    label: personaOptions[i],
                    tag: i == 0 ? 'Banter' : (i == 1 ? 'Exciting' : 'Challenging'),
                    isSelected: _settings.aiPersona == personaOptions[i],
                    isFocused: focusArea == 1 && subRow == 2 && subCol == i,
                    onTap: () {
                      setState(() {
                        focusArea = 1;
                        subRow = 2;
                        subCol = i;
                        _settings = _settings.copyWith(aiPersona: personaOptions[i]);
                      });
                    },
                  ),
                ),
                if (i < personaOptions.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // TAB 2: AUDIO & SOUND
  Widget _buildTabAudio() {
    return Column(
      key: const ValueKey(2),
      children: [
        // Row 0: Voice Host
        _buildSettingsSectionCard(
          icon: Icons.record_voice_over,
          title: 'AI VOICE SYNTHESIS & COMMENTARY',
          subtitle: 'CORTEX-9 vocal reads of questions, quips, and score updates',
          isRowActive: focusArea == 1 && subRow == 0,
          content: _buildToggleCard(
            title: 'Spoken AI Voice Host',
            desc: 'Enable real-time spoken audio commentary for TV living room immersion.',
            icon: Icons.mic,
            isEnabled: _settings.aiVoiceHost,
            isFocused: focusArea == 1 && subRow == 0,
            onTap: () {
              setState(() {
                focusArea = 1;
                subRow = 0;
                subCol = 0;
                _settings = _settings.copyWith(aiVoiceHost: !_settings.aiVoiceHost);
              });
            },
          ),
        ),

        const SizedBox(height: 12),

        // Row 1: Sound FX
        _buildSettingsSectionCard(
          icon: Icons.music_note,
          title: 'SOUND EFFECTS & BUZZER AUDIO',
          subtitle: 'Tactile sound effects for buzzers, timer ticks, and streak cheers',
          isRowActive: focusArea == 1 && subRow == 1,
          content: _buildToggleCard(
            title: 'Dynamic Game Sound Effects (SFX)',
            desc: 'Countdown ticks, buzzer hits, correct chimes, and celebration fanfare.',
            icon: Icons.volume_up,
            isEnabled: _settings.soundEffects,
            isFocused: focusArea == 1 && subRow == 1,
            onTap: () {
              setState(() {
                focusArea = 1;
                subRow = 1;
                subCol = 0;
                _settings = _settings.copyWith(soundEffects: !_settings.soundEffects);
              });
            },
          ),
        ),

        const SizedBox(height: 12),

        // Row 2: Ambient Music
        _buildSettingsSectionCard(
          icon: Icons.surround_sound,
          title: 'BACKGROUND ATMOSPHERIC MUSIC',
          subtitle: 'Soft modern synth soundtracks during questions and menu browsing',
          isRowActive: focusArea == 1 && subRow == 2,
          content: _buildToggleCard(
            title: 'Living Room Ambient Soundtrack',
            desc: 'Adaptive music that builds suspense as the countdown timer nears zero.',
            icon: Icons.audiotrack,
            isEnabled: _settings.ambientMusic,
            isFocused: focusArea == 1 && subRow == 2,
            onTap: () {
              setState(() {
                focusArea = 1;
                subRow = 2;
                subCol = 0;
                _settings = _settings.copyWith(ambientMusic: !_settings.ambientMusic);
              });
            },
          ),
        ),
      ],
    );
  }

  // TAB 3: PLAYERS & ROLES
  Widget _buildTabPlayers() {
    return Column(
      key: const ValueKey(3),
      children: [
        _buildSettingsSectionCard(
          icon: Icons.group,
          title: 'ACTIVE PLAYERS IN SESSION',
          subtitle: 'Live player profiles connected to the local room',
          isRowActive: focusArea == 1 && (subRow == 0 || subRow == 1),
          content: Column(
            children: [
              Row(
                children: [
                  for (int i = 0; i < widget.players.take(2).length; i++) ...[
                    Expanded(
                      child: _buildPlayerProfileCard(
                        player: widget.players[i],
                        isFocused: focusArea == 1 && subRow == 0 && subCol == i,
                      ),
                    ),
                    if (i < 1) const SizedBox(width: 10),
                  ],
                ],
              ),
              if (widget.players.length > 2) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (int i = 2; i < widget.players.take(4).length; i++) ...[
                      Expanded(
                        child: _buildPlayerProfileCard(
                          player: widget.players[i],
                          isFocused: focusArea == 1 && subRow == 1 && subCol == (i - 2),
                        ),
                      ),
                      if (i < 3) const SizedBox(width: 10),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Action: Reset streaks
        _buildSettingsSectionCard(
          icon: Icons.restart_alt,
          title: 'SESSION STREAKS & STATS',
          subtitle: 'Clear current session win streaks and score multipliers',
          isRowActive: focusArea == 1 && subRow == 2,
          content: InkWell(
            onTap: () {
              setState(() {
                focusArea = 1;
                subRow = 2;
                subCol = 0;
                for (var p in widget.players) {
                  p.streak = 0;
                }
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: (focusArea == 1 && subRow == 2)
                    ? Colors.white
                    : AppColors.surfaceHigh.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (focusArea == 1 && subRow == 2) ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: (focusArea == 1 && subRow == 2) ? 2.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 20,
                    color: (focusArea == 1 && subRow == 2) ? Colors.black : AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (focusArea == 1 && subRow == 2)
                        ? 'Reset All Player Streaks to 0 [OK]'
                        : 'Reset All Player Streaks to 0',
                    style: AppStyles.labelMd(
                      color: (focusArea == 1 && subRow == 2) ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- SUBWIDGET HELPERS ---

  Widget _buildPlayerProfileCard({required Player player, required bool isFocused}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFocused
            ? Colors.white
            : AppColors.surfaceLowest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.3),
          width: isFocused ? 2.5 : 1,
        ),
        boxShadow: isFocused
            ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.7), blurRadius: 16)]
            : [],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: player.accentColor,
            child: Text(
              player.name.isNotEmpty ? player.name[0] : 'P',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: AppStyles.labelMd(color: isFocused ? Colors.black : Colors.white),
                ),
                Text(
                  '${player.roleTag} • Streak: ${player.streak}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isFocused ? Colors.black87 : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'SYNCED',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isFocused ? Colors.black : AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget content,
    required bool isRowActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRowActive ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.3),
          width: isRowActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isRowActive ? AppColors.secondary : AppColors.onSurfaceVariant, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppStyles.labelMd(color: isRowActive ? AppColors.secondary : AppColors.onSurfaceVariant),
              ),
              const Spacer(),
              if (isRowActive)
                Text(
                  'D-Pad: ◄/► • [OK]',
                  style: AppStyles.labelMd(color: AppColors.secondary),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: AppStyles.bodyMd(color: AppColors.outlineVariant)),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildSelectablePill({
    required String label,
    required String tag,
    required bool isSelected,
    required bool isFocused,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isFocused
              ? Colors.white
              : (isSelected ? AppColors.secondary.withValues(alpha: 0.25) : AppColors.surfaceHigh.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFocused
                ? AppColors.secondary
                : (isSelected ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.3)),
            width: isFocused ? 3 : (isSelected ? 2 : 1),
          ),
          boxShadow: isFocused
              ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.8), blurRadius: 18)]
              : (isSelected ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.2), blurRadius: 8)] : []),
        ),
        child: Column(
          children: [
            Text(
              isFocused ? '$label [OK]' : label,
              style: AppStyles.labelMd(
                color: isFocused ? Colors.black : (isSelected ? Colors.white : AppColors.onSurface),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isFocused
                    ? Colors.black.withValues(alpha: 0.1)
                    : (isSelected ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.surfaceLowest),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isFocused ? Colors.black87 : (isSelected ? AppColors.secondary : AppColors.outlineVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String desc,
    required IconData icon,
    required bool isEnabled,
    required bool isFocused,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFocused
              ? (isEnabled ? Colors.white : const Color(0xFF2A2838))
              : (isEnabled ? AppColors.secondary.withValues(alpha: 0.18) : AppColors.surfaceLowest.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFocused
                ? AppColors.secondary
                : (isEnabled ? AppColors.secondary.withValues(alpha: 0.6) : AppColors.outlineVariant.withValues(alpha: 0.3)),
            width: isFocused ? 3 : (isEnabled ? 2 : 1),
          ),
          boxShadow: isFocused
              ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.7), blurRadius: 16)]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isFocused ? (isEnabled ? Colors.black : Colors.white) : (isEnabled ? AppColors.secondary : AppColors.outlineVariant),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFocused ? '$title [OK]' : title,
                    style: AppStyles.labelMd(
                      color: isFocused ? (isEnabled ? Colors.black : Colors.white) : (isEnabled ? Colors.white : AppColors.onSurfaceVariant),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 10,
                      color: isFocused ? (isEnabled ? Colors.black54 : Colors.white70) : AppColors.outlineVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isEnabled ? AppColors.emeraldReady : AppColors.outlineVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isEnabled ? 'ON' : 'OFF',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.secondary, size: 14),
        const SizedBox(width: 4),
        Text(text, style: AppStyles.labelMd()),
      ],
    );
  }

  Widget _buildDotSeparator() {
    return Text('•', style: TextStyle(color: AppColors.outlineVariant));
  }

  Widget _buildSynthesisPill(String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: color, size: 14),
              const SizedBox(width: 6),
              Text(title, style: AppStyles.labelMd()),
            ],
          ),
          Text(status, style: AppStyles.labelMd(color: color)),
        ],
      ),
    );
  }
}
