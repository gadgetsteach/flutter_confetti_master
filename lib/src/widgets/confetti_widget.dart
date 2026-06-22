import 'package:flutter/material.dart';
import '../controllers/confetti_controller.dart';
import '../models/confetti_options.dart';
import '../models/confetti_shape.dart';
import '../painters/burst_painter.dart';
import '../painters/particle_painter.dart';
import '../painters/spiral_painter.dart';
import 'cannon_widget.dart';
import 'fireworks_widget.dart';
import 'rain_widget.dart';

/// Specialized widget for rendering bursts, spirals, waves, balloon bursts, and general particle systems.
class ConfettiWidget extends StatefulWidget {
  /// The controller managing the confetti simulation.
  final ConfettiController controller;

  /// An optional child widget.
  final Widget? child;

  /// Creates a [ConfettiWidget].
  const ConfettiWidget({
    super.key,
    required this.controller,
    this.child,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
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

        final paintWidget = ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            CustomPainter painter;
            final origin = widget.controller.options.blastPosition ?? Offset(size.width / 2, size.height / 2);

            if (widget.controller.effect == ConfettiEffect.spiral) {
              painter = SpiralPainter(
                particles: widget.controller.particles,
                center: origin,
              );
            } else if (widget.controller.effect == ConfettiEffect.burst ||
                widget.controller.effect == ConfettiEffect.stars ||
                widget.controller.effect == ConfettiEffect.hearts ||
                widget.controller.effect == ConfettiEffect.emoji) {
              painter = BurstPainter(
                particles: widget.controller.particles,
                burstOrigin: origin,
              );
            } else {
              painter = ParticlePainter(
                particles: widget.controller.particles,
              );
            }

            return CustomPaint(
              size: size,
              painter: painter,
            );
          },
        );

        // Enable touch interactions for balloon burst
        final Widget interactivePaint = GestureDetector(
          onTapDown: (details) {
            if (widget.controller.effect == ConfettiEffect.balloonBurst) {
              widget.controller.triggerBalloonPop(details.localPosition);
            } else {
              // Trigger manual burst at tap position for standard effects
              widget.controller.triggerManualExplosion(details.localPosition);
            }
          },
          child: AbsorbPointer(
            absorbing: widget.controller.effect != ConfettiEffect.balloonBurst,
            child: paintWidget,
          ),
        );

        if (widget.child != null) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              widget.child!,
              Positioned.fill(
                child: interactivePaint,
              ),
            ],
          );
        }

        return interactivePaint;
      },
    );
  }
}

/// The unified entry-point widget for all 15 celebration and particle effects.
class ConfettiMaster extends StatefulWidget {
  /// The effect to run.
  final ConfettiEffect effect;

  /// Custom configuration options. If not specified, standard defaults for the effect are used.
  final ConfettiOptions? options;

  /// Optional list of colors to override default option colors.
  final List<Color>? colors;

  /// Optional particle count override.
  final int? particleCount;

  /// Play the animation automatically on mount.
  final bool autoPlay;

  /// How long the effect should emit particles. If null, it runs continuously.
  final Duration? duration;

  /// An optional external [ConfettiController] to coordinate play/pause/stop manually.
  /// If provided, this widget will NOT dispose of the controller.
  final ConfettiController? controller;

  /// Optional child widget to overlay celebration effects on top of.
  final Widget? child;

  /// Creates a [ConfettiMaster] orchestrator.
  const ConfettiMaster({
    super.key,
    required this.effect,
    this.options,
    this.colors,
    this.particleCount,
    this.autoPlay = true,
    this.duration,
    this.controller,
    this.child,
  });

  @override
  State<ConfettiMaster> createState() => _ConfettiMasterState();
}

class _ConfettiMasterState extends State<ConfettiMaster> {
  late ConfettiController _activeController;
  bool _isLocalController = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller != null) {
      _activeController = widget.controller!;
      _isLocalController = false;
    } else {
      _activeController = ConfettiController(
        effect: widget.effect,
        options: _buildConfigOptions(),
        duration: widget.duration,
        autoPlay: widget.autoPlay,
      );
      _isLocalController = true;
    }
  }

  ConfettiOptions _buildConfigOptions() {
    ConfettiOptions base = widget.options ?? const ConfettiOptions();

    // Setup typical default settings based on effect type
    switch (widget.effect) {
      case ConfettiEffect.burst:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 80,
          shapes: [ConfettiShape.circle, ConfettiShape.square, ConfettiShape.triangle],
        );
        break;
      case ConfettiEffect.cannon:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 100,
          gravity: 0.2,
          minVelocity: 8.0,
          maxVelocity: 16.0,
          shapes: [ConfettiShape.circle, ConfettiShape.square],
        );
        break;
      case ConfettiEffect.rain:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 120,
          gravity: 0.08,
          minVelocity: 1.0,
          maxVelocity: 3.0,
          loop: true,
        );
        break;
      case ConfettiEffect.moneyRain:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 40,
          gravity: 0.05,
          minVelocity: 0.8,
          maxVelocity: 2.0,
          shapes: [ConfettiShape.money],
          loop: true,
        );
        break;
      case ConfettiEffect.fireworks:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 50,
          gravity: 0.15,
          minVelocity: 1.5,
          maxVelocity: 4.0,
          loop: true,
        );
        break;
      case ConfettiEffect.rocketLaunch:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 15,
          gravity: 0.12,
          minVelocity: 1.0,
          maxVelocity: 3.5,
          loop: true,
        );
        break;
      case ConfettiEffect.stars:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 70,
          shapes: [ConfettiShape.star],
        );
        break;
      case ConfettiEffect.hearts:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 60,
          shapes: [ConfettiShape.heart],
          colors: [Colors.red, Colors.pink, Colors.redAccent, Colors.pinkAccent],
        );
        break;
      case ConfettiEffect.emoji:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 50,
          shapes: [ConfettiShape.emoji],
        );
        break;
      case ConfettiEffect.spiral:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 90,
          minVelocity: 0.0,
          maxVelocity: 0.0,
          gravity: 0.0,
        );
        break;
      case ConfettiEffect.wave:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 80,
          gravity: 0.06,
          minVelocity: 0.8,
          maxVelocity: 2.2,
          loop: true,
        );
        break;
      case ConfettiEffect.trophy:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 35,
          shapes: [ConfettiShape.trophy],
          gravity: 0.18,
          minVelocity: 6.0,
          maxVelocity: 12.0,
        );
        break;
      case ConfettiEffect.balloonBurst:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 8,
          loop: true,
        );
        break;
      case ConfettiEffect.sparkleTrail:
        base = base.copyWith(
          particleCount: widget.particleCount ?? 150,
          shapes: [ConfettiShape.star],
          gravity: 0.04,
          loop: true,
        );
        break;
      default:
        break;
    }

    // Overriding colors if provided explicitly
    if (widget.colors != null) {
      base = base.copyWith(colors: widget.colors);
    }
    
    // Overriding particle count if provided explicitly
    if (widget.particleCount != null) {
      base = base.copyWith(particleCount: widget.particleCount);
    }

    return base;
  }

  @override
  void didUpdateWidget(covariant ConfettiMaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final hasControllerChanged = widget.controller != oldWidget.controller;
    final hasEffectChanged = widget.effect != oldWidget.effect;
    
    if (hasControllerChanged || hasEffectChanged) {
      if (_isLocalController) {
        _activeController.dispose();
      }
      _initController();
    } else {
      // Just update configuration parameters
      _activeController.options = _buildConfigOptions();
    }
  }

  @override
  void dispose() {
    if (_isLocalController) {
      _activeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.effect) {
      case ConfettiEffect.cannon:
        return CannonWidget(
          controller: _activeController,
          child: widget.child,
        );
      case ConfettiEffect.rain:
      case ConfettiEffect.moneyRain:
      case ConfettiEffect.trophy:
        return RainWidget(
          controller: _activeController,
          child: widget.child,
        );
      case ConfettiEffect.fireworks:
      case ConfettiEffect.rocketLaunch:
        return FireworksWidget(
          controller: _activeController,
          child: widget.child,
        );
      default:
        return ConfettiWidget(
          controller: _activeController,
          child: widget.child,
        );
    }
  }
}
