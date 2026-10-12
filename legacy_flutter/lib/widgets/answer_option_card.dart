import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/question.dart';

class AnswerOptionCard extends StatelessWidget {
  final Option option;
  final String dpadLabel;
  final IconData icon;
  final bool isFocused;
  final bool isSubmitted;
  final bool isCorrect;
  final VoidCallback onTap;

  const AnswerOptionCard({
    super.key,
    required this.option,
    required this.dpadLabel,
    required this.icon,
    required this.isFocused,
    required this.isSubmitted,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBorder = isFocused ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.4);
    Color optionBg = isFocused ? AppColors.surfaceHigh : AppColors.surfaceContainer;

    if (isSubmitted && isFocused) {
      cardBorder = isCorrect ? AppColors.successGreen : AppColors.errorRed;
      optionBg = isCorrect ? AppColors.successGreen.withValues(alpha: 0.2) : AppColors.errorRed.withValues(alpha: 0.2);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: optionBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder, width: isFocused ? 3 : 1),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: cardBorder.withValues(alpha: 0.4),
                    blurRadius: 30,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isFocused ? AppColors.secondaryContainer : AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    option.id,
                    style: AppTextStyles.labelLg(
                      color: isFocused ? AppColors.onSecondaryContainer : AppColors.onSurfaceMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.text, style: AppTextStyles.headlineMd(color: Colors.white)),
                    if (isFocused)
                      Row(
                        children: [
                          Icon(
                            isSubmitted
                                ? (isCorrect ? Icons.check_circle : Icons.cancel)
                                : Icons.radio_button_checked,
                            size: 14,
                            color: isSubmitted ? (isCorrect ? AppColors.successGreen : AppColors.errorRed) : AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSubmitted
                                ? (isCorrect ? 'CORRECT! +POINTS' : 'INCORRECT')
                                : 'SELECTED — Press [OK]',
                            style: AppTextStyles.labelMd(
                              color: isSubmitted ? (isCorrect ? AppColors.successGreen : AppColors.errorRed) : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            Text(dpadLabel, style: AppTextStyles.labelMd(color: AppColors.outline)),
          ],
        ),
      ),
    );
  }
}
