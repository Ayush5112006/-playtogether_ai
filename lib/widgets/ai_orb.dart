import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AiOrbWidget extends StatefulWidget {
  final double size;
  final String label;

  const AiOrbWidget({
    super.key,
    this.size = 220,
    this.label = 'CORTEX-9',
  });

  @override
  State<AiOrbWidget> createState() => _AiOrbWidgetState();
}

class _AiOrbWidgetState extends State<AiOrbWidget> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _pulseController]),
      builder: (context, child) {
        final pulseVal = 1.0 + (_pulseController.value * 0.08);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating dotted ring
              Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: OrbitalRingPainter(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    isDashed: true,
                  ),
                ),
              ),
              // Inner counter-rotating ring
              Transform.rotate(
                angle: -_rotationController.value * 2 * math.pi * 1.5,
                child: CustomPaint(
                  size: Size(widget.size * 0.85, widget.size * 0.85),
                  painter: OrbitalRingPainter(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    isDashed: false,
                  ),
                ),
              ),

              // Glowing Core Orb
              Transform.scale(
                scale: pulseVal,
                child: Container(
                  width: widget.size * 0.55,
                  height: widget.size * 0.55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.onPrimaryContainer,
                        AppColors.secondaryContainer,
                        AppColors.primary,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(alpha: 0.6),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: widget.size * 0.22,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.label,
                            style: AppStyles.labelMd(color: AppColors.secondaryFixed),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrbitalRingPainter extends CustomPainter {
  final Color color;
  final bool isDashed;

  OrbitalRingPainter({required this.color, required this.isDashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (!isDashed) {
      canvas.drawCircle(center, radius, paint);
    } else {
      const double dashWidth = 10;
      const double dashSpace = 8;
      double circumference = 2 * math.pi * radius;
      int count = (circumference / (dashWidth + dashSpace)).floor();
      for (int i = 0; i < count; i++) {
        double startAngle = (i * (dashWidth + dashSpace) / circumference) * 2 * math.pi;
        double sweepAngle = (dashWidth / circumference) * 2 * math.pi;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant OrbitalRingPainter oldDelegate) => false;
}
