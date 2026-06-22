import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'particle_painter.dart';

/// Specialized custom painter for spiral motion.
/// Renders rotating spiral orbit lines that visually trace the path of particles.
class SpiralPainter extends ParticlePainter {
  /// The center point of the spiral.
  final Offset center;

  /// Creates a [SpiralPainter].
  SpiralPainter({
    required super.particles,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw a faint background spiral pattern
    if (particles.isNotEmpty) {
      final double rotationPhase = particles.first.age * 0.5;
      final path = Path();
      
      final spiralPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw 3 spiral arms in the background
      for (int arm = 0; arm < 3; arm++) {
        final double startAngle = (arm / 3) * 2 * math.pi + rotationPhase;
        path.reset();
        path.moveTo(center.dx, center.dy);
        
        for (double r = 0.0; r < size.width * 0.7; r += 5.0) {
          final double theta = startAngle + r * 0.008;
          path.lineTo(
            center.dx + r * math.cos(theta),
            center.dy + r * math.sin(theta),
          );
        }
        canvas.drawPath(path, spiralPaint);
      }
    }

    // 2. Draw standard particles
    super.paint(canvas, size);
  }
}
