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

  // --- Feature 1: 50/50 Lifeline & AI Host Hint State ---
  Set<int> eliminatedOptionIndices = {};
  bool isHintVisible = false;
  String? currentHintText;
  int lifelinesRemaining = 2;
  int hintsRemaining = 2;

  // --- Feature 2: Streak Multiplier State ---
  double lastPointsMultiplier = 1.0;
  int lastBonusEarned = 0;

  final ApiService _apiService = ApiService();

  @override
  void didUpdateWidget(GameplayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.questions != oldWidget.questions || widget.initialQuestionIndex != oldWidget.initialQuestionIndex) {
      setState(() {
        currentQuestionIndex = widget.initialQuestionIndex.clamp(0, (widget.questions.length - 1).clamp(0, 99));
        selectedOptionIndex = 0;
        isAnswerSubmitted = false;
        lastAnswerCorrect = null;
        lastExplanation = null;
        eliminatedOptionIndices = {};
        isHintVisible = false;
        currentHintText = null;
      });
      _startTimer();
    }
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;

      if (cmd == 'LEFT') {
        _selectNonEliminatedOption(0);
      } else if (cmd == 'UP') {
        _selectNonEliminatedOption(1);
      } else if (cmd == 'DOWN') {
        _selectNonEliminatedOption(2);
      } else if (cmd == 'RIGHT') {
        _selectNonEliminatedOption(3);
      } else if (cmd == 'OK') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !isAnswerSubmitted) _submitAnswer();
        });
      } else if (cmd == 'BUZZ') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onTriggerAdaptation();
        });
      } else if (cmd == 'LIFELINE') {
        _useFiftyFifty();
      } else if (cmd == 'HINT') {
        _useAiHint();
      }
    }
  }

  void _selectNonEliminatedOption(int targetIndex) {
    if (!eliminatedOptionIndices.contains(targetIndex)) {
      setState(() => selectedOptionIndex = targetIndex);
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

  // --- Feature 1 Logic: 50/50 Lifeline ---
  void _useFiftyFifty() {
    if (lifelinesRemaining <= 0 || isAnswerSubmitted || widget.questions.isEmpty || eliminatedOptionIndices.isNotEmpty) return;
    final currentQ = widget.questions[currentQuestionIndex];
    final wrongIndices = <int>[];
    for (int i = 0; i < currentQ.options.length; i++) {
      if (i != currentQ.correctIndex && currentQ.options[i].id != currentQ.correctOptionId) {
        wrongIndices.add(i);
      }
    }
    wrongIndices.shuffle();
    setState(() {
      eliminatedOptionIndices = wrongIndices.take(2).toSet();
      lifelinesRemaining--;
      if (eliminatedOptionIndices.contains(selectedOptionIndex)) {
        for (int i = 0; i < currentQ.options.length; i++) {
          if (!eliminatedOptionIndices.contains(i)) {
            selectedOptionIndex = i;
            break;
          }
        }
      }
    });
  }

  // --- Feature 1 Logic: AI Host Hint ---
  void _useAiHint() {
    if (hintsRemaining <= 0 || isAnswerSubmitted || widget.questions.isEmpty || isHintVisible) return;
    final currentQ = widget.questions[currentQuestionIndex];
    String hint;
    if (currentQ.quoteHighlight.isNotEmpty) {
      hint = 'Focus closely on the key phrase: ${currentQ.quoteHighlight}';
    } else if (currentQ.explanation.isNotEmpty) {
      final words = currentQ.explanation.split(' ');
      hint = words.length > 8 ? '${words.take(8).join(' ')}...' : currentQ.explanation;
    } else {
      hint = 'Category tip: Think back to the golden milestones of ${currentQ.category}!';
    }
    setState(() {
      currentHintText = hint;
      isHintVisible = true;
      hintsRemaining--;
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

    bool isCorrectLocal = selectedOptionIndex == currentQ.correctIndex || selectedOpt.id == currentQ.correctOptionId;
    int basePoints = currentQ.points;
    String explanation = currentQ.explanation.isNotEmpty ? currentQ.explanation : 'Great attempt!';

    // --- Feature 2 Logic: Streak Multipliers ---
    double streakMultiplier = 1.0;
    int currentStreak = activePlayer?.streak ?? 0;
    if (isCorrectLocal) {
      if (currentStreak >= 2) {
        streakMultiplier = 2.0; // ⚡ 2.0x Mega Streak Multiplier!
      } else if (currentStreak == 1) {
        streakMultiplier = 1.5; // 🔥 1.5x Streak Multiplier!
      }
    }
    int totalEarnedPoints = isCorrectLocal ? (basePoints * streakMultiplier).round() : 0;
    int bonusEarned = totalEarnedPoints - (isCorrectLocal ? basePoints : 0);

    // Send real answer submission to Supabase backend
    final responseTime = (widget.questionTimerSeconds - secondsRemaining).clamp(1, widget.questionTimerSeconds).toDouble();
    if (activePlayer != null) {
      try {
        final res = await _apiService.submitAnswer(
          sessionId: widget.sessionId,
          questionId: currentQ.id,
          selectedOptionId: selectedOpt.id,
          playerId: activePlayer.id,
          responseTimeSeconds: responseTime,
        );
        if (res['isCorrect'] != null) isCorrectLocal = res['isCorrect'] as bool;
        if (res['explanation'] != null) explanation = res['explanation'] as String;
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      lastAnswerCorrect = isCorrectLocal;
      lastExplanation = explanation;
      lastPointsMultiplier = streakMultiplier;
      lastBonusEarned = bonusEarned;

      if (activePlayer != null) {
        activePlayer.totalAnswered++;
        if (isCorrectLocal) {
          activePlayer.score += totalEarnedPoints;
          activePlayer.correctCount++;
          activePlayer.streak++;
        } else {
          activePlayer.streak = 0;
        }
      }
    });

    if (isCorrectLocal) {
      widget.onScoreUpdate(totalEarnedPoints);
    }

    final totalTargetQuestions = widget.questions.length.clamp(1, widget.questionCountLimit);

    // Move to next question or adaptation after brief explanation display
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;

      if (currentQuestionIndex == 1 && totalTargetQuestions > 2) {
        // Trigger AI Intervention on question 2 completion
        widget.onTriggerAdaptation();
      } else if (currentQuestionIndex < totalTargetQuestions - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedOptionIndex = 0;
          isAnswerSubmitted = false;
          lastAnswerCorrect = null;
          lastExplanation = null;
          eliminatedOptionIndices = {};
          isHintVisible = false;
          currentHintText = null;
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
          // HUD Top Row (Question count, Countdown Timer, Active Player & Streak Multiplier)
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

              // Active Turn Player Pill + Dynamic Streak Flame Badge
              if (activePlayer != null)
                Row(
                  children: [
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
                    if (activePlayer.streak >= 1) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: activePlayer.streak >= 2
                                ? [const Color(0xFFFF416C), const Color(0xFFFF4B2B)]
                                : [const Color(0xFFF7971E), const Color(0xFFFFD200)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (activePlayer.streak >= 2 ? const Color(0xFFFF416C) : const Color(0xFFFFD200)).withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(activePlayer.streak >= 2 ? '⚡' : '🔥', style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              activePlayer.streak >= 2 ? '2.0x MEGA COMBO' : '1.5x COMBO',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Category Badge & Points Pill
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

          const SizedBox(height: 12),

          // --- Feature 1 UI: Interactive Lifelines & AI Hint Strip ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 50/50 Lifeline Button
              InkWell(
                onTap: lifelinesRemaining > 0 && !isAnswerSubmitted && eliminatedOptionIndices.isEmpty
                    ? _useFiftyFifty
                    : null,
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: lifelinesRemaining > 0 && eliminatedOptionIndices.isEmpty
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: lifelinesRemaining > 0 && eliminatedOptionIndices.isEmpty
                          ? AppColors.secondary.withValues(alpha: 0.8)
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.content_cut,
                        size: 15,
                        color: lifelinesRemaining > 0 && eliminatedOptionIndices.isEmpty
                            ? AppColors.secondary
                            : Colors.white38,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        eliminatedOptionIndices.isNotEmpty
                            ? '50/50 ACTIVE'
                            : '50/50 LIFELINE ($lifelinesRemaining) [L]',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: lifelinesRemaining > 0 && eliminatedOptionIndices.isEmpty
                              ? AppColors.secondary
                              : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // AI Host Hint Button
              InkWell(
                onTap: hintsRemaining > 0 && !isAnswerSubmitted && !isHintVisible
                    ? _useAiHint
                    : null,
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: hintsRemaining > 0 && !isHintVisible
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hintsRemaining > 0 && !isHintVisible
                          ? AppColors.primary.withValues(alpha: 0.8)
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        size: 15,
                        color: hintsRemaining > 0 && !isHintVisible
                            ? AppColors.primary
                            : Colors.white38,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isHintVisible ? 'HINT REVEALED' : 'AI HOST HINT ($hintsRemaining) [H]',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: hintsRemaining > 0 && !isHintVisible
                              ? AppColors.primary
                              : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // AI Host Clue Revealer Bubble
          if (isHintVisible && currentHintText != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryContainer.withValues(alpha: 0.35),
                    AppColors.surfaceHigh.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.8)),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 15),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'AI GAME MASTER CLUE: $currentHintText',
                      style: AppStyles.labelLg(color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

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

          const SizedBox(height: 18),

          // Dynamic Answer Feedback / Explanation Pill (Includes Streak Points Breakdown)
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
                      (lastAnswerCorrect ?? false)
                          ? (lastPointsMultiplier > 1.0
                              ? 'CORRECT! +${currentQ.points} PTS + $lastBonusEarned STREAK BONUS (🔥 ${lastPointsMultiplier}x COMBO!) • $lastExplanation'
                              : 'CORRECT! +${currentQ.points} PTS • $lastExplanation')
                          : 'INCORRECT • $lastExplanation',
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

          // 2x2 D-PAD ANSWER GRID (Respects 50/50 Elimination)
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

          // LIVE PLAYER SCORES STRIP WITH STREAK INDICATORS
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
                      final isCurrentTurn = widget.players.indexOf(p) == (activePlayerTurnIndex % widget.players.length);
                      return Container(
                        margin: const EdgeInsets.only(left: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCurrentTurn ? p.accentColor.withValues(alpha: 0.25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrentTurn ? p.accentColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 5, backgroundColor: p.accentColor),
                            const SizedBox(width: 8),
                            Text(p.name, style: TextStyle(fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal, color: Colors.white)),
                            const SizedBox(width: 8),
                            Text('${p.score} PTS', style: TextStyle(fontWeight: FontWeight.bold, color: p.accentColor)),
                            if (p.streak >= 2) ...[
                              const SizedBox(width: 6),
                              Text(p.streak >= 3 ? '⚡${p.streak}' : '🔥${p.streak}', style: const TextStyle(fontSize: 12)),
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
    final isEliminated = eliminatedOptionIndices.contains(index);

    // If eliminated by 50/50 lifeline, render greyed out / struck through card
    if (isEliminated) {
      return Opacity(
        opacity: 0.3,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.block, color: Colors.redAccent, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    optionText,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 18,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const Text('50/50 ELIMINATED', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

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
