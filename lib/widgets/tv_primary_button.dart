import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class TVPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isFocused;
  final String keyHint;

  const TVPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.play_arrow,
    this.isFocused = true,
    this.keyHint = '[OK]',
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: isFocused ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          backgroundColor: AppColors.primaryContainer,
          elevation: isFocused ? 16 : 6,
          shadowColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isFocused ? AppColors.secondary : Colors.transparent,
              width: isFocused ? 2 : 0,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.headlineMd(color: Colors.white)),
            if (keyHint.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(keyHint, style: AppTextStyles.labelMd(color: AppColors.secondary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
