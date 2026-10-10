import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_orb.dart';
import '../models/game_settings.dart';
import '../models/player.dart';

class AiSynthesisScreen extends StatefulWidget {
  final VoidCallback onStartGame;
  final String? lastRemoteCommand;
  final GameSettings? gameSettings;
  final ValueChanged<GameSettings>? onSettingsChanged;
  final List<Player> players;
  final String selectedCategory;
  final String selectedDifficulty;

  const AiSynthesisScreen({
    super.key,
    required this.onStartGame,
    this.lastRemoteCommand,
    this.gameSettings,
    this.onSettingsChanged,
    this.players = const [],
    this.selectedCategory = 'Cinema Clues',
    this.selectedDifficulty = 'ADAPTIVE',
  });

  @override
  State<AiSynthesisScreen> createState() => _AiSynthesisScreenState();
}

class _AiSynthesisScreenState extends State<AiSynthesisScreen> with TickerProviderStateMixin {
  late GameSettings _settings;

  // Remote D-Pad 2D Navigation Grid
  // Row 0: Question Count (cols 0..2) -> 5, 10, 15
  // Row 1: Timer Duration (cols 0..3) -> 10s, 15s, 20s, 30s
  // Row 2: AI Engine Toggles (cols 0..1) -> Adaptive Handicap, Wildcard Round
  // Row 3: Audio Toggles (cols 0..2) -> AI Voice Host, Sound FX, Ambient Music
  // Row 4: Start Game Button (col 0)
  int focusRow = 4; // Start focused on Start Game button for rapid launch
  int focusCol = 0;

  final List<int> questionCountOptions = [5, 10, 15];
  final List<int> timerOptions = [10, 15, 20, 30];

  @override
  void initState() {
    super.initState();
    _settings = widget.gameSettings?.copyWith() ?? GameSettings();
  }

  @override
  void didUpdateWidget(AiSynthesisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameSettings != null && widget.gameSettings != oldWidget.gameSettings) {
      _settings = widget.gameSettings!.copyWith();
    }

    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;
      _handleRemoteDpad(cmd);
    }
  }

  void _handleRemoteDpad(String cmd) {
    setState(() {
      if (cmd == 'UP') {
        if (focusRow > 0) {
          focusRow--;
          focusCol = _clampCol(focusRow, focusCol);
        }
      } else if (cmd == 'DOWN') {
        if (focusRow < 4) {
          focusRow++;
          focusCol = _clampCol(focusRow, focusCol);
        }
      } else if (cmd == 'LEFT') {
        final maxC = _maxColForRow(focusRow);
        focusCol = (focusCol - 1 + (maxC + 1)) % (maxC + 1);
      } else if (cmd == 'RIGHT') {
        final maxC = _maxColForRow(focusRow);
        focusCol = (focusCol + 1) % (maxC + 1);
      } else if (cmd == 'OK') {
        _activateFocusedItem();
      }
    });
  }

  int _maxColForRow(int row) {
    switch (row) {
      case 0:
        return 2; // 3 options: 5, 10, 15
      case 1:
        return 3; // 4 options: 10, 15, 20, 30
      case 2:
        return 1; // 2 toggles: Adaptive, Wildcard
      case 3:
        return 2; // 3 toggles: Voice, SFX, Ambience
      case 4:
      default:
        return 0; // 1 button: Start
    }
  }

  int _clampCol(int row, int col) {
    final maxC = _maxColForRow(row);
    return col.clamp(0, maxC);
  }

  void _activateFocusedItem() {
    if (focusRow == 0) {
      final val = questionCountOptions[focusCol];
      _updateSettings(_settings.copyWith(questionCount: val));
    } else if (focusRow == 1) {
      final val = timerOptions[focusCol];
      _updateSettings(_settings.copyWith(timerSeconds: val));
    } else if (focusRow == 2) {
      if (focusCol == 0) {
        _updateSettings(_settings.copyWith(adaptiveHandicap: !_settings.adaptiveHandicap));
      } else {
        _updateSettings(_settings.copyWith(wildcardRound: !_settings.wildcardRound));
      }
    } else if (focusRow == 3) {
      if (focusCol == 0) {
        _updateSettings(_settings.copyWith(aiVoiceHost: !_settings.aiVoiceHost));
      } else if (focusCol == 1) {
        _updateSettings(_settings.copyWith(soundEffects: !_settings.soundEffects));
      } else {
        _updateSettings(_settings.copyWith(ambientMusic: !_settings.ambientMusic));
      }
    } else if (focusRow == 4) {
      widget.onStartGame();
    }
  }

  void _updateSettings(GameSettings updated) {
    setState(() => _settings = updated);
    widget.onSettingsChanged?.call(updated);
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
          // 1. HEADER ROW (Overflow Protected)
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
                    Text('D-Pad [Arrows] Navigate • [OK] Toggle', style: AppStyles.labelMd(color: AppColors.secondary)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. MAIN TWO-COLUMN STUDIO GRID
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (Flex 5): CORTEX-9 AI Orb & Dynamic Insight Console
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                      // Pulsing AI Orb
                      const AiOrbWidget(size: 200, label: 'CORTEX-9'),
                      const SizedBox(height: 16),
                      Text('Dynamic Match Synthesizer', style: AppStyles.headlineMd()),
                      const SizedBox(height: 4),
                      Text(
                        'Engine calibrated for $playerNames',
                        style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

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
                            _buildInfoBadge(Icons.timer, '${_settings.timerSeconds}s / Question'),
                            _buildDotSeparator(),
                            _buildInfoBadge(Icons.hourglass_bottom, '~$estimatedMinutes Min Match'),
                            _buildDotSeparator(),
                            _buildInfoBadge(Icons.category, widget.selectedCategory),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // AI Host Observation Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLowest.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.psychology, color: AppColors.secondary, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CORTEX-9 HOST LOGIC', style: AppStyles.labelMd(color: AppColors.secondary)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"Synthesized ${widget.selectedCategory} trivia for $playerNames. '
                                    '${_settings.adaptiveHandicap ? "Adaptive handicap will dynamically balance point weights" : "Standard point weights applied"}. '
                                    '${_settings.wildcardRound ? "Surprise buzzer round enabled!" : "Single phase play."}"',
                                    style: AppStyles.bodyMd(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Synthesis Checklist Indicators
                      _buildSynthesisPill('AI Dynamic Question Bank', 'LOADED (Supabase DB)', AppColors.emeraldReady),
                      const SizedBox(height: 8),
                      _buildSynthesisPill(
                        'Adaptive Player Handicap',
                        _settings.adaptiveHandicap ? 'ACTIVE (Real-time tuning)' : 'DISABLED',
                        _settings.adaptiveHandicap ? AppColors.secondary : AppColors.outlineVariant,
                      ),
                      const SizedBox(height: 8),
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

              // RIGHT COLUMN (Flex 7): Interactive TV Settings Controls
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    // Setting Card 1: Question Count
                    _buildSettingsSectionCard(
                      icon: Icons.format_list_numbered,
                      title: 'MATCH LENGTH (QUESTION COUNT)',
                      subtitle: 'Choose how many questions to play before the Winner Celebration',
                      isRowActive: focusRow == 0,
                      content: Row(
                        children: [
                          for (int i = 0; i < questionCountOptions.length; i++) ...[
                            Expanded(
                              child: _buildSelectablePill(
                                label: '${questionCountOptions[i]} Questions',
                                tag: i == 0 ? 'Blitz' : (i == 1 ? 'Standard' : 'Championship'),
                                isSelected: _settings.questionCount == questionCountOptions[i],
                                isFocused: focusRow == 0 && focusCol == i,
                                onTap: () {
                                  setState(() {
                                    focusRow = 0;
                                    focusCol = i;
                                  });
                                  _updateSettings(_settings.copyWith(questionCount: questionCountOptions[i]));
                                },
                              ),
                            ),
                            if (i < questionCountOptions.length - 1) const SizedBox(width: 12),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Setting Card 2: Question Countdown Timer
                    _buildSettingsSectionCard(
                      icon: Icons.alarm,
                      title: 'COUNTDOWN TIMER PER QUESTION',
                      subtitle: 'Pacing for living room sofa buzzers and answer submission',
                      isRowActive: focusRow == 1,
                      content: Row(
                        children: [
                          for (int i = 0; i < timerOptions.length; i++) ...[
                            Expanded(
                              child: _buildSelectablePill(
                                label: '${timerOptions[i]} Seconds',
                                tag: i == 0 ? 'Speed' : (i == 1 ? 'Default' : (i == 2 ? 'Relaxed' : 'Party')),
                                isSelected: _settings.timerSeconds == timerOptions[i],
                                isFocused: focusRow == 1 && focusCol == i,
                                onTap: () {
                                  setState(() {
                                    focusRow = 1;
                                    focusCol = i;
                                  });
                                  _updateSettings(_settings.copyWith(timerSeconds: timerOptions[i]));
                                },
                              ),
                            ),
                            if (i < timerOptions.length - 1) const SizedBox(width: 10),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Setting Card 3: AI & Game Engine Dynamics
                    _buildSettingsSectionCard(
                      icon: Icons.auto_awesome,
                      title: 'AI ENGINE & GAMEPLAY DYNAMICS',
                      subtitle: 'Intelligent handicap balance and surprise buzzer sprint',
                      isRowActive: focusRow == 2,
                      content: Row(
                        children: [
                          Expanded(
                            child: _buildToggleCard(
                              title: 'Adaptive Handicap',
                              desc: 'AI adapts points & hints for younger/trailing players',
                              icon: Icons.balance,
                              isEnabled: _settings.adaptiveHandicap,
                              isFocused: focusRow == 2 && focusCol == 0,
                              onTap: () {
                                setState(() {
                                  focusRow = 2;
                                  focusCol = 0;
                                });
                                _updateSettings(_settings.copyWith(adaptiveHandicap: !_settings.adaptiveHandicap));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildToggleCard(
                              title: 'Wildcard Round',
                              desc: 'Surprise double-point buzzer sprint mid-game',
                              icon: Icons.electric_bolt,
                              isEnabled: _settings.wildcardRound,
                              isFocused: focusRow == 2 && focusCol == 1,
                              onTap: () {
                                setState(() {
                                  focusRow = 2;
                                  focusCol = 1;
                                });
                                _updateSettings(_settings.copyWith(wildcardRound: !_settings.wildcardRound));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Setting Card 4: Audio & Immersion
                    _buildSettingsSectionCard(
                      icon: Icons.volume_up,
                      title: 'AUDIO & LIVING ROOM IMMERSION',
                      subtitle: 'Voice synthesis commentary, sound effects, and ambient music',
                      isRowActive: focusRow == 3,
                      content: Row(
                        children: [
                          Expanded(
                            child: _buildToggleCard(
                              title: 'AI Host Voice',
                              desc: 'Spoken commentary & quips',
                              icon: Icons.record_voice_over,
                              isEnabled: _settings.aiVoiceHost,
                              isFocused: focusRow == 3 && focusCol == 0,
                              onTap: () {
                                setState(() {
                                  focusRow = 3;
                                  focusCol = 0;
                                });
                                _updateSettings(_settings.copyWith(aiVoiceHost: !_settings.aiVoiceHost));
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildToggleCard(
                              title: 'Sound FX',
                              desc: 'Buzzers & ticking',
                              icon: Icons.music_note,
                              isEnabled: _settings.soundEffects,
                              isFocused: focusRow == 3 && focusCol == 1,
                              onTap: () {
                                setState(() {
                                  focusRow = 3;
                                  focusCol = 1;
                                });
                                _updateSettings(_settings.copyWith(soundEffects: !_settings.soundEffects));
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildToggleCard(
                              title: 'Ambient Music',
                              desc: 'Background synth',
                              icon: Icons.surround_sound,
                              isEnabled: _settings.ambientMusic,
                              isFocused: focusRow == 3 && focusCol == 2,
                              onTap: () {
                                setState(() {
                                  focusRow = 3;
                                  focusCol = 2;
                                });
                                _updateSettings(_settings.copyWith(ambientMusic: !_settings.ambientMusic));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 5. PROMINENT LAUNCH CTA (Focus Row 4)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: (focusRow == 4)
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
                        onPressed: () {
                          setState(() => focusRow = 4);
                          widget.onStartGame();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          backgroundColor: (focusRow == 4) ? Colors.white : AppColors.secondaryContainer,
                          minimumSize: const Size(double.infinity, 70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: (focusRow == 4) ? AppColors.secondary : Colors.transparent,
                              width: (focusRow == 4) ? 3.5 : 0,
                            ),
                          ),
                          elevation: (focusRow == 4) ? 16 : 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color: (focusRow == 4) ? Colors.black : Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              (focusRow == 4) ? 'START GAME [OK] ◄' : 'START GAME [OK]',
                              style: AppStyles.headlineLg(
                                color: (focusRow == 4) ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
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

  // --- SUBWIDGET HELPERS ---

  Widget _buildSettingsSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget content,
    required bool isRowActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRowActive ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.35),
          width: isRowActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isRowActive ? AppColors.secondary : AppColors.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppStyles.labelMd(color: isRowActive ? AppColors.secondary : AppColors.onSurfaceVariant),
              ),
              const Spacer(),
              if (isRowActive)
                Text(
                  'D-Pad: ◄ Left | Right ► • [OK]',
                  style: AppStyles.labelMd(color: AppColors.secondary),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: AppStyles.bodyMd(color: AppColors.outlineVariant)),
          const SizedBox(height: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            const SizedBox(width: 8),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title, style: AppStyles.labelMd()),
            ],
          ),
          Text(status, style: AppStyles.labelMd(color: color)),
        ],
      ),
    );
  }
}
