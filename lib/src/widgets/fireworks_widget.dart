import 'package:flutter/material.dart';
import '../controllers/confetti_controller.dart';
import '../painters/fireworks_painter.dart';

/// A specialized widget for rendering fireworks and rocket launch celebrations.
class FireworksWidget extends StatefulWidget {
  /// The controller managing the fireworks simulation.
  final ConfettiController controller;

  /// An optional child widget to display underneath the fireworks.
  final Widget? child;

  /// Creates a [FireworksWidget].
  const FireworksWidget({
    super.key,
    required this.controller,
    this.child,
  });

  @override
  State<FireworksWidget> createState() => _FireworksWidgetState();
}

class _FireworksWidgetState extends State<FireworksWidget> {
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
                painter: FireworksPainter(
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
