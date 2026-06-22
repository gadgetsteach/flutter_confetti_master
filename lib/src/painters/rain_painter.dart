import 'package:flutter/material.dart';
import 'particle_painter.dart';

/// Specialized custom painter for falling rain.
/// Renders subtle wind streaks and trailing ribbon lines behind falling particles.
class RainPainter extends ParticlePainter {
  /// Creates a [RainPainter].
  RainPainter({required super.particles});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw speed streaks behind falling particles
    for (final p in particles) {
      if (p.opacity <= 0.05) continue;

      final streakPaint = Paint()
        ..color = p.color.withValues(alpha: p.opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = p.size * 0.4
        ..strokeCap = StrokeCap.round;

      // Draw a line opposite to its velocity vector
      final Offset start = p.position;
      final Offset end =
          p.position - Offset(p.velocity.dx * 2.5, p.velocity.dy * 2.5);
      canvas.drawLine(start, end, streakPaint);
    }

    // 2. Draw standard rain particles on top
    super.paint(canvas, size);
  }
}
