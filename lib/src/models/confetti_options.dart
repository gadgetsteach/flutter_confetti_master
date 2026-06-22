import 'package:flutter/material.dart';
import 'confetti_shape.dart';

/// Configuration options for the confetti and particle simulations.
class ConfettiOptions {
  /// The colors available to particles.
  final List<Color> colors;

  /// The gravity pulling particles down. Positive is downwards.
  final double gravity;

  /// The minimum speed for spawned particles.
  final double minVelocity;

  /// The maximum speed for spawned particles.
  final double maxVelocity;

  /// The minimum scale factor for particles.
  final double minScale;

  /// The maximum scale factor for particles.
  final double maxScale;

  /// The number of particles spawned in this effect.
  final int particleCount;

  /// The list of shapes to randomly choose from when spawning particles.
  final List<ConfettiShape> shapes;

  /// Emojis used when [ConfettiShape.emoji] is active.
  final List<String> emojis;

  /// The direction in radians to launch particles (used by Cannon).
  ///
  /// `0` is to the right, `pi / 2` is downwards, `pi` is to the left, `3 * pi / 2` (or `-pi / 2`) is upwards.
  final double blastDirection;

  /// The spread angle in radians (used by Cannon).
  final double spread;

  /// Air resistance drag coefficient. Typically between `0.9` and `1.0`.
  /// Lower values cause particles to slow down faster.
  final double drag;

  /// Whether the animation should restart automatically after completing.
  final bool loop;

  /// The starting offset of the emission source. If null, the center or standard position is used.
  final Offset? blastPosition;

  /// Creates a new instance of [ConfettiOptions].
  const ConfettiOptions({
    this.colors = const [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.pink,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
    ],
    this.gravity = 0.15,
    this.minVelocity = 2.0,
    this.maxVelocity = 8.0,
    this.minScale = 0.5,
    this.maxScale = 1.0,
    this.particleCount = 80,
    this.shapes = const [ConfettiShape.circle, ConfettiShape.square, ConfettiShape.triangle],
    this.emojis = const ['🎉', '✨', '🎈', '❤️', '🥳', '🌟', '🦄', '🧁'],
    this.blastDirection = -3.14159 / 2, // upwards (-pi / 2)
    this.spread = 3.14159 / 4,          // 45 degrees (pi / 4)
    this.drag = 0.98,
    this.loop = false,
    this.blastPosition,
  });

  /// Copy this options object with overridden fields.
  ConfettiOptions copyWith({
    List<Color>? colors,
    double? gravity,
    double? minVelocity,
    double? maxVelocity,
    double? minScale,
    double? maxScale,
    int? particleCount,
    List<ConfettiShape>? shapes,
    List<String>? emojis,
    double? blastDirection,
    double? spread,
    double? drag,
    bool? loop,
    Offset? blastPosition,
  }) {
    return ConfettiOptions(
      colors: colors ?? this.colors,
      gravity: gravity ?? this.gravity,
      minVelocity: minVelocity ?? this.minVelocity,
      maxVelocity: maxVelocity ?? this.maxVelocity,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      particleCount: particleCount ?? this.particleCount,
      shapes: shapes ?? this.shapes,
      emojis: emojis ?? this.emojis,
      blastDirection: blastDirection ?? this.blastDirection,
      spread: spread ?? this.spread,
      drag: drag ?? this.drag,
      loop: loop ?? this.loop,
      blastPosition: blastPosition ?? this.blastPosition,
    );
  }
}
