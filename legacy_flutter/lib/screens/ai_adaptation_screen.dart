import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_orb.dart';
import '../models/player.dart';
import '../services/api_service.dart';

class AdaptiveFormula {
  final String id;
  final String name;
  final String targetDifficulty;
  final String formulaBadge;
  final String description;
  final String speedBonusText;
  final Color accentColor;
  final IconData icon;

  const AdaptiveFormula({
    required this.id,
    required this.name,
    required this.targetDifficulty,
    required this.formulaBadge,
    required this.description,
    required this.speedBonusText,
    required this.accentColor,
    required this.icon,
  });
}

class SurpriseChallengeOption {
  final String id;
  final String title;
  final String description;
  final String stakes;
  final String bounty;
  final int bonusPoints;
  final Color themeColor;
  final IconData icon;

  const SurpriseChallengeOption({
    required this.id,
    required this.title,
    required this.description,
    required this.stakes,
    required this.bounty,
    required this.bonusPoints,
    required this.themeColor,
    required this.icon,
  });
}

class AiAdaptationScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final String? lastRemoteCommand;
  final List<Player> players;
  final String currentDifficulty;
  final String sessionId;
  final Function(String newDifficulty, Map<String, dynamic> challenge)? onApplySettings;

  const AiAdaptationScreen({
    super.key,
    required this.onContinue,
    this.lastRemoteCommand,
    this.players = const [],
    this.currentDifficulty = 'MEDIUM',
    this.sessionId = 'session_live_4892',
    this.onApplySettings,
  });

  @override
  State<AiAdaptationScreen> createState() => _AiAdaptationScreenState();
}

class _AiAdaptationScreenState extends State<AiAdaptationScreen> with TickerProviderStateMixin {
  // 0: Voice Broadcast, 1: Balance Engine, 2: Surprise Event, 3: Players, 4: Continue CTA
  int focusZone = 4;
  int selectedFormulaIndex = 0;
  int selectedChallengeIndex = 0;
  int speedBonusSeconds = 5;
  bool underdogBoostActive = true;

  bool isVoicePlaying = false;
  bool isBuzzerTesting = false;
  Player? lastBuzzedPlayer;
  int buzzerReactionMs = 158;
  String dynamicReason = '';

  final ApiService _apiService = ApiService();
  late AnimationController _voiceWaveController;
  late AnimationController _buzzerPulseController;
  Timer? _buzzerResetTimer;
  Timer? _voiceAutoTimer;

  static const List<AdaptiveFormula> formulas = [
    AdaptiveFormula(
      id: 'pace',
      name: 'ADAPTIVE PACE',
      targetDifficulty: 'MEDIUM',
      formulaBadge: 'Medium+',
      description: 'Dynamic pacing based on player reaction velocity and living room momentum.',
      speedBonusText: '+50 PTS bonus for <5s quick answer bonus.',
      accentColor: AppColors.secondary,
      icon: Icons.tune,
    ),
    AdaptiveFormula(
      id: 'turbo',
      name: 'TURBO OVERDRIVE',
      targetDifficulty: 'HARD',
      formulaBadge: 'Hard [2x]',
      description: 'Elevated difficulty multiplier for high-scoring streak masters.',
      speedBonusText: '+100 PTS speed bonus + 2x streak multiplier.',
      accentColor: AppColors.primary,
      icon: Icons.bolt,
    ),
    AdaptiveFormula(
      id: 'harmony',
      name: 'FAMILY HARMONY',
      targetDifficulty: 'EASY',
      formulaBadge: 'Catch-Up+',
      description: 'Living room rebalancing. Underdog handicap assists trailing players with bonus stakes.',
      speedBonusText: '+100 PTS comeback bonus for trailing player.',
      accentColor: AppColors.emeraldReady,
      icon: Icons.favorite,
    ),
  ];

  late List<SurpriseChallengeOption> challenges;

  @override
  void initState() {
    super.initState();

    challenges = [
      const SurpriseChallengeOption(
        id: 'buzzer',
        title: 'SURPRISE ROUND: BUZZER BLITZ!',
        description: 'First player to buzz in gets exclusive rights to answer! Double Points!',
        stakes: 'STAKES: DOUBLE POINTS',
        bounty: 'BOUNTY: +300 PTS / Q',
        bonusPoints: 300,
        themeColor: AppColors.tertiary,
        icon: Icons.electric_bolt,
      ),
      const SurpriseChallengeOption(
        id: 'lightning',
        title: 'SURPRISE ROUND: LIGHTNING SPRINT!',
        description: 'Rapid 5-second countdown clock per player! Maximum speed bonus awarded!',
        stakes: 'STAKES: 5s RAPID CLOCK',
        bounty: 'BOUNTY: +400 PTS / Q',
        bonusPoints: 400,
        themeColor: AppColors.amberWarning,
        icon: Icons.speed,
      ),
      const SurpriseChallengeOption(
        id: 'teamup',
        title: 'SURPRISE ROUND: FAMILY TEAM-UP!',
        description: 'Living room consensus round! Confer with everyone and lock in the collective answer!',
        stakes: 'STAKES: SHARED JACKPOT',
        bounty: 'BOUNTY: +500 PTS POOL',
        bonusPoints: 500,
        themeColor: AppColors.secondary,
        icon: Icons.diversity_3,
      ),
    ];

    _voiceWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _buzzerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _analyzeTelemetry();
    _loadBackendInsights();
  }

  void _analyzeTelemetry() {
    final effectivePlayers = widget.players.isNotEmpty ? widget.players : Player.getDefaultPlayers();
    final sorted = List<Player>.from(effectivePlayers)..sort((a, b) => b.score.compareTo(a.score));
    final leader = sorted.first;
    final chaser = sorted.length > 1 ? sorted[1] : null;
    final trailing = sorted.last;

    final streakPlayer = effectivePlayers.reduce((c, n) => n.streak > c.streak ? n : c);

    if (streakPlayer.streak >= 2 && chaser != null) {
      dynamicReason = 'CORTEX-9 noticed ${streakPlayer.name} is on a ${streakPlayer.streak}-question streak (${streakPlayer.score} PTS) and ${chaser.name} is closing in (${chaser.score} PTS). Rebalancing room difficulty and launching a SURPRISE ROUND!';
    } else if (chaser != null && (leader.score - chaser.score).abs() <= 50) {
      dynamicReason = 'DEAD HEAT! ${leader.name} (${leader.score} PTS) and ${chaser.name} (${chaser.score} PTS) are neck-and-neck! Elevating stakes for a thrilling SURPRISE ROUND!';
    } else if (sorted.length > 1 && (leader.score - trailing.score) >= 100) {
      dynamicReason = 'CORTEX-9 detected score spread. Dynamic catch-up matrix armed to give ${trailing.name} a comeback runway in the SURPRISE ROUND!';
    } else {
      dynamicReason = 'CORTEX-9 rebalanced living room pacing across ${effectivePlayers.length} synced remotes. Activating SURPRISE ROUND!';
    }
  }

  Future<void> _loadBackendInsights() async {
    try {
      final challengeData = await _apiService.fetchSurpriseChallenge(widget.sessionId);
      if (mounted && challengeData['title'] != null) {
        setState(() {
          challenges[0] = SurpriseChallengeOption(
            id: 'buzzer',
            title: challengeData['title'] as String,
            description: challengeData['description'] as String? ?? challenges[0].description,
            stakes: 'STAKES: DOUBLE POINTS',
            bounty: 'BOUNTY: +${challengeData['bonusPoints'] ?? 300} PTS / Q',
            bonusPoints: (challengeData['bonusPoints'] as num?)?.toInt() ?? 300,
            themeColor: AppColors.tertiary,
            icon: Icons.electric_bolt,
          );
        });
      }
      final adaptData = await _apiService.fetchAdaptiveDifficulty(sessionId: widget.sessionId);
      if (mounted && adaptData['newDifficulty'] != null) {
        // Match formula if possible
        final diffStr = (adaptData['newDifficulty'] as String).toUpperCase();
        if (diffStr.contains('HARD')) {
          setState(() => selectedFormulaIndex = 1);
        } else if (diffStr.contains('EASY')) {
          setState(() => selectedFormulaIndex = 2);
        }
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(AiAdaptationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;

      if (cmd == 'UP') {
        setState(() => focusZone = (focusZone - 1).clamp(0, 4));
      } else if (cmd == 'DOWN') {
        setState(() => focusZone = (focusZone + 1).clamp(0, 4));
      } else if (cmd == 'LEFT') {
        if (focusZone == 1) {
          setState(() => selectedFormulaIndex = (selectedFormulaIndex - 1 + formulas.length) % formulas.length);
        } else if (focusZone == 2) {
          setState(() => selectedChallengeIndex = (selectedChallengeIndex - 1 + challenges.length) % challenges.length);
        }
      } else if (cmd == 'RIGHT') {
        if (focusZone == 1) {
          setState(() => selectedFormulaIndex = (selectedFormulaIndex + 1) % formulas.length);
        } else if (focusZone == 2) {
          setState(() => selectedChallengeIndex = (selectedChallengeIndex + 1) % challenges.length);
        }
      } else if (cmd == 'OK') {
        if (focusZone == 0) {
          _toggleVoiceBroadcast();
        } else if (focusZone == 1) {
          setState(() => selectedFormulaIndex = (selectedFormulaIndex + 1) % formulas.length);
        } else if (focusZone == 2) {
          _triggerBuzzerTest();
        } else {
          _handleContinue();
        }
      } else if (cmd == 'BUZZ') {
        _triggerBuzzerTest();
      } else if (cmd == 'MIC') {
        _toggleVoiceBroadcast();
      }
    }
  }

  void _triggerBuzzerTest() {
    _buzzerResetTimer?.cancel();
    final effectivePlayers = widget.players.isNotEmpty ? widget.players : Player.getDefaultPlayers();
    final random = math.Random();
    final candidate = effectivePlayers[random.nextInt(effectivePlayers.length)];
    final reaction = 120 + random.nextInt(95);

    _buzzerPulseController.forward(from: 0.0);
    setState(() {
      isBuzzerTesting = true;
      lastBuzzedPlayer = candidate;
      buzzerReactionMs = reaction;
    });

    _buzzerResetTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        setState(() => isBuzzerTesting = false);
      }
    });
  }

  void _toggleVoiceBroadcast() {
    _voiceAutoTimer?.cancel();
    setState(() {
      isVoicePlaying = !isVoicePlaying;
    });

    if (isVoicePlaying) {
      _voiceWaveController.repeat();
      _voiceAutoTimer = Timer(const Duration(seconds: 7), () {
        if (mounted) {
          setState(() => isVoicePlaying = false);
          _voiceWaveController.stop();
        }
      });
    } else {
      _voiceWaveController.stop();
    }
  }

  void _handleContinue() {
    final formula = formulas[selectedFormulaIndex];
    final challenge = challenges[selectedChallengeIndex];
    widget.onApplySettings?.call(
      formula.targetDifficulty,
      {
        'title': challenge.title,
        'description': challenge.description,
        'bonusPoints': challenge.bonusPoints,
        'stakes': challenge.stakes,
        'bounty': challenge.bounty,
        'formulaName': formula.name,
      },
    );
    widget.onContinue();
  }

  @override
  void dispose() {
    _voiceWaveController.dispose();
    _buzzerPulseController.dispose();
    _buzzerResetTimer?.cancel();
    _voiceAutoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectivePlayers = widget.players.isNotEmpty ? widget.players : Player.getDefaultPlayers();
    final activeFormula = formulas[selectedFormulaIndex];
    final activeChallenge = challenges[selectedChallengeIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Center Orb & Header
          const AiOrbWidget(size: 130, label: 'CORTEX-9'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.tertiary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, color: AppColors.tertiary, size: 18),
                const SizedBox(width: 8),
                Text('REAL-TIME GAME MATRIX ADJUSTMENT', style: AppStyles.labelMd(color: AppColors.tertiary)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('AI ADAPTATION TRIGGERED!', style: AppStyles.headlineXl(color: Colors.white)),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Text(
              dynamicReason,
              style: AppStyles.bodyLg(color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 14),

          // 2. Interactive CORTEX-9 AI Voice Broadcast Bar
          _buildVoiceBroadcastBar(activeFormula, activeChallenge),

          const SizedBox(height: 18),

          // 3. TWO SHOWCASE INTERACTIVE TV CARDS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card 1: Balance Engine / Dynamic Difficulty Shift
              Expanded(
                child: _buildBalanceEngineCard(activeFormula),
              ),

              const SizedBox(width: 20),

              // Card 2: Surprise Round Buzzer Blitz
              Expanded(
                child: _buildSurpriseRoundCard(activeChallenge),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 4. Live Players Buzzer Status Strip
          _buildPlayerBuzzerStatusStrip(effectivePlayers),

          const SizedBox(height: 20),

          // 5. Dynamic CTA Button
          _buildContinueButton(activeChallenge),
        ],
      ),
    );
  }

  Widget _buildVoiceBroadcastBar(AdaptiveFormula formula, SurpriseChallengeOption challenge) {
    final isFocused = focusZone == 0;
    return GestureDetector(
      onTap: _toggleVoiceBroadcast,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isVoicePlaying
              ? AppColors.primaryContainer.withValues(alpha: 0.25)
              : AppColors.surfaceLow.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused
                ? AppColors.secondary
                : (isVoicePlaying ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.4)),
            width: isFocused ? 2.5 : 1.0,
          ),
          boxShadow: isFocused || isVoicePlaying
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isVoicePlaying ? AppColors.primaryContainer : AppColors.surfaceHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVoicePlaying ? Icons.record_voice_over : Icons.mic_none,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Audio wave bars
            if (isVoicePlaying)
              AnimatedBuilder(
                animation: _voiceWaveController,
                builder: (context, child) {
                  return Row(
                    children: List.generate(7, (i) {
                      final val = math.sin((_voiceWaveController.value * 2 * math.pi) + (i * 0.8)).abs();
                      final h = 8.0 + (val * 16.0);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 3.5,
                        height: h,
                        decoration: BoxDecoration(
                          color: i.isEven ? AppColors.secondary : AppColors.tertiary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              )
            else
              const Icon(Icons.graphic_eq, color: AppColors.outline, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                isVoicePlaying
                    ? '“Attention players! Room matrix adapted to ${formula.name}. Remote buzzers are armed for ${challenge.title}!”'
                    : 'Tap to listen to CORTEX-9 vocal synthesis broadcast [MIC / M]',
                style: AppStyles.bodyMd(color: isVoicePlaying ? Colors.white : AppColors.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isVoicePlaying ? AppColors.secondaryContainer : AppColors.surfaceHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isVoicePlaying ? 'AUDIO LIVE' : 'PLAY [M]',
                style: AppStyles.labelMd(color: Colors.white).copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceEngineCard(AdaptiveFormula activeFormula) {
    final isFocused = focusZone == 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFocused ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.5),
          width: isFocused ? 2.5 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.35),
                  blurRadius: 25,
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: activeFormula.accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(activeFormula.icon, color: activeFormula.accentColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BALANCE ENGINE', style: AppStyles.labelMd(color: activeFormula.accentColor)),
                      Text('DYNAMIC DIFFICULTY SHIFT', style: AppStyles.headlineMd(color: Colors.white)),
                    ],
                  ),
                ],
              ),
              // Preset Switcher Indicators
              Row(
                children: List.generate(formulas.length, (i) {
                  final isSel = selectedFormulaIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFormulaIndex = i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSel ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSel ? activeFormula.accentColor : AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Previous vs New Formula Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PREVIOUS', style: AppStyles.labelMd(color: AppColors.outline)),
                      const SizedBox(height: 2),
                      Text(widget.currentDifficulty, style: AppStyles.headlineMd(color: AppColors.outline)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: activeFormula.accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: activeFormula.accentColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEW FORMULA', style: AppStyles.labelMd(color: activeFormula.accentColor)),
                      const SizedBox(height: 2),
                      Text(activeFormula.formulaBadge, style: AppStyles.headlineMd(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Interactive Formula Mode Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: formulas.asMap().entries.map((e) {
                final isCurrent = selectedFormulaIndex == e.key;
                final f = e.value;
                return GestureDetector(
                  onTap: () => setState(() => selectedFormulaIndex = e.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent ? f.accentColor.withValues(alpha: 0.3) : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent ? f.accentColor : AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      f.name,
                      style: AppStyles.labelMd(color: isCurrent ? Colors.white : AppColors.onSurfaceVariant)
                          .copyWith(fontSize: 13),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          Text(activeFormula.description, style: AppStyles.bodyMd(color: Colors.white70)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.emeraldReady, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(activeFormula.speedBonusText, style: AppStyles.bodyMd(color: AppColors.secondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSurpriseRoundCard(SurpriseChallengeOption activeChallenge) {
    final isFocused = focusZone == 2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFocused ? AppColors.secondary : activeChallenge.themeColor,
          width: isFocused ? 2.5 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: activeChallenge.themeColor.withValues(alpha: isFocused ? 0.45 : 0.25),
            blurRadius: 35,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: activeChallenge.themeColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(activeChallenge.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CORTEX-9 SPECIAL EVENT', style: AppStyles.labelMd(color: activeChallenge.themeColor)),
                      Text(activeChallenge.title, style: AppStyles.headlineMd(color: Colors.white)),
                    ],
                  ),
                ],
              ),
              // Challenge Mode Navigation Arrows
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white70),
                    onPressed: () {
                      setState(() {
                        selectedChallengeIndex =
                            (selectedChallengeIndex - 1 + challenges.length) % challenges.length;
                      });
                    },
                    tooltip: 'Previous challenge',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white70),
                    onPressed: () {
                      setState(() {
                        selectedChallengeIndex = (selectedChallengeIndex + 1) % challenges.length;
                      });
                    },
                    tooltip: 'Next challenge',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rule banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: activeChallenge.themeColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active, color: activeChallenge.themeColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    activeChallenge.description,
                    style: AppStyles.bodyMd(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(activeChallenge.stakes, style: AppStyles.labelMd(color: AppColors.secondary)),
              Text(activeChallenge.bounty, style: AppStyles.labelMd(color: activeChallenge.themeColor)),
            ],
          ),

          const SizedBox(height: 12),

          // Interactive Test Buzzer Button
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _triggerBuzzerTest,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: isBuzzerTesting
                          ? const LinearGradient(colors: [AppColors.amberWarning, AppColors.tertiaryContainer])
                          : LinearGradient(colors: [
                              activeChallenge.themeColor.withValues(alpha: 0.3),
                              AppColors.surfaceBright,
                            ]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isBuzzerTesting ? Colors.white : activeChallenge.themeColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: isBuzzerTesting ? Colors.white : activeChallenge.themeColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBuzzerTesting ? 'BUZZER TRIGGERED! [B]' : 'TEST BUZZER SIMULATOR [B]',
                          style: AppStyles.labelMd(color: Colors.white).copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Buzzer feedback pill
          if (isBuzzerTesting && lastBuzzedPlayer != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.amberWarning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.amberWarning),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: lastBuzzedPlayer!.accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🚨 ${lastBuzzedPlayer!.name} buzzed in first! (${buzzerReactionMs}ms) • EXCLUSIVE ANSWER LOCKED',
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerBuzzerStatusStrip(List<Player> players) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.sensors, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text('LIVE MATRIX STATUS', style: AppStyles.labelMd(color: AppColors.outline)),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: players.map((p) {
                final isLastBuzzed = lastBuzzedPlayer?.id == p.id && isBuzzerTesting;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      lastBuzzedPlayer = p;
                      isBuzzerTesting = true;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLastBuzzed ? p.accentColor.withValues(alpha: 0.3) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isLastBuzzed ? p.accentColor : AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 5, backgroundColor: p.accentColor),
                        const SizedBox(width: 6),
                        Text(p.name, style: AppStyles.labelMd(color: Colors.white).copyWith(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text('${p.score}pts', style: TextStyle(fontSize: 12, color: p.accentColor)),
                        if (p.streak > 1) ...[
                          const SizedBox(width: 4),
                          Text('🔥${p.streak}', style: const TextStyle(fontSize: 11, color: AppColors.amberWarning)),
                        ],
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.emeraldReady,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Text(
            '${players.length} Buzzers Armed',
            style: AppStyles.bodyMd(color: AppColors.emeraldReady),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(SurpriseChallengeOption activeChallenge) {
    final isFocused = focusZone == 4;

    return ElevatedButton(
      onPressed: _handleContinue,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
        backgroundColor: AppColors.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: isFocused ? 24 : 14,
        shadowColor: AppColors.secondary,
        side: isFocused ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CONTINUE TO SURPRISE ROUND [OK]',
            style: AppStyles.headlineMd(color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.play_arrow, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
