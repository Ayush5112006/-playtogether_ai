import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SharedTopBar extends StatelessWidget {
  final int currentStep;
  final String title;
  final VoidCallback? onMicTap;
  final VoidCallback? onSettingsTap;
  final ValueChanged<int>? onStepTap;

  const SharedTopBar({
    super.key,
    required this.currentStep,
    this.title = 'PlayTogether AI',
    this.onMicTap,
    this.onSettingsTap,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: Color(0x4D494454), width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Brand Logo & Step Indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryContainer, AppColors.secondaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: AppColors.surfaceLowest,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'PlayTogether AI',
                  style: AppStyles.headlineMd(color: AppColors.primary),
                ),
                if (currentStep > 0 && currentStep <= 4) ...[
                  const SizedBox(width: 14),
                  Container(width: 1, height: 20, color: AppColors.outlineVariant),
                  const SizedBox(width: 14),
                  _buildStepBreadcrumb(),
                ],
              ],
            ),

            const SizedBox(width: 24),

            // Center Status / Room Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    blurRadius: 15,
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CORTEX-9 Active',
                    style: AppStyles.labelMd(color: AppColors.secondary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '•',
                    style: TextStyle(color: AppColors.outlineVariant),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Host Code: ',
                    style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                  Text(
                    '#8942',
                    style: AppStyles.labelMd(color: AppColors.secondary),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right Actions & Mic Status
            Row(
              children: [
                InkWell(
                  onTap: onMicTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Host Listening',
                          style: AppStyles.labelMd(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.secondary, size: 20),
                  tooltip: 'Game Settings & Parameters',
                  onPressed: onSettingsTap,
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle, color: AppColors.onSurfaceVariant, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBreadcrumb() {
    final steps = ['SETUP', 'GAME', 'SETTINGS', 'PLAY'];
    return Row(
      children: [
        Text(
          'STEP $currentStep OF 4: ',
          style: AppStyles.labelMd(color: AppColors.secondary),
        ),
        const SizedBox(width: 6),
        for (int i = 0; i < steps.length; i++) ...[
          InkWell(
            onTap: onStepTap != null ? () => onStepTap!(i + 1) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                steps[i],
                style: AppStyles.labelMd(
                  color: i + 1 == currentStep
                      ? AppColors.onSurface
                      : (i + 1 < currentStep ? AppColors.secondary : AppColors.outlineVariant),
                ),
              ),
            ),
          ),
          if (i < steps.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '•',
                style: TextStyle(color: AppColors.outlineVariant, fontSize: 12),
              ),
            ),
        ],
      ],
    );
  }
}
