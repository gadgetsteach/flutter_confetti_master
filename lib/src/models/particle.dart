import 'package:flutter/material.dart';
import 'confetti_shape.dart';

/// Represents a single particle in the confetti celebration engine.
class Particle {
  /// The current position of the particle.
  Offset position;

  /// The velocity vector of the particle (pixels per frame/update).
  Offset velocity;

  /// The acceleration vector of the particle.
  Offset acceleration;

  /// The primary color of the particle.
  final Color color;

  /// The shape of this particle.
  final ConfettiShape shape;

  /// The size (radius/dimension) of the particle.
  final double size;

  /// The current rotation angle in radians.
  double rotation;

  /// The rate of rotation in radians per update.
  double angularVelocity;

  /// The current opacity (transparency) of the particle (0.0 to 1.0).
  double opacity;

  /// The total lifetime of the particle in seconds.
  final double lifetime;

  /// The current age of the particle in seconds.
  double age;

  /// The 3D horizontal scale factor (oscillates to simulate 3D rotation).
  double scaleX;

  /// The 3D vertical scale factor.
  double scaleY;

  /// A unique random seed used for sinusoids (Wave, Spiral, Sparkle).
  final double uniqueSeed;

  /// The emoji character to render (if shape is emoji).
  final String? emoji;

  /// Whether this particle acts as a rocket (used in fireworks/rocket effects).
  final bool isRocket;

  /// List of historical positions to draw trails (used in sparkles/rockets).
  final List<Offset> trail;

  /// A tag to categorize particles (e.g. "spark", "smoke", "balloon").
  final String? tag;

  /// Additional metadata or customization state for specific effects.
  final Map<String, dynamic> extra;

  /// Creates a new [Particle].
  Particle({
    required this.position,
    required this.velocity,
    this.acceleration = Offset.zero,
    required this.color,
    required this.shape,
    required this.size,
    this.rotation = 0.0,
    this.angularVelocity = 0.0,
    this.opacity = 1.0,
    required this.lifetime,
    this.age = 0.0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    required this.uniqueSeed,
    this.emoji,
    this.isRocket = false,
    List<Offset>? trail,
    this.tag,
    Map<String, dynamic>? extra,
  })  : trail = trail ?? [],
        extra = extra ?? {};

  /// Checks if the particle is dead (reached or exceeded its lifetime, or fully faded out).
  bool get isDead => age >= lifetime || opacity <= 0.001;

  /// Updates the physical state of the particle for a single animation frame tick.
  ///
  /// [dt] is the delta time step.
  /// [drag] is the air resistance multiplier.
  /// [gravity] is the vertical pull force.
  void update({
    double dt = 1.0 / 60.0,
    double drag = 0.98,
    double gravity = 0.15,
  }) {
    age += dt;

    // Apply drag to velocity
    velocity = Offset(velocity.dx * drag, velocity.dy * drag);

    // Apply acceleration
    velocity = Offset(velocity.dx + acceleration.dx, velocity.dy + acceleration.dy + gravity);

    // Update position
    position = Offset(position.dx + velocity.dx, position.dy + velocity.dy);

    // Update rotation
    rotation += angularVelocity;

    // Simulate 3D tumbling by oscillating scaleX and scaleY using different frequencies
    scaleX = (age * 12 + uniqueSeed * 5).hashCode % 100 / 100.0 * 2.0 - 1.0;
    scaleY = (age * 8 + uniqueSeed * 7).hashCode % 100 / 100.0 * 2.0 - 1.0;

    // Store trails if needed (e.g. rockets or sparkle trails)
    if (isRocket || tag == 'rocket' || tag == 'sparkle_trail') {
      trail.add(position);
      if (trail.length > 15) {
        trail.removeAt(0);
      }
    }

    // Fade out as it nears the end of its life
    if (lifetime - age < 1.0) {
      opacity = (lifetime - age).clamp(0.0, 1.0);
    }
  }
}
