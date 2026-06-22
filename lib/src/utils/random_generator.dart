import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/confetti_shape.dart';

/// Helper utility for generating randomized values for particle physics and appearance.
class RandomGenerator {
  static final math.Random _random = math.Random();

  /// Generates a random double between [min] and [max].
  static double doubleInRange(double min, double max) {
    if (min >= max) return min;
    return min + _random.nextDouble() * (max - min);
  }

  /// Generates a random integer between [min] and [max] (inclusive).
  static int intInRange(int min, int max) {
    if (min >= max) return min;
    return min + _random.nextInt(max - min + 1);
  }

  /// Selects a random color from [colors].
  static Color randomColor(List<Color> colors) {
    if (colors.isEmpty) return Colors.grey;
    return colors[_random.nextInt(colors.length)];
  }

  /// Selects a random shape from [shapes].
  static ConfettiShape randomShape(List<ConfettiShape> shapes) {
    if (shapes.isEmpty) return ConfettiShape.circle;
    return shapes[_random.nextInt(shapes.length)];
  }

  /// Selects a random emoji from [emojis].
  static String randomEmoji(List<String> emojis) {
    if (emojis.isEmpty) return '🎉';
    return emojis[_random.nextInt(emojis.length)];
  }

  /// Generates a random sign: `1.0` or `-1.0`.
  static double randomSign() {
    return _random.nextBool() ? 1.0 : -1.0;
  }

  /// Generates a random angle in radians within a spread centered around a direction.
  static double randomAngle(double direction, double spread) {
    final halfSpread = spread / 2;
    return direction + doubleInRange(-halfSpread, halfSpread);
  }
}
