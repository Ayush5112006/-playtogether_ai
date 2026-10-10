import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_orb.dart';

class AiSynthesisScreen extends StatefulWidget {
  final VoidCallback onStartGame;
  final String? lastRemoteCommand;

  const AiSynthesisScreen({
    super.key,
    required this.onStartGame,
    this.lastRemoteCommand,
  });

  @override
  State<AiSynthesisScreen> createState() => _AiSynthesisScreenState();
}

class _AiSynthesisScreenState extends State<AiSynthesisScreen> with TickerProviderStateMixin {
  int completedSteps = 4; // 80% Complete

  @override
  void didUpdateWidget(AiSynthesisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRemoteCommand != null && widget.lastRemoteCommand != oldWidget.lastRemoteCommand) {
      final rawCmd = widget.lastRemoteCommand!;
      final cmd = rawCmd.contains('-') ? rawCmd.split('-').first : rawCmd;
      if (cmd == 'OK') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onStartGame();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          // Left 7 Cols: AI Orb Showcase
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AiOrbWidget(size: 260, label: 'CORTEX-9'),
                const SizedBox(height: 24),
                Text('Building your custom game...', style: AppStyles.headlineLg()),
                const SizedBox(height: 8),
                Text(
                  'CORTEX-9 is analyzing player streaks, balancing difficulty, and composing live rounds.',
                  style: AppStyles.bodyLg(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Game Preview Summary Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.quiz, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 6),
                      Text('10 Questions', style: AppStyles.labelMd()),
                      const SizedBox(width: 12),
                      Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                      const SizedBox(width: 12),
                      const Icon(Icons.timer, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 6),
                      Text('10 Minutes', style: AppStyles.labelMd()),
                      const SizedBox(width: 12),
                      Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                      const SizedBox(width: 12),
                      const Icon(Icons.group, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 6),
                      Text('4 Players', style: AppStyles.labelMd()),
                      const SizedBox(width: 12),
                      Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                      const SizedBox(width: 12),
                      Text('Adaptive Difficulty Active', style: AppStyles.labelMd(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Right 5 Cols: Progress Timeline & CTA
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SYNTHESIS TIMELINE', style: AppStyles.labelLg()),
                          Text('80% COMPLETE', style: AppStyles.labelMd(color: AppColors.secondary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTimelineRow('Understanding your players', 'Mom, Dad, Maya, Aarav', 'PROFILED', true, AppColors.secondary),
                      _buildTimelineRow('Selecting topics', 'Sci-Fi, 90s Blockbusters, Animal Kingdom', '3 GENRES', true, AppColors.primary),
                      _buildTimelineRow('Creating tailored questions & dynamic hints', '', '10 READY', true, AppColors.secondary),
                      _buildTimelineRow('Balancing adaptive handicaps', 'Maya (Expert) & Dad (Casual bonus)', 'TUNED', true, AppColors.tertiary),
                      _buildTimelineRow('Preparing surprise round', 'Wildcard Buzzer Blitz', 'GENERATING', false, AppColors.secondary, isGenerating: true),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Host Insight Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, color: AppColors.secondary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CORTEX-9 HOST INSIGHT', style: AppStyles.labelMd(color: AppColors.secondary)),
                            const SizedBox(height: 4),
                            Text(
                              '"Maya is on a 4-game movie winning streak and Aarav loves science! I added Cinema Clues & space trivia."',
                              style: AppStyles.bodyMd(color: AppColors.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CTA Button
                ElevatedButton(
                  onPressed: widget.onStartGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: AppColors.secondaryContainer,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 12,
                    shadowColor: AppColors.secondary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text('START GAME [OK]', style: AppStyles.headlineMd(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(String title, String subtitle, String tag, bool isDone, Color color, {bool isGenerating = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isGenerating ? AppColors.surfaceBright.withOpacity(0.7) : AppColors.surfaceHigh.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isGenerating ? AppColors.secondary : AppColors.outlineVariant.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.sync,
              color: isDone ? AppColors.secondary : AppColors.amberWarning,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.labelMd()),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: AppStyles.bodyMd()),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(tag, style: AppStyles.labelMd(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
