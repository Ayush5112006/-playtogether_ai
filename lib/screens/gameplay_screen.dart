import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';
import '../models/player.dart';
import '../services/api_service.dart';

class GameplayScreen extends StatefulWidget {
  final List<Question> questions;
  final List<Player> players;
  final VoidCallback onTriggerAdaptation;
  final VoidCallback onGameFinished;
  final ValueChanged<int> onScoreUpdate;
  final String? lastRemoteCommand;
  final int initialQuestionIndex;
  final String sessionId;
  final int questionTimerSeconds;
  final int questionCountLimit;

  const GameplayScreen({
    super.key,
    required this.questions,
    required this.players,
    required this.onTriggerAdaptation,
    required this.onGameFinished,
    required this.onScoreUpdate,
    this.initialQuestionIndex = 0,
    this.lastRemoteCommand,
    this.sessionId = 'session_live_4892',
    this.questionTimerSeconds = 15,
    this.questionCountLimit = 10,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late int currentQuestionIndex;
  int selectedOptionIndex = 0;
  late int secondsRemaining;
  Timer? _timer;
  bool isAnswerSubmitted = false;
  bool? lastAnswerCorrect;
  String? lastExplanation;
  int activePlayerTurnIndex = 0;

  final ApiService _apiService = ApiService();

  @override
  void didUpdateWidget(GameplayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;

      if (cmd == 'LEFT') {
        setState(() => selectedOptionIndex = 0);
      } else if (cmd == 'UP') {
        setState(() => selectedOptionIndex = 1);
      } else if (cmd == 'DOWN') {
        setState(() => selectedOptionIndex = 2);
      } else if (cmd == 'RIGHT') {
        setState(() => selectedOptionIndex = 3);
      } else if (cmd == 'OK') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !isAnswerSubmitted) _submitAnswer();
        });
      } else if (cmd == 'BUZZ') {
        // Phone buzzer fast action
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onTriggerAdaptation();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    currentQuestionIndex = widget.initialQuestionIndex.clamp(0, (widget.questions.length - 1).clamp(0, 99));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    secondsRemaining = widget.questionTimerSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        _timer?.cancel();
        _submitAnswer();
      }
    });
  }

  Future<void> _submitAnswer() async {
    if (isAnswerSubmitted || widget.questions.isEmpty) return;
    setState(() => isAnswerSubmitted = true);
    _timer?.cancel();

    final currentQ = widget.questions[currentQuestionIndex];
    final activePlayer = widget.players.isNotEmpty ? widget.players[activePlayerTurnIndex % widget.players.length] : null;

    final selectedOpt = (selectedOptionIndex < currentQ.options.length)
        ? currentQ.options[selectedOptionIndex]
        : currentQ.options.first;

    final isCorrectLocal = selectedOptionIndex == currentQ.correctIndex || selectedOpt.id == currentQ.correctOptionId;
    final points = currentQ.points;

    // Send real answer submission to Supabase backend
    final responseTime = (widget.questionTimerSeconds - secondsRemaining).clamp(1, widget.questionTimerSeconds).toDouble();
    if (activePlayer != null) {
      _apiService.submitAnswer(
        sessionId: widget.sessionId,
        questionId: currentQ.id,
        selectedOptionId: selectedOpt.id,
        playerId: activePlayer.id,
        responseTimeSeconds: responseTime,
      );
    }

    setState(() {
      lastAnswerCorrect = isCorrectLocal;
      lastExplanation = currentQ.explanation.isNotEmpty ? currentQ.explanation : 'Great attempt!';

      if (activePlayer != null) {
        activePlayer.totalAnswered++;
        if (isCorrectLocal) {
          activePlayer.score += points;
          activePlayer.correctCount++;
          activePlayer.streak++;
        } else {
          activePlayer.streak = 0;
        }
      }
    });

    if (isCorrectLocal) {
      widget.onScoreUpdate(points);
    }

    final totalTargetQuestions = widget.questions.length.clamp(1, widget.questionCountLimit);

    // Move to next question or adaptation after brief explanation display
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;

      if (currentQuestionIndex == 1 && totalTargetQuestions > 2) {
        // Trigger AI Intervention on question 2 completion!
        widget.onTriggerAdaptation();
      } else if (currentQuestionIndex < totalTargetQuestions - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedOptionIndex = 0;
          isAnswerSubmitted = false;
          lastAnswerCorrect = null;
          lastExplanation = null;
          activePlayerTurnIndex = (activePlayerTurnIndex + 1) % widget.players.length;
        });
        _startTimer();
      } else {
        widget.onGameFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    final currentQ = widget.questions[currentQuestionIndex];
    final activePlayer = widget.players.isNotEmpty ? widget.players[activePlayerTurnIndex % widget.players.length] : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Column(
        children: [
          // HUD Top Row (Question count, Countdown Timer, Active Player)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Round info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      'ROUND 1 • QUESTION ${(currentQuestionIndex + 1).toString().padLeft(2, '0')} OF ${(widget.questions.length.clamp(1, widget.questionCountLimit)).toString().padLeft(2, '0')}',
                      style: AppStyles.labelMd(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),

              // Countdown Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: secondsRemaining <= 5 ? AppColors.rubyError.withValues(alpha: 0.25) : AppColors.surfaceHigh.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: secondsRemaining <= 5 ? AppColors.rubyError : AppColors.secondary.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: secondsRemaining <= 5 ? AppColors.rubyError : AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${secondsRemaining}s',
                      style: AppStyles.headlineLg(color: secondsRemaining <= 5 ? AppColors.rubyError : Colors.white),
                    ),
                  ],
                ),
              ),

              // Active Turn Player Pill
              if (activePlayer != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: activePlayer.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: activePlayer.accentColor.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 6, backgroundColor: activePlayer.accentColor),
                      const SizedBox(width: 8),
                      Text('TURN: ${activePlayer.name.toUpperCase()}', style: AppStyles.labelMd(color: activePlayer.accentColor)),
                      const SizedBox(width: 6),
                      Text('(${activePlayer.roleTag})', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${currentQ.categoryEmoji} ${currentQ.category}', style: AppStyles.labelLg(color: AppColors.secondary)),
                const SizedBox(width: 12),
                const Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                const SizedBox(width: 12),
                Text('${currentQ.points} PTS', style: AppStyles.labelLg(color: AppColors.tertiary)),
                const SizedBox(width: 12),
                const Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                const SizedBox(width: 12),
                Text(currentQ.difficulty, style: AppStyles.labelMd(color: AppColors.primary)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Question Text
          Text(
            currentQ.questionText,
            style: AppStyles.headlineXl(),
            textAlign: TextAlign.center,
          ),
          if (currentQ.quoteHighlight.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              currentQ.quoteHighlight,
              style: AppStyles.displayHero(color: AppColors.primary).copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 20),

          // Dynamic Answer Feedback / Explanation Pill
          if (isAnswerSubmitted && lastExplanation != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: (lastAnswerCorrect ?? false)
                    ? AppColors.emeraldReady.withValues(alpha: 0.2)
                    : AppColors.rubyError.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (lastAnswerCorrect ?? false) ? AppColors.emeraldReady : AppColors.rubyError,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (lastAnswerCorrect ?? false) ? Icons.check_circle : Icons.cancel,
                    color: (lastAnswerCorrect ?? false) ? AppColors.emeraldReady : AppColors.rubyError,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      '${(lastAnswerCorrect ?? false) ? "CORRECT! +${currentQ.points} PTS" : "INCORRECT"} • $lastExplanation',
                      style: AppStyles.labelLg(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 8),

          const SizedBox(height: 16),

          // 2x2 D-PAD ANSWER GRID
          if (currentQ.options.length >= 4) ...[
            Row(
              children: [
                Expanded(
                  child: _buildAnswerCard(0, currentQ.options[0].text, 'D-PAD LEFT', Icons.arrow_back, isFocused: selectedOptionIndex == 0),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildAnswerCard(1, currentQ.options[1].text, 'D-PAD UP', Icons.arrow_upward, isFocused: selectedOptionIndex == 1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnswerCard(2, currentQ.options[2].text, 'D-PAD DOWN', Icons.arrow_downward, isFocused: selectedOptionIndex == 2),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildAnswerCard(3, currentQ.options[3].text, 'D-PAD RIGHT', Icons.arrow_forward, isFocused: selectedOptionIndex == 3),
                ),
              ],
            ),
          ] else ...[
            // Fallback for options list with other length
            Column(
              children: currentQ.options.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAnswerCard(e.key, e.value.text, 'OPTION ${e.value.id}', Icons.radio_button_checked, isFocused: selectedOptionIndex == e.key),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),

          // LIVE PLAYER SCORES STRIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    const Icon(Icons.leaderboard, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('LIVE SCORES', style: AppStyles.labelMd(color: AppColors.outline)),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.players.map((p) {
                      final isCurrentTurn = activePlayer?.id == p.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 5, backgroundColor: p.accentColor),
                            const SizedBox(width: 6),
                            Text('${p.name}: ', style: AppStyles.bodyMd(color: isCurrentTurn ? AppColors.secondary : Colors.white)),
                            Text('${p.score}', style: AppStyles.labelLg(color: isCurrentTurn ? AppColors.primary : AppColors.onSurface)),
                            if (p.streak > 1) ...[
                              const SizedBox(width: 4),
                              Text('(${p.streak}🔥)', style: const TextStyle(fontSize: 11, color: AppColors.amberWarning)),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.wifi, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                    Text('${widget.players.length} Remotes Synced', style: AppStyles.bodyMd()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(int index, String optionText, String dpadLabel, IconData icon, {bool isFocused = false}) {
    final currentQ = widget.questions[currentQuestionIndex];
    final isOptionCorrect = index == currentQ.correctIndex;

    Color borderColor;
    Color bgColor;

    if (isAnswerSubmitted) {
      if (isOptionCorrect) {
        borderColor = AppColors.emeraldReady;
        bgColor = AppColors.emeraldReady.withValues(alpha: 0.2);
      } else if (isFocused) {
        borderColor = AppColors.rubyError;
        bgColor = AppColors.rubyError.withValues(alpha: 0.2);
      } else {
        borderColor = AppColors.outlineVariant.withValues(alpha: 0.2);
        bgColor = AppColors.surface.withValues(alpha: 0.5);
      }
    } else {
      borderColor = isFocused ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.4);
      bgColor = isFocused ? AppColors.surfaceHigh : AppColors.surface.withValues(alpha: 0.7);
    }

    return GestureDetector(
      onTap: () {
        if (!isAnswerSubmitted) {
          setState(() => selectedOptionIndex = index);
          _submitAnswer();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isFocused ? 3 : 1,
          ),
          boxShadow: isFocused
              ? [
                  BoxShadow(color: AppColors.secondary.withValues(alpha: 0.4), blurRadius: 25),
                  BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.3), blurRadius: 35),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFocused ? AppColors.secondaryContainer : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: isFocused ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          optionText,
                          style: AppStyles.headlineMd(color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isFocused && !isAnswerSubmitted)
                          Row(
                            children: [
                              const Icon(Icons.radio_button_checked, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text('SELECTED - Press [OK]', style: AppStyles.labelMd(color: AppColors.secondary)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(dpadLabel, style: AppStyles.labelMd(color: AppColors.outline)),
          ],
        ),
      ),
    );
  }
}
