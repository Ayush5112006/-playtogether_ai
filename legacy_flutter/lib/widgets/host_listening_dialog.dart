import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';
import 'ai_orb.dart';

class HostListeningDialog extends StatefulWidget {
  final List<Player> players;
  final String currentCategory;
  final String currentDifficulty;
  final ValueChanged<String>? onCategorySelected;
  final ValueChanged<String>? onDifficultyChanged;
  final VoidCallback? onStartGame;
  final VoidCallback? onSurpriseRound;

  const HostListeningDialog({
    super.key,
    required this.players,
    required this.currentCategory,
    required this.currentDifficulty,
    this.onCategorySelected,
    this.onDifficultyChanged,
    this.onStartGame,
    this.onSurpriseRound,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Player> players,
    required String currentCategory,
    required String currentDifficulty,
    ValueChanged<String>? onCategorySelected,
    ValueChanged<String>? onDifficultyChanged,
    VoidCallback? onStartGame,
    VoidCallback? onSurpriseRound,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => HostListeningDialog(
        players: players,
        currentCategory: currentCategory,
        currentDifficulty: currentDifficulty,
        onCategorySelected: onCategorySelected,
        onDifficultyChanged: onDifficultyChanged,
        onStartGame: onStartGame,
        onSurpriseRound: onSurpriseRound,
      ),
    );
  }

  @override
  State<HostListeningDialog> createState() => _HostListeningDialogState();
}

class _HostListeningDialogState extends State<HostListeningDialog> with SingleTickerProviderStateMixin {
  late TextEditingController _speechInputController;
  late AnimationController _waveformController;
  String _hostResponse = "I'm listening! Speak or tap a command below to control the room.";
  bool _isProcessing = false;

  final List<String> _quickCommands = [
    '▶ Launch Quiz Now',
    '🎬 Play Cinema Clues',
    '🚀 Play Science & Cosmos',
    '⚡ Surprise Buzzer Blitz',
    '📈 Shift to Hard Mode',
    '📉 Shift to Easy Mode',
    '🏆 Who is winning?',
  ];

  @override
  void initState() {
    super.initState();
    _speechInputController = TextEditingController();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _speechInputController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  void _processVoiceCommand(String rawCommand) {
    final cmd = rawCommand.toLowerCase();
    setState(() {
      _isProcessing = true;
      _speechInputController.text = rawCommand;
    });

    String response = "";
    VoidCallback? action;

    if (cmd.contains('launch') || cmd.contains('start') || cmd.contains('play quiz')) {
      response = "Launching party quiz now! Synchronizing all living room players...";
      action = () {
        if (widget.onStartGame != null) widget.onStartGame!();
      };
    } else if (cmd.contains('cinema') || cmd.contains('movie')) {
      response = "Category switched to Cinema Clues from the Supabase question bank!";
      action = () {
        if (widget.onCategorySelected != null) widget.onCategorySelected!('Cinema Clues');
      };
    } else if (cmd.contains('science') || cmd.contains('cosmos') || cmd.contains('space')) {
      response = "Category switched to Science & Cosmos! Preparing astronomy trivia.";
      action = () {
        if (widget.onCategorySelected != null) widget.onCategorySelected!('Science & Cosmos');
      };
    } else if (cmd.contains('surprise') || cmd.contains('blitz') || cmd.contains('buzzer')) {
      response = "Triggering Surprise Round: Buzzer Blitz! Double points activated.";
      action = () {
        if (widget.onSurpriseRound != null) widget.onSurpriseRound!();
      };
    } else if (cmd.contains('hard') || cmd.contains('harder') || cmd.contains('increase')) {
      response = "Elevating room difficulty to HARD! Maximum points on the line.";
      action = () {
        if (widget.onDifficultyChanged != null) widget.onDifficultyChanged!('HARD');
      };
    } else if (cmd.contains('easy') || cmd.contains('easier') || cmd.contains('decrease')) {
      response = "Relaxing room difficulty to EASY. Family friendly mode engaged.";
      action = () {
        if (widget.onDifficultyChanged != null) widget.onDifficultyChanged!('EASY');
      };
    } else if (cmd.contains('winning') || cmd.contains('leader') || cmd.contains('score')) {
      if (widget.players.isNotEmpty) {
        final leader = (List<Player>.from(widget.players)..sort((a, b) => b.score.compareTo(a.score))).first;
        response = "${leader.name} is leading the room with ${leader.score} points and a ${leader.streak}x streak!";
      } else {
        response = "Scores are currently even across all players.";
      }
    } else {
      response = "Command acknowledged: \"$rawCommand\". Applying adaptive room synthesis.";
    }

    setState(() {
      _hostResponse = response;
      _isProcessing = false;
    });

    if (action != null) {
      Timer(const Duration(milliseconds: 1400), () {
        if (mounted) {
          Navigator.of(context).pop();
          action!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 760,
        constraints: const BoxConstraints(maxHeight: 660),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 4,
            ),
            const BoxShadow(
              color: Colors.black87,
              blurRadius: 50,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header with Active Listening Wave Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: const Border(
                  bottom: BorderSide(color: Color(0x33D0BCFF), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '● LIVE VOICE MIC ACTIVE',
                              style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('CORTEX-9 Host Voice Recognition', style: AppStyles.headlineMd()),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                    tooltip: 'Close Voice Assistant',
                  ),
                ],
              ),
            ),

            // 2. Main Animated Center Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                children: [
                  // Orb & Dynamic Waveform
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AiOrbWidget(size: 110, label: 'CORTEX-9'),
                      const SizedBox(width: 24),
                      // Animated Voice Bars
                      AnimatedBuilder(
                        animation: _waveformController,
                        builder: (context, child) {
                          return Row(
                            children: List.generate(14, (idx) {
                              final wave = math.sin((_waveformController.value * math.pi * 2) + (idx * 0.45)).abs();
                              final barHeight = 16.0 + (wave * 42.0);
                              return Container(
                                width: 5,
                                height: barHeight,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: idx.isEven ? AppColors.primary : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (idx.isEven ? AppColors.primary : AppColors.secondary).withValues(alpha: 0.6),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Synthesized AI Host Speech Bubble
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.record_voice_over, color: AppColors.primary, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _hostResponse,
                            style: AppStyles.bodyLg(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Real-time Text Input / Voice Transcribe Field
                  TextField(
                    controller: _speechInputController,
                    onSubmitted: _processVoiceCommand,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceLowest,
                      hintText: "Type voice command or click a prompt below (Press Enter)...",
                      hintStyle: TextStyle(color: AppColors.outlineVariant),
                      prefixIcon: const Icon(Icons.mic, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: () => _processVoiceCommand(_speechInputController.text),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Voice Action Chips Rail
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('FREQUENT LIVING ROOM VOICE COMMANDS:', style: AppStyles.labelMd(color: AppColors.secondary)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickCommands.map((commandText) {
                      return ActionChip(
                        backgroundColor: AppColors.surfaceHigh,
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        label: Text(
                          commandText,
                          style: AppStyles.labelMd(color: Colors.white),
                        ),
                        onPressed: () => _processVoiceCommand(commandText),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // 3. Bottom Close Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Microphone Input: Active via Web / Fire TV Remote [MIC]',
                    style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceHigh,
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    child: const Text('Dismiss [BACK]', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
