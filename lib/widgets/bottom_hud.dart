import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SharedBottomHud extends StatelessWidget {
  final VoidCallback? onDpadNavigate;
  final VoidCallback? onOkPress;
  final VoidCallback? onMicPress;
  final VoidCallback? onBackPress;

  const SharedBottomHud({
    super.key,
    this.onDpadNavigate,
    this.onOkPress,
    this.onMicPress,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.92),
        border: const Border(
          top: BorderSide(color: Color(0x4D494454), width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 25,
            offset: Offset(0, -10),
          )
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remote D-Pad Navigation Glyphs
            Row(
              children: [
                _buildHintPill('▲▼◀▶', 'Navigate', AppColors.secondary),
                const SizedBox(width: 8),
                _buildHintPill('[OK]', 'Select', AppColors.secondary),
                const SizedBox(width: 8),
                _buildHintPill('[MIC]', 'Voice Input', AppColors.primary),
                const SizedBox(width: 8),
                _buildHintPill('[BACK]', 'Return', AppColors.tertiary),
              ],
            ),

            const SizedBox(width: 24),

            // Secondary Quick Links
            Row(
              children: [
                Text(
                  'Leave Room',
                  style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(width: 10),
                Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                const SizedBox(width: 10),
                Text(
                  'Audio Settings',
                  style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(width: 10),
                Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Host Code: ',
                        style: AppStyles.labelMd(color: AppColors.secondary),
                      ),
                      Text(
                        '8942',
                        style: AppStyles.labelLg(color: AppColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintPill(String keyGlyph, String label, Color glyphColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Text(
            keyGlyph,
            style: AppStyles.labelMd(color: glyphColor),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
