import 'package:flutter/material.dart';
import '../controllers/confetti_controller.dart';
import '../painters/rain_painter.dart';

/// A specialized widget for rendering falling confetti rain effects.
class RainWidget extends StatefulWidget {
  /// The controller managing the rain particle simulation.
  final ConfettiController controller;

  /// An optional child widget to display underneath the rain simulation.
  final Widget? child;

  /// Creates a [RainWidget].
  const RainWidget({
    super.key,
    required this.controller,
    this.child,
  });

  @override
  State<RainWidget> createState() => _RainWidgetState();
}

class _RainWidgetState extends State<RainWidget> {
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
                painter: RainPainter(
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
