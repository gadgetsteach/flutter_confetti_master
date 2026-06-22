import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_confetti_master/flutter_confetti_master.dart';
import 'package:flutter_confetti_master/src/utils/random_generator.dart';

void main() {
  group('RandomGenerator tests', () {
    test('doubleInRange returns values within bounds', () {
      final val = RandomGenerator.doubleInRange(2.0, 5.0);
      expect(val, greaterThanOrEqualTo(2.0));
      expect(val, lessThanOrEqualTo(5.0));
    });

    test('intInRange returns values within bounds', () {
      final val = RandomGenerator.intInRange(10, 20);
      expect(val, greaterThanOrEqualTo(10));
      expect(val, lessThanOrEqualTo(20));
    });

    test('randomColor returns a color from the list', () {
      final colors = [Colors.red, Colors.blue];
      final color = RandomGenerator.randomColor(colors);
      expect(colors.contains(color), isTrue);
    });

    test('randomShape returns a shape from the list', () {
      final shapes = [ConfettiShape.star, ConfettiShape.heart];
      final shape = RandomGenerator.randomShape(shapes);
      expect(shapes.contains(shape), isTrue);
    });

    test('randomEmoji returns an emoji from the list', () {
      final emojis = ['🎉', '🎈'];
      final emoji = RandomGenerator.randomEmoji(emojis);
      expect(emojis.contains(emoji), isTrue);
    });

    test('randomSign returns either 1.0 or -1.0', () {
      final sign = RandomGenerator.randomSign();
      expect(sign == 1.0 || sign == -1.0, isTrue);
    });
  });

  group('Particle physics tests', () {
    test('Particle physics update applies gravity and drag correctly', () {
      final p = Particle(
        position: const Offset(10, 10),
        velocity: const Offset(10, -10),
        color: Colors.red,
        shape: ConfettiShape.circle,
        size: 5.0,
        lifetime: 2.0,
        uniqueSeed: 42.0,
      );

      expect(p.isDead, isFalse);
      
      // Update one step
      p.update(dt: 0.1, drag: 0.9, gravity: 2.0);

      // Verify velocity = (10 * 0.9 + 0, -10 * 0.9 + 2) = (9, -7)
      expect(p.velocity.dx, closeTo(9.0, 0.001));
      expect(p.velocity.dy, closeTo(-7.0, 0.001));

      // Verify position = (10 + 9, 10 - 7) = (19, 3)
      expect(p.position.dx, closeTo(19.0, 0.001));
      expect(p.position.dy, closeTo(3.0, 0.001));

      expect(p.age, closeTo(0.1, 0.001));
    });

    test('Particle is dead when age exceeds lifetime', () {
      final p = Particle(
        position: Offset.zero,
        velocity: Offset.zero,
        color: Colors.red,
        shape: ConfettiShape.circle,
        size: 5.0,
        lifetime: 1.0,
        uniqueSeed: 42.0,
        age: 0.95,
      );

      expect(p.isDead, isFalse);

      p.update(dt: 0.1);

      expect(p.isDead, isTrue);
    });
  });

  group('ConfettiController State tests', () {
    test('Initial controller state', () {
      final controller = ConfettiController(
        effect: ConfettiEffect.burst,
        options: const ConfettiOptions(particleCount: 50),
        duration: const Duration(seconds: 2),
      );

      expect(controller.isPlaying, isFalse);
      expect(controller.isPaused, isFalse);
      expect(controller.particles, isEmpty);
    });

    test('Play/Pause/Resume/Stop flow', () {
      final controller = ConfettiController(
        effect: ConfettiEffect.burst,
        options: const ConfettiOptions(particleCount: 50),
      );

      // Start play with non-zero canvas size
      controller.updateCanvasSize(const Size(500, 500));
      controller.play();

      expect(controller.isPlaying, isTrue);
      expect(controller.particles.length, 50);

      controller.pause();
      expect(controller.isPlaying, isFalse);
      expect(controller.isPaused, isTrue);

      controller.resume();
      expect(controller.isPlaying, isTrue);
      expect(controller.isPaused, isFalse);

      controller.stop();
      expect(controller.isPlaying, isFalse);
      expect(controller.isPaused, isFalse);
      expect(controller.particles, isEmpty);
      controller.dispose();
    });

    test('triggerManualExplosion adds new particles', () {
      final controller = ConfettiController(
        effect: ConfettiEffect.burst,
        options: const ConfettiOptions(particleCount: 10),
      );
      controller.updateCanvasSize(const Size(500, 500));

      controller.triggerManualExplosion(const Offset(250, 250), count: 15);
      expect(controller.particles.length, 25); // 10 initial + 15 manual
      controller.dispose();
    });

    test('triggerBalloonPop pops matching balloon', () {
      final controller = ConfettiController(
        effect: ConfettiEffect.balloonBurst,
        options: const ConfettiOptions(particleCount: 5),
      );
      controller.updateCanvasSize(const Size(500, 500));
      controller.play();

      expect(controller.particles.any((p) => p.tag == 'balloon'), isTrue);

      final balloon = controller.particles.firstWhere((p) => p.tag == 'balloon');
      // Tap on it
      final popped = controller.triggerBalloonPop(balloon.position);

      expect(popped, isTrue);
      controller.dispose();
    });
  });

  group('ConfettiMaster Widget tests', () {
    testWidgets('ConfettiMaster renders successfully and plays automatically', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: ConfettiMaster(
                effect: ConfettiEffect.burst,
                autoPlay: true,
                particleCount: 30,
              ),
            ),
          ),
        ),
      );

      // Wait a frame to let size updates settle and post-frame callbacks trigger play
      await tester.pump(const Duration(milliseconds: 16));

      // Assert that a CustomPaint exists in tree under ConfettiMaster
      expect(
        find.descendant(
          of: find.byType(ConfettiMaster),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });
  });
}
