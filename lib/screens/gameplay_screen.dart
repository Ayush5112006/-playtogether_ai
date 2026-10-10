import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';
import '../models/player.dart';

class GameplayScreen extends StatefulWidget {
  final List<Question> questions;
  final List<Player> players;
  final VoidCallback onTriggerAdaptation;
  final VoidCallback onGameFinished;
  final ValueChanged<int> onScoreUpdate;
  final String? lastRemoteCommand;

  const GameplayScreen({
    super.key,
    required this.questions,
    required this.players,
    required this.onTriggerAdaptation,
    required this.onGameFinished,
    required this.onScoreUpdate,
    this.lastRemoteCommand,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  int currentQuestionIndex = 0;
  int selectedOptionIndex = 1; // Default D-Pad Up (Han Solo)
  int secondsRemaining = 12;
  Timer? _timer;
  bool isAnswerSubmitted = false;

  @override
  void didUpdateWidget(GameplayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final cmd = widget.lastRemoteCommand!;
      if (cmd == 'LEFT') {
        setState(() => selectedOptionIndex = 0);
      } else if (cmd == 'UP') {
        setState(() => selectedOptionIndex = 1);
      } else if (cmd == 'DOWN') {
        setState(() => selectedOptionIndex = 2);
      } else if (cmd == 'RIGHT') {
        setState(() => selectedOptionIndex = 3);
      } else if (cmd == 'OK') {
        _submitAnswer();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    secondsRemaining = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        _timer?.cancel();
        _submitAnswer();
      }
    });
  }

  void _submitAnswer() {
    if (isAnswerSubmitted) return;
    setState(() => isAnswerSubmitted = true);

    final currentQ = widget.questions[currentQuestionIndex];
    if (selectedOptionIndex == currentQ.correctIndex) {
      widget.onScoreUpdate(currentQ.points);
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (currentQuestionIndex == 0) {
        // Trigger AI Intervention on question 1 completion!
        widget.onTriggerAdaptation();
      } else if (currentQuestionIndex < widget.questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedOptionIndex = 1;
          isAnswerSubmitted = false;
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
    final currentQ = widget.questions[currentQuestionIndex];

    return Padding(
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
                  color: AppColors.surfaceHigh.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      'ROUND 1 • QUESTION 0${currentQuestionIndex + 1} OF 10',
                      style: AppStyles.labelMd(),
                    ),
                  ],
                ),
              ),

              // Glowing Electric Countdown Timer
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.secondary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.4),
                      blurRadius: 25,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: AppColors.secondary, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      '${secondsRemaining}s REMAINING',
                      style: AppStyles.headlineMd(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),

              // Active Turn Player Anchor (Maya)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Maya\'s Turn', style: AppStyles.labelMd(color: AppColors.primary)),
                        Text('Team Violet', style: AppStyles.bodyMd()),
                      ],
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20,
                      child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${currentQ.categoryEmoji} ${currentQ.category}', style: AppStyles.labelLg(color: AppColors.secondary)),
                const SizedBox(width: 12),
                Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                const SizedBox(width: 12),
                Text('${currentQ.points} PTS', style: AppStyles.labelLg(color: AppColors.tertiary)),
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

          const Spacer(),

          // 2x2 D-PAD ANSWER GRID
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

          const Spacer(),

          // LIVE PLAYER SCORES STRIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
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
                Row(
                  children: widget.players.map((p) {
                    final isMaya = p.name == 'Maya';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 5, backgroundColor: p.accentColor),
                          const SizedBox(width: 6),
                          Text('${p.name}: ', style: AppStyles.bodyMd()),
                          Text('${p.score}', style: AppStyles.labelLg(color: isMaya ? AppColors.primary : AppColors.onSurface)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                Row(
                  children: [
                    const Icon(Icons.wifi, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                    Text('4 Phones Synced', style: AppStyles.bodyMd()),
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
    return GestureDetector(
      onTap: () {
        setState(() => selectedOptionIndex = index);
        _submitAnswer();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isFocused ? AppColors.surfaceHigh : AppColors.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused ? AppColors.secondary : AppColors.outlineVariant.withOpacity(0.4),
            width: isFocused ? 3 : 1,
          ),
          boxShadow: isFocused
              ? [
                  BoxShadow(color: AppColors.secondary.withOpacity(0.4), blurRadius: 30),
                  BoxShadow(color: AppColors.primaryContainer.withOpacity(0.3), blurRadius: 40),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(optionText, style: AppStyles.headlineMd(color: Colors.white)),
                    if (isFocused)
                      Row(
                        children: [
                          const Icon(Icons.radio_button_checked, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text('SELECTED - Press [OK]', style: AppStyles.labelMd(color: AppColors.secondary)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            Text(dpadLabel, style: AppStyles.labelMd(color: AppColors.outline)),
          ],
        ),
      ),
    );
  }
}
