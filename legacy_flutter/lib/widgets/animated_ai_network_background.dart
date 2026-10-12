import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated AI Network Background
///
/// A premium, continuously animated background depicting a luminous golden
/// neural network with interconnected particles, morphing central energy cluster,
/// geometric triangular wireframes, and subtle glowing nodes over a dark navy background.
class AnimatedAINetworkBackground extends StatefulWidget {
  final int particleCount;
  final double animationSpeed;
  final double opacity;
  final double glowIntensity;
  final double connectionDistance;
  final Color backgroundColor;
  final bool showCentralCluster;
  final double centralClusterWeight;
  final int maxConnectionsPerParticle;
  final bool reducedMotion;
  final bool drawBackground;
  final Widget? child;

  const AnimatedAINetworkBackground({
    super.key,
    this.particleCount = 30,
    this.animationSpeed = 1.0,
    this.opacity = 1.0,
    this.glowIntensity = 1.0,
    this.connectionDistance = 145.0,
    this.backgroundColor = const Color(0xFF070812),
    this.showCentralCluster = true,
    this.centralClusterWeight = 0.45,
    this.maxConnectionsPerParticle = 4,
    this.reducedMotion = false,
    this.drawBackground = true,
    this.child,
  });

  @override
  State<AnimatedAINetworkBackground> createState() => _AnimatedAINetworkBackgroundState();
}

class _AnimatedAINetworkBackgroundState extends State<AnimatedAINetworkBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_AINetworkParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    );

    _generateParticles();

    if (!widget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedAINetworkBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.particleCount != widget.particleCount ||
        oldWidget.showCentralCluster != widget.showCentralCluster ||
        oldWidget.centralClusterWeight != widget.centralClusterWeight ||
        oldWidget.animationSpeed != widget.animationSpeed) {
      _generateParticles();
    }

    if (oldWidget.reducedMotion != widget.reducedMotion) {
      if (widget.reducedMotion) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
    }
  }

  void _generateParticles() {
    final rand = math.Random(42); // Seeded for stable layout
    final total = widget.particleCount;
    final centralCount = widget.showCentralCluster
        ? (total * widget.centralClusterWeight.clamp(0.0, 1.0)).round()
        : 0;
    final peripheralCount = total - centralCount;

    // Palette tokens: Gold, Champagne, Deep Gold, Amber Accent
    const goldMain = Color(0xFFFFD76A);
    const goldHighlight = Color(0xFFFFE9A8);
    const goldDeep = Color(0xFFD6A63D);
    const amberAccent = Color(0xFFB98530);

    final colors = [goldMain, goldHighlight, goldDeep, amberAccent];

    final particles = <_AINetworkParticle>[];

    // Central Energy Cluster Particles
    for (int i = 0; i < centralCount; i++) {
      final radiusNorm = 0.04 + (rand.nextDouble() * 0.28);
      final angle = rand.nextDouble() * 2 * math.pi;

      particles.add(_AINetworkParticle(
        isCentral: true,
        baseX: 0.5 + radiusNorm * math.cos(angle),
        baseY: 0.5 + radiusNorm * math.sin(angle),
        radiusX: radiusNorm,
        radiusY: radiusNorm * (0.7 + rand.nextDouble() * 0.6),
        freqX: (0.3 + rand.nextDouble() * 0.7) * widget.animationSpeed,
        freqY: (0.3 + rand.nextDouble() * 0.7) * widget.animationSpeed,
        freqZ: (0.2 + rand.nextDouble() * 0.5) * widget.animationSpeed,
        phaseX: rand.nextDouble() * 2 * math.pi,
        phaseY: rand.nextDouble() * 2 * math.pi,
        phaseZ: rand.nextDouble() * 2 * math.pi,
        rotSpeed: (rand.nextBool() ? 1 : -1) * (0.05 + rand.nextDouble() * 0.12) * widget.animationSpeed,
        size: 1.5 + rand.nextDouble() * 2.5,
        color: colors[rand.nextInt(colors.length)],
        hasGlow: rand.nextDouble() < 0.45,
        glowRadius: 6.0 + rand.nextDouble() * 10.0,
      ));
    }

    // Peripheral Drifting Network Particles
    for (int i = 0; i < peripheralCount; i++) {
      particles.add(_AINetworkParticle(
        isCentral: false,
        baseX: 0.05 + rand.nextDouble() * 0.90,
        baseY: 0.05 + rand.nextDouble() * 0.90,
        radiusX: 0.02 + rand.nextDouble() * 0.06,
        radiusY: 0.02 + rand.nextDouble() * 0.06,
        freqX: (0.15 + rand.nextDouble() * 0.45) * widget.animationSpeed,
        freqY: (0.15 + rand.nextDouble() * 0.45) * widget.animationSpeed,
        freqZ: (0.1 + rand.nextDouble() * 0.3) * widget.animationSpeed,
        phaseX: rand.nextDouble() * 2 * math.pi,
        phaseY: rand.nextDouble() * 2 * math.pi,
        phaseZ: rand.nextDouble() * 2 * math.pi,
        rotSpeed: (rand.nextBool() ? 1 : -1) * (0.02 + rand.nextDouble() * 0.06) * widget.animationSpeed,
        size: 1.2 + rand.nextDouble() * 2.0,
        color: colors[rand.nextInt(colors.length)],
        hasGlow: rand.nextDouble() < 0.25,
        glowRadius: 4.0 + rand.nextDouble() * 8.0,
      ));
    }

    _particles = particles;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = RepaintBoundary(
      child: CustomPaint(
        painter: _AINetworkPainter(
          animationValue: _controller,
          particles: _particles,
          opacity: widget.opacity,
          glowIntensity: widget.glowIntensity,
          connectionDistance: widget.connectionDistance,
          backgroundColor: widget.backgroundColor,
          maxConnectionsPerParticle: widget.maxConnectionsPerParticle,
          reducedMotion: widget.reducedMotion,
          drawBackground: widget.drawBackground,
        ),
        child: widget.child,
      ),
    );

    if (widget.child == null) {
      return IgnorePointer(child: painter);
    }

    return painter;
  }
}

class _AINetworkParticle {
  final bool isCentral;
  final double baseX;
  final double baseY;
  final double radiusX;
  final double radiusY;
  final double freqX;
  final double freqY;
  final double freqZ;
  final double phaseX;
  final double phaseY;
  final double phaseZ;
  final double rotSpeed;
  final double size;
  final Color color;
  final bool hasGlow;
  final double glowRadius;

  const _AINetworkParticle({
    required this.isCentral,
    required this.baseX,
    required this.baseY,
    required this.radiusX,
    required this.radiusY,
    required this.freqX,
    required this.freqY,
    required this.freqZ,
    required this.phaseX,
    required this.phaseY,
    required this.phaseZ,
    required this.rotSpeed,
    required this.size,
    required this.color,
    required this.hasGlow,
    required this.glowRadius,
  });

  Offset getOffset(double t, Size size, bool reducedMotion) {
    final effectiveT = reducedMotion ? t * 0.2 : t;
    double x, y;

    if (isCentral) {
      final baseAngle = math.atan2(baseY - 0.5, baseX - 0.5);
      final currentAngle = baseAngle + rotSpeed * effectiveT + 0.15 * math.sin(freqZ * effectiveT + phaseZ);

      final stretchX = 1.0 + 0.22 * math.sin(0.4 * effectiveT + phaseX);
      final stretchY = 1.0 + 0.22 * math.cos(0.3 * effectiveT + phaseY);

      final r = radiusX * (1.0 + 0.18 * math.sin(freqX * effectiveT + phaseX));

      x = 0.5 + r * stretchX * math.cos(currentAngle);
      y = 0.5 + r * stretchY * math.sin(currentAngle);
    } else {
      final dx = radiusX * math.sin(freqX * effectiveT + phaseX);
      final dy = radiusY * math.cos(freqY * effectiveT + phaseY);

      x = baseX + dx;
      y = baseY + dy;
    }

    return Offset(
      x.clamp(-0.05, 1.05) * size.width,
      y.clamp(-0.05, 1.05) * size.height,
    );
  }
}

class _AINetworkPainter extends CustomPainter {
  final Animation<double> animationValue;
  final List<_AINetworkParticle> particles;
  final double opacity;
  final double glowIntensity;
  final double connectionDistance;
  final Color backgroundColor;
  final int maxConnectionsPerParticle;
  final bool reducedMotion;
  final bool drawBackground;

  _AINetworkPainter({
    required this.animationValue,
    required this.particles,
    required this.opacity,
    required this.glowIntensity,
    required this.connectionDistance,
    required this.backgroundColor,
    required this.maxConnectionsPerParticle,
    required this.reducedMotion,
    required this.drawBackground,
  }) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || opacity <= 0) return;

    if (drawBackground) {
      final bgPaint = Paint()..color = backgroundColor.withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    }

    final t = animationValue.value * 2 * math.pi * 10.0;
    final count = particles.length;

    final positions = List<Offset>.generate(
      count,
      (i) => particles[i].getOffset(t, size, reducedMotion),
      growable: false,
    );

    final connectionCounts = List<int>.filled(count, 0);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 1.0;

    final maxDistSq = connectionDistance * connectionDistance;

    // 1. HIGH-PERFORMANCE DYNAMIC NETWORK CONNECTIONS & LINES
    for (int i = 0; i < count; i++) {
      if (connectionCounts[i] >= maxConnectionsPerParticle) continue;
      final p1 = positions[i];

      for (int j = i + 1; j < count; j++) {
        if (connectionCounts[j] >= maxConnectionsPerParticle) continue;

        final p2 = positions[j];
        final dx = p1.dx - p2.dx;
        final dy = p1.dy - p2.dy;
        final distSq = dx * dx + dy * dy;

        if (distSq < maxDistSq) {
          final dist = math.sqrt(distSq);
          final alphaNorm = (1.0 - (dist / connectionDistance)).clamp(0.0, 1.0);

          final isBothCentral = particles[i].isCentral && particles[j].isCentral;
          final lineAlpha = alphaNorm * (isBothCentral ? 0.60 : 0.35) * opacity;

          if (lineAlpha > 0.03) {
            linePaint.color = const Color(0xFFFFD76A).withValues(alpha: lineAlpha);
            linePaint.strokeWidth = isBothCentral ? 1.2 : 0.8;
            canvas.drawLine(p1, p2, linePaint);

            connectionCounts[i]++;
            connectionCounts[j]++;
          }
        }
      }
    }

    // 3. LUMINOUS PARTICLES & GOLDEN GLOW HALOS
    final glowPaint = Paint()..style = PaintingStyle.fill;
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final p = particles[i];
      final pos = positions[i];

      if (p.hasGlow && glowIntensity > 0) {
        final glowAlpha = (p.isCentral ? 0.25 : 0.15) * opacity * glowIntensity;
        glowPaint.color = const Color(0xFFFFD76A).withValues(alpha: glowAlpha);
        canvas.drawCircle(pos, p.glowRadius * glowIntensity, glowPaint);

        glowPaint.color = const Color(0xFFFFE9A8).withValues(alpha: glowAlpha * 1.5);
        canvas.drawCircle(pos, p.glowRadius * 0.4 * glowIntensity, glowPaint);
      }

      final pAlpha = (p.isCentral ? 0.95 : 0.75) * opacity;
      particlePaint.color = p.color.withValues(alpha: pAlpha);
      canvas.drawCircle(pos, p.size, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AINetworkPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.connectionDistance != connectionDistance ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.reducedMotion != reducedMotion ||
        oldDelegate.drawBackground != drawBackground;
  }
}
