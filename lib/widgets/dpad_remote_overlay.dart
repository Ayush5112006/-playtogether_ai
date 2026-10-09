import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DpadRemoteOverlay extends StatelessWidget {
  final ValueChanged<String> onCommand;
  final bool isVisible;
  final VoidCallback onToggle;

  const DpadRemoteOverlay({
    super.key,
    required this.onCommand,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return Positioned(
        right: 20,
        bottom: 70,
        child: FloatingActionButton.extended(
          onPressed: onToggle,
          backgroundColor: AppColors.secondaryContainer,
          icon: const Icon(Icons.settings_remote, color: Colors.white),
          label: Text(
            'TV Remote & Phone Controller',
            style: AppStyles.labelMd(color: Colors.white),
          ),
        ),
      );
    }

    return Positioned(
      right: 20,
      bottom: 70,
      child: Material(
        elevation: 20,
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceHighest,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.3),
                blurRadius: 30,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings_remote, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Fire TV Controller',
                        style: AppStyles.labelMd(color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.outline, size: 20),
                    onPressed: onToggle,
                  ),
                ],
              ),
              const Divider(color: AppColors.outlineVariant, height: 16),

              // D-PAD Cross
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // UP
                    Positioned(
                      top: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_drop_up,
                        onTap: () => onCommand('UP'),
                      ),
                    ),
                    // DOWN
                    Positioned(
                      bottom: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_drop_down,
                        onTap: () => onCommand('DOWN'),
                      ),
                    ),
                    // LEFT
                    Positioned(
                      left: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_left,
                        onTap: () => onCommand('LEFT'),
                      ),
                    ),
                    // RIGHT
                    Positioned(
                      right: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_right,
                        onTap: () => onCommand('RIGHT'),
                      ),
                    ),
                    // OK CENTER
                    GestureDetector(
                      onTap: () => onCommand('OK'),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.5),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'OK',
                            style: AppStyles.labelMd(color: AppColors.onSecondaryContainer),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons (MIC, BACK, PHONE BUZZER)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.mic,
                    label: 'Voice',
                    color: AppColors.primary,
                    onTap: () => onCommand('MIC'),
                  ),
                  _buildActionButton(
                    icon: Icons.arrow_back,
                    label: 'Back',
                    color: AppColors.tertiary,
                    onTap: () => onCommand('BACK'),
                  ),
                  _buildActionButton(
                    icon: Icons.bolt,
                    label: 'Buzz',
                    color: AppColors.amberWarning,
                    onTap: () => onCommand('BUZZ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDpadButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 28),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
