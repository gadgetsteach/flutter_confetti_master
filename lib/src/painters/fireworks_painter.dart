import 'package:flutter/material.dart';
import 'particle_painter.dart';

/// Specialized custom painter for fireworks and rocket launches.
/// Renders glowing exhaust trails and bright rocket flares.
class FireworksPainter extends ParticlePainter {
  /// Creates a [FireworksPainter].
  FireworksPainter({required super.particles});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw trails for rockets and sparks
    for (final p in particles) {
      if (p.trail.length < 2) continue;

      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < p.trail.length - 1; i++) {
        final double factor = i / (p.trail.length - 1);
        trailPaint.color = p.color.withValues(alpha: p.opacity * factor * 0.5);
        trailPaint.strokeWidth = p.size * factor * 0.8;

        canvas.drawLine(p.trail[i], p.trail[i + 1], trailPaint);
      }
    }

    // 2. Draw standard particles (rockets and sparks)
    super.paint(canvas, size);

    // 3. Draw a glow flare on rockets
    for (final p in particles) {
      if (p.tag == 'rocket' || p.tag == 'launch_rocket') {
        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
        canvas.drawCircle(p.position, p.size * 1.5, glowPaint);
      }
    }
  }
}
