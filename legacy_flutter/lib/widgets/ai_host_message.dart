import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AIHostMessageWidget extends StatelessWidget {
  final String title;
  final String message;
  final Color accentColor;

  const AIHostMessageWidget({
    super.key,
    this.title = 'CORTEX-9 AI HOST',
    required this.message,
    this.accentColor = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 20,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.psychology, color: accentColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.labelMd(color: accentColor)),
                const SizedBox(height: 4),
                Text(message, style: AppTextStyles.bodyMd(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
