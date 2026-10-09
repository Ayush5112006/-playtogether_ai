import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_orb.dart';

class AiAdaptationScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const AiAdaptationScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Center Orb & Title
          const AiOrbWidget(size: 140, label: 'CORTEX-9'),
          const SizedBox(height: 12),
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
          Text(
            'CORTEX-9 noticed Maya is on a 4-question streak and Aarav is closing in. Rebalancing room difficulty and launching a SURPRISE WILDCARD!',
            style: AppStyles.bodyLg(color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // TWO SHOWCASE TV CARDS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card 1: Difficulty Shift
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.tune, color: AppColors.secondary, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('BALANCE ENGINE', style: AppStyles.labelMd(color: AppColors.secondary)),
                                Text('DYNAMIC DIFFICULTY SHIFT', style: AppStyles.headlineMd(color: Colors.white), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PREVIOUS', style: AppStyles.labelMd(color: AppColors.outline)),
                                  Text('Medium', style: AppStyles.headlineMd(color: AppColors.outline)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('NEW FORMULA', style: AppStyles.labelMd(color: AppColors.primary)),
                                  Text('Medium+', style: AppStyles.headlineMd(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('+50 PTS bonus for <5s quick answer bonus.', style: AppStyles.bodyMd()),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Card 2: Surprise Round Buzzer Blitz
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.tertiary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tertiaryContainer.withValues(alpha: 0.4),
                        blurRadius: 35,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.electric_bolt, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CORTEX-9 SPECIAL EVENT', style: AppStyles.labelMd(color: AppColors.tertiary)),
                                Text('SURPRISE ROUND: BUZZER BLITZ!', style: AppStyles.headlineMd(color: Colors.white), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active, color: AppColors.tertiary, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'First player to buzz in gets exclusive rights to answer! Double Points!',
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
                          Text('STAKES: DOUBLE POINTS', style: AppStyles.labelMd(color: AppColors.secondary)),
                          Text('BOUNTY: +300 PTS / Q', style: AppStyles.labelMd(color: AppColors.tertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // CTA BUTTON
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              backgroundColor: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 16,
              shadowColor: AppColors.secondary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('CONTINUE TO SURPRISE ROUND [OK]', style: AppStyles.headlineMd(color: Colors.white)),
                const SizedBox(width: 12),
                const Icon(Icons.play_arrow, color: Colors.white, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
