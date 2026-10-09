import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/question.dart';
import '../../models/player.dart';

class AnswerResultScreen extends StatelessWidget {
  final bool isCorrect;
  final Question question;
  final Option? selectedOption;
  final int pointsEarned;
  final Player player;
  final VoidCallback onContinue;

  const AnswerResultScreen({
    super.key,
    required this.isCorrect,
    required this.question,
    this.selectedOption,
    required this.pointsEarned,
    required this.player,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final correctOpt = question.options.firstWhere(
      (o) => o.id == question.correctOptionId,
      orElse: () => question.options.first,
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon & Headline
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isCorrect ? AppColors.successGreen : AppColors.errorRed).withValues(alpha: 0.2),
                border: Border.all(color: isCorrect ? AppColors.successGreen : AppColors.errorRed, width: 3),
              ),
              child: Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                size: 72,
                color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isCorrect ? 'THAT\'S CORRECT!' : 'NOT QUITE!',
              style: AppTextStyles.heroTitle(
                color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCorrect ? '+ $pointsEarned POINTS EARNED!' : 'Correct Answer: ${correctOpt.id}. ${correctOpt.text}',
              style: AppTextStyles.headlineLg(color: isCorrect ? AppColors.goldAccent : Colors.white),
            ),

            const SizedBox(height: 24),

            // Explanation Card
            Container(
              maxWidth: 800,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: player.accentColor,
                        radius: 18,
                        child: Icon(player.icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(player.name, style: AppTextStyles.labelLg(color: Colors.white)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${player.streak}x STREAK', style: AppTextStyles.labelMd(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.outlineVariant, height: 24),
                  Text(
                    question.explanation,
                    style: AppTextStyles.bodyLg(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                backgroundColor: AppColors.primaryContainer,
                elevation: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('CONTINUE [OK]', style: AppTextStyles.headlineMd(color: Colors.white)),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
