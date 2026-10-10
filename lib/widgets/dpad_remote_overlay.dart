import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DpadRemoteOverlay extends StatelessWidget {
  final ValueChanged<String> onCommand;
  final bool isVisible;
  final VoidCallback onToggle;
  final String? activeCommand;

  const DpadRemoteOverlay({
    super.key,
    required this.onCommand,
    required this.isVisible,
    required this.onToggle,
    this.activeCommand,
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
                        cmd: 'UP',
                        onTap: () => onCommand('UP'),
                      ),
                    ),
                    // DOWN
                    Positioned(
                      bottom: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_drop_down,
                        cmd: 'DOWN',
                        onTap: () => onCommand('DOWN'),
                      ),
                    ),
                    // LEFT
                    Positioned(
                      left: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_left,
                        cmd: 'LEFT',
                        onTap: () => onCommand('LEFT'),
                      ),
                    ),
                    // RIGHT
                    Positioned(
                      right: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_right,
                        cmd: 'RIGHT',
                        onTap: () => onCommand('RIGHT'),
                      ),
                    ),
                    // OK CENTER
                    GestureDetector(
                      onTap: () => onCommand('OK'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (activeCommand?.startsWith('OK') ?? false)
                              ? AppColors.primary
                              : AppColors.secondaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: (activeCommand?.startsWith('OK') ?? false)
                                  ? AppColors.primary.withValues(alpha: 0.9)
                                  : AppColors.secondary.withValues(alpha: 0.5),
                              blurRadius: (activeCommand?.startsWith('OK') ?? false) ? 20 : 10,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'OK',
                            style: AppStyles.labelMd(
                              color: (activeCommand?.startsWith('OK') ?? false)
                                  ? Colors.white
                                  : AppColors.onSecondaryContainer,
                            ),
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
                    label: 'Voice [M]',
                    cmd: 'MIC',
                    color: AppColors.primary,
                    onTap: () => onCommand('MIC'),
                  ),
                  _buildActionButton(
                    icon: Icons.arrow_back,
                    label: 'Back [Esc]',
                    cmd: 'BACK',
                    color: AppColors.tertiary,
                    onTap: () => onCommand('BACK'),
                  ),
                  _buildActionButton(
                    icon: Icons.bolt,
                    label: 'Buzz [B]',
                    cmd: 'BUZZ',
                    color: AppColors.amberWarning,
                    onTap: () => onCommand('BUZZ'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Keys: Arrows/WASD • Enter=OK • B=Buzz',
                  style: TextStyle(fontSize: 10, color: AppColors.outlineVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDpadButton({required IconData icon, required String cmd, required VoidCallback onTap}) {
    final isActive = activeCommand != null && activeCommand!.startsWith(cmd);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondaryContainer : AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.secondary : AppColors.outlineVariant,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.8),
                    blurRadius: 15,
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppColors.secondary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String cmd,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isActive = activeCommand != null && activeCommand!.startsWith(cmd);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: isActive ? 2 : 1),
              boxShadow: isActive
                  ? [BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 16)]
                  : null,
            ),
            child: Icon(icon, color: isActive ? Colors.white : color, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
