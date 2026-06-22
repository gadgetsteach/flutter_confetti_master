import 'package:flutter/material.dart';
import '../controllers/confetti_controller.dart';
import '../painters/particle_painter.dart';

/// A specialized widget for rendering confetti cannon effects.
class CannonWidget extends StatefulWidget {
  /// The controller managing the cannon particle simulation.
  final ConfettiController controller;

  /// An optional child widget to display underneath the cannon simulation.
  final Widget? child;

  /// Creates a [CannonWidget].
  const CannonWidget({
    super.key,
    required this.controller,
    this.child,
  });

  @override
  State<CannonWidget> createState() => _CannonWidgetState();
}

class _CannonWidgetState extends State<CannonWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        // Pass layout size to simulation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.controller.updateCanvasSize(size);
          }
        });

        final paintWidget = RepaintBoundary(
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: ParticlePainter(
                  particles: widget.controller.particles,
                ),
              );
            },
          ),
        );

        if (widget.child != null) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              widget.child!,
              Positioned.fill(
                child: IgnorePointer(
                  child: paintWidget,
                ),
              ),
            ],
          );
        }

        return paintWidget;
      },
    );
  }
}
