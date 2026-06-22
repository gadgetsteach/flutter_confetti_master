import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/confetti_shape.dart';
import '../models/particle.dart';

/// General-purpose particle painter for drawing standard shapes (circles, squares,
/// triangles, stars, hearts, emojis, and dollar bills).
class ParticlePainter extends CustomPainter {
  /// The list of particles to paint.
  final List<Particle> particles;

  /// Creates a [ParticlePainter] with a given set of particles.
  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Don't draw if particle is fully transparent
      if (p.opacity <= 0.01) continue;

      canvas.save();
      
      // Move to particle position
      canvas.translate(p.position.dx, p.position.dy);
      
      // Apply rotation
      canvas.rotate(p.rotation);
      
      // Simulate 3D tumbling by scaling axes
      canvas.scale(p.scaleX, p.scaleY);

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      switch (p.shape) {
        case ConfettiShape.circle:
          if (p.tag == 'balloon') {
            _drawBalloon(canvas, p, paint);
          } else {
            canvas.drawCircle(Offset.zero, p.size, paint);
          }
          break;
        case ConfettiShape.square:
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size * 2, height: p.size * 2),
            paint,
          );
          break;
        case ConfettiShape.triangle:
          final trianglePath = Path()
            ..moveTo(0, -p.size)
            ..lineTo(p.size, p.size)
            ..lineTo(-p.size, p.size)
            ..close();
          canvas.drawPath(trianglePath, paint);
          break;
        case ConfettiShape.star:
          _drawStar(canvas, p.size, paint);
          break;
        case ConfettiShape.heart:
          _drawHeart(canvas, p.size, paint);
          break;
        case ConfettiShape.emoji:
        case ConfettiShape.trophy:
          _drawEmoji(canvas, p);
          break;
        case ConfettiShape.money:
          _drawMoney(canvas, p.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    const double cx = 0;
    const double cy = 0;
    const int spikes = 5;
    final double outerRadius = size;
    final double innerRadius = size * 0.45;

    double rot = math.pi / 2 * 3;
    const double step = math.pi / spikes;

    path.moveTo(cx, cy - outerRadius);
    for (int i = 0; i < spikes; i++) {
      double x = cx + math.cos(rot) * outerRadius;
      double y = cy + math.sin(rot) * outerRadius;
      path.lineTo(x, y);
      rot += step;

      x = cx + math.cos(rot) * innerRadius;
      y = cy + math.sin(rot) * innerRadius;
      path.lineTo(x, y);
      rot += step;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final double width = size * 2.2;
    final double height = size * 2.2;

    path.moveTo(0, height / 4);
    path.cubicTo(width / 2, -height / 3, width, height / 6, 0, height);
    path.cubicTo(-width, height / 6, -width / 2, -height / 3, 0, height / 4);
    path.close();

    // Center path vertically
    final Matrix4 matrix = Matrix4.translationValues(0, -height / 2.2, 0);
    canvas.drawPath(path.transform(matrix.storage), paint);
  }

  void _drawEmoji(Canvas canvas, Particle p) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: p.emoji ?? '🎉',
        style: TextStyle(
          fontSize: p.size * 1.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // To fade emojis on platforms where TextPainter ignores textStyle opacity:
    if (p.opacity < 0.99) {
      final bounds = Rect.fromCenter(
        center: Offset.zero,
        width: textPainter.width * 1.5,
        height: textPainter.height * 1.5,
      );
      canvas.saveLayer(bounds, Paint()..color = Colors.white.withValues(alpha: p.opacity));
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    } else {
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    }
  }

  void _drawMoney(Canvas canvas, double size, Paint paint) {
    final w = size * 2.6;
    final h = size * 1.4;
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.2));

    // 1. Draw money bill base background (green)
    canvas.drawRRect(rrect, paint);

    // 2. Draw border (darker green)
    final borderPaint = Paint()
      ..color = Colors.green.shade900.withValues(alpha: paint.color.a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.12;
    canvas.drawRRect(rrect, borderPaint);

    // 3. Draw center oval decorative detail
    final centerOval = Rect.fromCenter(center: Offset.zero, width: w * 0.5, height: h * 0.7);
    canvas.drawOval(centerOval, borderPaint);

    // 4. Draw "$" text in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: '\$',
        style: TextStyle(
          fontSize: size * 0.8,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade900.withValues(alpha: paint.color.a),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
  }

  void _drawBalloon(Canvas canvas, Particle p, Paint paint) {
    final double radiusX = p.size * 0.75;
    final double radiusY = p.size;

    // 1. Draw string hanging down
    final stringPaint = Paint()
      ..color = Colors.grey.shade400.withValues(alpha: p.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final stringPath = Path()
      ..moveTo(0, radiusY)
      ..quadraticBezierTo(
        math.sin(p.age * 3) * 15,
        radiusY + p.size * 0.8,
        math.cos(p.age * 2) * 5,
        radiusY + p.size * 1.8,
      );
    canvas.drawPath(stringPath, stringPaint);

    // 2. Draw balloon body
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radiusX * 2, height: radiusY * 2),
      paint,
    );

    // 3. Draw balloon knot (triangle at the bottom)
    final knotPath = Path()
      ..moveTo(-p.size * 0.15, radiusY)
      ..lineTo(p.size * 0.15, radiusY)
      ..lineTo(0, radiusY + p.size * 0.15)
      ..close();
    canvas.drawPath(knotPath, paint);

    // 4. Draw highlights (semi-transparent white oval at top-left)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: p.opacity * 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-radiusX * 0.35, -radiusY * 0.35),
        width: radiusX * 0.4,
        height: radiusY * 0.4,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
