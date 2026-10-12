import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DpadRemoteOverlay extends StatefulWidget {
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
  State<DpadRemoteOverlay> createState() => _DpadRemoteOverlayState();
}

class _DpadRemoteOverlayState extends State<DpadRemoteOverlay> {
  // Freeform draggable position (left, top)
  Offset? _position;

  Offset _getDefaultPosition(Size size) {
    // Default to bottom-right corner, 20px margin
    final double defaultX = (size.width - 280).clamp(20.0, size.width);
    final double defaultY = (size.height - 460).clamp(20.0, size.height);
    return Offset(defaultX, defaultY);
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      final currentPos = _position ?? _getDefaultPosition(size);
      final double newX = (currentPos.dx + details.delta.dx).clamp(10.0, (size.width - 270).clamp(10.0, size.width));
      final double newY = (currentPos.dy + details.delta.dy).clamp(10.0, (size.height - 440).clamp(10.0, size.height));
      _position = Offset(newX, newY);
    });
  }

  void _resetPosition(Size size) {
    setState(() {
      _position = _getDefaultPosition(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final currentPos = _position ?? _getDefaultPosition(screenSize);

    if (!widget.isVisible) {
      final minX = (currentPos.dx).clamp(20.0, (screenSize.width - 250).clamp(20.0, screenSize.width));
      final minY = (currentPos.dy + 350).clamp(20.0, (screenSize.height - 80).clamp(20.0, screenSize.height));

      return Positioned(
        left: minX,
        top: minY,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              final double newX = (minX + details.delta.dx).clamp(10.0, (screenSize.width - 240).clamp(10.0, screenSize.width));
              final double newY = (minY + details.delta.dy).clamp(10.0, (screenSize.height - 70).clamp(10.0, screenSize.height));
              _position = Offset(newX, newY - 350);
            });
          },
          child: FloatingActionButton.extended(
            onPressed: widget.onToggle,
            backgroundColor: AppColors.secondaryContainer,
            elevation: 12,
            icon: const Icon(Icons.settings_remote, color: Colors.white),
            label: Row(
              children: [
                const Icon(Icons.drag_indicator, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  'Open Remote Controller',
                  style: AppStyles.labelMd(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Positioned(
      left: currentPos.dx,
      top: currentPos.dy,
      child: Material(
        elevation: 24,
        borderRadius: BorderRadius.circular(22),
        color: Colors.transparent,
        child: Container(
          width: 260,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.secondary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.4),
                blurRadius: 35,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 25,
                offset: Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // DRAG HANDLE BAR (Move Controller anywhere)
              GestureDetector(
                onPanUpdate: (details) => _onPanUpdate(details, screenSize),
                behavior: HitTestBehavior.opaque,
                child: MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.drag_indicator, color: AppColors.secondary, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'Fire TV Remote',
                                style: AppStyles.labelMd(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Reset corner button
                              Tooltip(
                                message: 'Reset Position',
                                child: InkWell(
                                  onTap: () => _resetPosition(screenSize),
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.refresh, color: AppColors.outline, size: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Close/Minimize
                              Tooltip(
                                message: 'Minimize',
                                child: InkWell(
                                  onTap: widget.onToggle,
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close, color: AppColors.outline, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hold & drag header to move',
                            style: TextStyle(fontSize: 10, color: AppColors.secondary.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(color: AppColors.outlineVariant, height: 16),

              // D-PAD Cross
              SizedBox(
                width: 146,
                height: 146,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // UP
                    Positioned(
                      top: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_drop_up,
                        cmd: 'UP',
                        onTap: () => widget.onCommand('UP'),
                      ),
                    ),
                    // DOWN
                    Positioned(
                      bottom: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_drop_down,
                        cmd: 'DOWN',
                        onTap: () => widget.onCommand('DOWN'),
                      ),
                    ),
                    // LEFT
                    Positioned(
                      left: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_left,
                        cmd: 'LEFT',
                        onTap: () => widget.onCommand('LEFT'),
                      ),
                    ),
                    // RIGHT
                    Positioned(
                      right: 0,
                      child: _buildDpadButton(
                        icon: Icons.arrow_right,
                        cmd: 'RIGHT',
                        onTap: () => widget.onCommand('RIGHT'),
                      ),
                    ),
                    // OK CENTER
                    GestureDetector(
                      onTap: () => widget.onCommand('OK'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (widget.activeCommand?.startsWith('OK') ?? false)
                              ? AppColors.primary
                              : AppColors.secondaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: (widget.activeCommand?.startsWith('OK') ?? false)
                                  ? AppColors.primary.withValues(alpha: 0.9)
                                  : AppColors.secondary.withValues(alpha: 0.5),
                              blurRadius: (widget.activeCommand?.startsWith('OK') ?? false) ? 20 : 10,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'OK',
                            style: AppStyles.labelMd(
                              color: (widget.activeCommand?.startsWith('OK') ?? false)
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

              const SizedBox(height: 14),

              // Action buttons (MIC, BACK, PHONE BUZZER)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.mic,
                    label: 'Voice [M]',
                    cmd: 'MIC',
                    color: AppColors.primary,
                    onTap: () => widget.onCommand('MIC'),
                  ),
                  _buildActionButton(
                    icon: Icons.arrow_back,
                    label: 'Back [Esc]',
                    cmd: 'BACK',
                    color: AppColors.tertiary,
                    onTap: () => widget.onCommand('BACK'),
                  ),
                  _buildActionButton(
                    icon: Icons.bolt,
                    label: 'Buzz [B]',
                    cmd: 'BUZZ',
                    color: AppColors.amberWarning,
                    onTap: () => widget.onCommand('BUZZ'),
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
    final isActive = widget.activeCommand != null && widget.activeCommand!.startsWith(cmd);
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
    final isActive = widget.activeCommand != null && widget.activeCommand!.startsWith(cmd);
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
