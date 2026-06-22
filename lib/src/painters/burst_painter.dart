import 'package:flutter/material.dart';
import 'particle_painter.dart';

/// Specialized custom painter for explosion bursts.
/// Draws a fading radial shockwave at the explosion origin in addition to the particles.
class BurstPainter extends ParticlePainter {
  /// The center of the explosion burst.
  final Offset burstOrigin;

  /// Creates a [BurstPainter].
  BurstPainter({
    required super.particles,
    required this.burstOrigin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw expanding shockwave
    if (particles.isNotEmpty) {
      final firstParticle = particles.first;
      // Use particle age to determine shockwave size
      final double age = firstParticle.age;
      if (age < 0.8) {
        final double progress = (age / 0.8).clamp(0.0, 1.0);
        final double radius = 30.0 + progress * 120.0;
        final double opacity = (1.0 - progress).clamp(0.0, 1.0);

        final shockPaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

        canvas.drawCircle(burstOrigin, radius, shockPaint);
      }
    }

    // 2. Draw standard particles
    super.paint(canvas, size);
  }
}
