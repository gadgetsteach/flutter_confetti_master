import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/confetti_options.dart';
import '../models/confetti_shape.dart';
import '../models/particle.dart';
import '../utils/random_generator.dart';

/// Supported confetti and celebration effects.
enum ConfettiEffect {
  /// Circular explosion burst from a point.
  burst,

  /// Targeted spray shot from a source angle.
  cannon,

  /// Continuous rain falling from the top.
  rain,

  /// Interactive/multiple exploding firework rockets.
  fireworks,

  /// Burst/fall of star-shaped foil.
  stars,

  /// Float/fall of red and pink hearts.
  hearts,

  /// Float/fall of randomly selected emojis.
  emoji,

  /// Swirling spiral expansion from the center.
  spiral,

  /// Falling particles that sway side-to-side sinusoidally.
  wave,

  /// Fully customizable advanced physics particles.
  particles,

  /// Falling green dollar bill notes tumbling in 3D.
  moneyRain,

  /// Balloon float-up that bursts into secondary confetti.
  balloonBurst,

  /// Twinkling sparkles trailing a moving emitter.
  sparkleTrail,

  /// Blasting trophies and gold medals.
  trophy,

  /// Rocket launch with smoke trails and final peak explosion.
  rocketLaunch,
}

/// The controller managing the animation tick and particle physics simulation.
class ConfettiController extends ChangeNotifier {
  /// The active list of simulated particles.
  final List<Particle> particles = [];

  /// Configuration options for the simulation.
  ConfettiOptions options;

  /// The active confetti effect.
  final ConfettiEffect effect;

  /// The duration of the particle emission.
  final Duration? duration;

  /// Whether the controller starts playing automatically.
  final bool autoPlay;

  Ticker? _ticker;
  double _elapsedSeconds = 0.0;
  bool _isPlaying = false;
  bool _isPaused = false;
  Size _canvasSize = Size.zero;

  // Emitter variables for Sparkle Trail and general continuous spawners
  double _spawnTimer = 0.0;
  double _sparklePathAngle = 0.0;

  /// Creates a [ConfettiController] for managing celebration simulations.
  ConfettiController({
    this.effect = ConfettiEffect.burst,
    this.options = const ConfettiOptions(),
    this.duration,
    this.autoPlay = false,
  });

  /// Check if the simulation is currently active.
  bool get isPlaying => _isPlaying;

  /// Check if the simulation is currently paused.
  bool get isPaused => _isPaused;

  /// Sets the canvas size and initializes particles if needed.
  void updateCanvasSize(Size size) {
    if (_canvasSize != size) {
      _canvasSize = size;
      if (autoPlay && !_isPlaying && !_isPaused && size != Size.zero) {
        play();
      }
    }
  }

  /// Initialize and start the animation.
  void play() {
    if (_canvasSize == Size.zero) {
      // Defer play until canvas size is set
      return;
    }
    _isPlaying = true;
    _isPaused = false;
    _elapsedSeconds = 0.0;
    particles.clear();
    _spawnTimer = 0.0;

    // Spawn initial particles for burst-type effects
    _spawnInitialParticles();

    _ticker?.dispose();
    _ticker = Ticker(_onTick);
    _ticker!.start();
    notifyListeners();
  }

  /// Pause the particle simulation.
  void pause() {
    if (!_isPlaying) return;
    _isPlaying = false;
    _isPaused = true;
    _ticker?.stop();
    notifyListeners();
  }

  /// Resume a paused particle simulation.
  void resume() {
    if (!_isPaused) return;
    _isPlaying = true;
    _isPaused = false;
    _ticker?.start();
    notifyListeners();
  }

  /// Stop and reset the particle simulation.
  void stop() {
    _isPlaying = false;
    _isPaused = false;
    _ticker?.stop();
    particles.clear();
    notifyListeners();
  }

  /// Stop and restart the particle simulation from the beginning.
  void replay() {
    stop();
    play();
  }

  /// Dispose the controller.
  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    const double dt = 1.0 / 60.0;
    _elapsedSeconds += dt;

    // 1. Check duration expiration
    if (duration != null && _elapsedSeconds >= duration!.inMilliseconds / 1000.0) {
      if (options.loop) {
        _elapsedSeconds = 0.0;
        // Re-spawn or just keep going
      } else {
        // Stop spawning, let existing particles finish
      }
    }

    // 2. Continuous Spawning (Rain, Money Rain, Fireworks, Rocket, Sparkle, etc.)
    final bool canSpawn = duration == null || _elapsedSeconds < duration!.inMilliseconds / 1000.0 || options.loop;
    if (canSpawn) {
      _handleContinuousSpawning(dt);
    }

    // 3. Update physics for all active particles
    _updateParticlePhysics(dt);

    // 4. Stop ticker if all particles are dead
    if (particles.isEmpty && !canSpawn) {
      stop();
    } else {
      notifyListeners();
    }
  }

  void _spawnInitialParticles() {
    final spawnPoint = options.blastPosition ?? Offset(_canvasSize.width / 2, _canvasSize.height / 2);

    switch (effect) {
      case ConfettiEffect.burst:
        _spawnBurst(spawnPoint, options.particleCount);
        break;
      case ConfettiEffect.cannon:
        final cannonPoint = options.blastPosition ?? Offset(_canvasSize.width / 2, _canvasSize.height);
        _spawnCannon(cannonPoint, options.particleCount);
        break;
      case ConfettiEffect.stars:
        _spawnBurst(spawnPoint, options.particleCount, shapeOverride: ConfettiShape.star);
        break;
      case ConfettiEffect.hearts:
        _spawnBurst(spawnPoint, options.particleCount, shapeOverride: ConfettiShape.heart);
        break;
      case ConfettiEffect.emoji:
        _spawnBurst(spawnPoint, options.particleCount, shapeOverride: ConfettiShape.emoji);
        break;
      case ConfettiEffect.spiral:
        _spawnSpiral(spawnPoint, options.particleCount);
        break;
      case ConfettiEffect.trophy:
        final trophyPoint = options.blastPosition ?? Offset(_canvasSize.width / 2, _canvasSize.height - 30);
        _spawnTrophyCelebration(trophyPoint, options.particleCount);
        break;
      case ConfettiEffect.balloonBurst:
        _spawnBalloons(5);
        break;
      default:
        // Rain, Fireworks, Money Rain, Sparkle Trail, Rocket Launch are continuous spawners
        break;
    }
  }

  void _handleContinuousSpawning(double dt) {
    _spawnTimer += dt;

    switch (effect) {
      case ConfettiEffect.rain:
        if (_spawnTimer >= 0.05 && particles.length < options.particleCount) {
          _spawnTimer = 0.0;
          _spawnRainDrop();
        }
        break;
      case ConfettiEffect.moneyRain:
        if (_spawnTimer >= 0.1 && particles.length < options.particleCount) {
          _spawnTimer = 0.0;
          _spawnMoneyBill();
        }
        break;
      case ConfettiEffect.fireworks:
        if (_spawnTimer >= 0.8 && particles.length < options.particleCount) {
          _spawnTimer = 0.0;
          _spawnFireworkRocket();
        }
        break;
      case ConfettiEffect.rocketLaunch:
        if (_spawnTimer >= 0.9 && particles.length < options.particleCount) {
          _spawnTimer = 0.0;
          _spawnLaunchRocket();
        }
        break;
      case ConfettiEffect.sparkleTrail:
        if (_spawnTimer >= 0.03) {
          _spawnTimer = 0.0;
          _spawnSparkleFromTrail();
        }
        break;
      case ConfettiEffect.wave:
        if (_spawnTimer >= 0.06 && particles.length < options.particleCount) {
          _spawnTimer = 0.0;
          _spawnWaveParticle();
        }
        break;
      default:
        break;
    }
  }

  void _updateParticlePhysics(double dt) {
    final List<Particle> deadParticles = [];

    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];

      // Standard physics update
      p.update(
        dt: dt,
        drag: options.drag,
        gravity: options.gravity,
      );

      // Effect-specific custom motion adjustments
      if (effect == ConfettiEffect.spiral) {
        final double radialSpeed = p.extra['radialSpeed'] ?? 2.0;
        final double angularSpeed = p.extra['angularSpeed'] ?? 0.05;
        p.extra['radius'] = (p.extra['radius'] ?? 0.0) + radialSpeed;
        p.extra['angle'] = (p.extra['angle'] ?? 0.0) + angularSpeed;

        final double r = p.extra['radius'];
        final double theta = p.extra['angle'];
        final Offset center = p.extra['center'] ?? Offset(_canvasSize.width / 2, _canvasSize.height / 2);
        
        p.position = Offset(
          center.dx + r * math.cos(theta),
          center.dy + r * math.sin(theta),
        );
      } else if (effect == ConfettiEffect.wave) {
        final double amp = p.extra['amplitude'] ?? 30.0;
        final double freq = p.extra['frequency'] ?? 4.0;
        final double baseDx = p.extra['baseDx'] ?? p.position.dx;
        
        // Sinusoidal horizontal displacement
        p.position = Offset(
          baseDx + amp * math.sin(p.age * freq + p.uniqueSeed * 10),
          p.position.dy,
        );
      } else if (p.tag == 'rocket') {
        // Rocket trail spawning
        if (p.age % 0.05 < dt) {
          particles.add(Particle(
            position: p.position,
            velocity: Offset(RandomGenerator.doubleInRange(-0.5, 0.5), RandomGenerator.doubleInRange(1.0, 3.0)),
            color: RandomGenerator.randomColor([Colors.orange, Colors.red, Colors.yellow]),
            shape: ConfettiShape.circle,
            size: RandomGenerator.doubleInRange(2.0, 5.0),
            lifetime: RandomGenerator.doubleInRange(0.3, 0.6),
            uniqueSeed: RandomGenerator.doubleInRange(0, 100),
            tag: 'smoke',
          ));
        }

        // Explode at peak velocity or height
        if (p.velocity.dy >= -0.2) {
          deadParticles.add(p);
          _explodeFirework(p.position, p.color);
        }
      } else if (p.tag == 'launch_rocket') {
        // Launch rocket trails
        if (p.age % 0.03 < dt) {
          particles.add(Particle(
            position: p.position + const Offset(0, 15),
            velocity: Offset(RandomGenerator.doubleInRange(-0.8, 0.8), RandomGenerator.doubleInRange(1.5, 4.0)),
            color: RandomGenerator.randomColor([Colors.deepOrange, Colors.orangeAccent, Colors.yellow, Colors.grey]),
            shape: ConfettiShape.circle,
            size: RandomGenerator.doubleInRange(3.0, 7.0),
            lifetime: RandomGenerator.doubleInRange(0.4, 0.8),
            uniqueSeed: RandomGenerator.doubleInRange(0, 100),
            tag: 'smoke',
          ));
        }

        // Peak explosion
        if (p.position.dy < _canvasSize.height * 0.25 || p.velocity.dy >= -0.5) {
          deadParticles.add(p);
          _explodeFirework(p.position, p.color, isRocketExplosion: true);
        }
      } else if (p.tag == 'balloon') {
        // Float upwards
        p.velocity = Offset(p.velocity.dx, -1.5);
        p.position = Offset(
          p.position.dx + math.sin(p.age * 2 + p.uniqueSeed) * 0.5,
          p.position.dy + p.velocity.dy,
        );

        // Pop automatically when reaching upper half of screen
        final double popHeight = p.extra['popHeight'] ?? (_canvasSize.height * 0.3);
        if (p.position.dy < popHeight) {
          deadParticles.add(p);
          _explodeBalloon(p.position, p.color);
        }
      }

      // Check bounds
      final bool isOut = p.position.dy > _canvasSize.height + 100 ||
          p.position.dx < -100 ||
          p.position.dx > _canvasSize.width + 100;
          
      if (p.isDead || isOut) {
        deadParticles.add(p);
      }
    }

    particles.removeWhere((p) => deadParticles.contains(p));
  }

  // --- Particle Spawners ---

  void _spawnBurst(Offset center, int count, {ConfettiShape? shapeOverride}) {
    for (int i = 0; i < count; i++) {
      final angle = RandomGenerator.doubleInRange(0, 2 * math.pi);
      final speed = RandomGenerator.doubleInRange(options.minVelocity, options.maxVelocity);
      final shape = shapeOverride ?? RandomGenerator.randomShape(options.shapes);

      particles.add(Particle(
        position: center,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: RandomGenerator.randomColor(options.colors),
        shape: shape,
        size: RandomGenerator.doubleInRange(8, 16),
        rotation: RandomGenerator.doubleInRange(0, 2 * math.pi),
        angularVelocity: RandomGenerator.doubleInRange(-0.1, 0.1),
        lifetime: RandomGenerator.doubleInRange(2.0, 4.0),
        uniqueSeed: RandomGenerator.doubleInRange(0, 100),
        emoji: shape == ConfettiShape.emoji ? RandomGenerator.randomEmoji(options.emojis) : null,
      ));
    }
  }

  void _spawnCannon(Offset source, int count) {
    for (int i = 0; i < count; i++) {
      final angle = RandomGenerator.randomAngle(options.blastDirection, options.spread);
      final speed = RandomGenerator.doubleInRange(options.minVelocity * 1.5, options.maxVelocity * 1.8);
      final shape = RandomGenerator.randomShape(options.shapes);

      particles.add(Particle(
        position: source,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: RandomGenerator.randomColor(options.colors),
        shape: shape,
        size: RandomGenerator.doubleInRange(10, 18),
        rotation: RandomGenerator.doubleInRange(0, 2 * math.pi),
        angularVelocity: RandomGenerator.doubleInRange(-0.15, 0.15),
        lifetime: RandomGenerator.doubleInRange(3.0, 5.0),
        uniqueSeed: RandomGenerator.doubleInRange(0, 100),
        emoji: shape == ConfettiShape.emoji ? RandomGenerator.randomEmoji(options.emojis) : null,
      ));
    }
  }

  void _spawnRainDrop() {
    final x = RandomGenerator.doubleInRange(0, _canvasSize.width);
    final shape = RandomGenerator.randomShape(options.shapes);

    particles.add(Particle(
      position: Offset(x, -20),
      velocity: Offset(RandomGenerator.doubleInRange(-0.5, 0.5), RandomGenerator.doubleInRange(1.5, 3.5)),
      color: RandomGenerator.randomColor(options.colors),
      shape: shape,
      size: RandomGenerator.doubleInRange(8, 15),
      rotation: RandomGenerator.doubleInRange(0, 2 * math.pi),
      angularVelocity: RandomGenerator.doubleInRange(-0.05, 0.05),
      lifetime: RandomGenerator.doubleInRange(4.0, 6.0),
      uniqueSeed: RandomGenerator.doubleInRange(0, 100),
      emoji: shape == ConfettiShape.emoji ? RandomGenerator.randomEmoji(options.emojis) : null,
    ));
  }

  void _spawnMoneyBill() {
    final x = RandomGenerator.doubleInRange(0, _canvasSize.width);
    particles.add(Particle(
      position: Offset(x, -30),
      velocity: Offset(RandomGenerator.doubleInRange(-0.8, 0.8), RandomGenerator.doubleInRange(1.0, 2.5)),
      color: Colors.green.shade600,
      shape: ConfettiShape.money,
      size: RandomGenerator.doubleInRange(12, 22),
      rotation: RandomGenerator.doubleInRange(-0.3, 0.3),
      angularVelocity: RandomGenerator.doubleInRange(-0.03, 0.03),
      lifetime: RandomGenerator.doubleInRange(5.0, 7.0),
      uniqueSeed: RandomGenerator.doubleInRange(0, 100),
    ));
  }

  void _spawnWaveParticle() {
    final x = RandomGenerator.doubleInRange(0, _canvasSize.width);
    final shape = RandomGenerator.randomShape(options.shapes);

    particles.add(Particle(
      position: Offset(x, -20),
      velocity: Offset(0, RandomGenerator.doubleInRange(1.2, 2.5)),
      color: RandomGenerator.randomColor(options.colors),
      shape: shape,
      size: RandomGenerator.doubleInRange(8, 14),
      rotation: RandomGenerator.doubleInRange(0, 2 * math.pi),
      angularVelocity: RandomGenerator.doubleInRange(-0.04, 0.04),
      lifetime: RandomGenerator.doubleInRange(5.0, 7.0),
      uniqueSeed: RandomGenerator.doubleInRange(0, 100),
      emoji: shape == ConfettiShape.emoji ? RandomGenerator.randomEmoji(options.emojis) : null,
      extra: {
        'amplitude': RandomGenerator.doubleInRange(20.0, 45.0),
        'frequency': RandomGenerator.doubleInRange(2.5, 5.0),
        'baseDx': x,
      },
    ));
  }

  void _spawnSpiral(Offset center, int count) {
    for (int i = 0; i < count; i++) {
      final double startAngle = (i / count) * 2 * math.pi;
      particles.add(Particle(
        position: center,
        velocity: Offset.zero,
        color: RandomGenerator.randomColor(options.colors),
        shape: RandomGenerator.randomShape(options.shapes),
        size: RandomGenerator.doubleInRange(6, 12),
        rotation: RandomGenerator.doubleInRange(0, 2 * math.pi),
        angularVelocity: RandomGenerator.doubleInRange(-0.05, 0.05),
        lifetime: RandomGenerator.doubleInRange(3.0, 4.5),
        uniqueSeed: RandomGenerator.doubleInRange(0, 100),
        extra: {
          'center': center,
          'angle': startAngle,
          'radius': 0.0,
          'radialSpeed': RandomGenerator.doubleInRange(1.5, 3.5),
          'angularSpeed': RandomGenerator.doubleInRange(0.03, 0.08) * RandomGenerator.randomSign(),
        },
      ));
    }
  }

  void _spawnTrophyCelebration(Offset source, int count) {
    for (int i = 0; i < count; i++) {
      final angle = RandomGenerator.doubleInRange(-110 * math.pi / 180, -70 * math.pi / 180);
      final speed = RandomGenerator.doubleInRange(5.0, 11.0);
      final isTrophy = i % 2 == 0;

      particles.add(Particle(
        position: source,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: isTrophy ? Colors.amber : RandomGenerator.randomColor([Colors.amber, Colors.orangeAccent, Colors.yellow]),
        shape: ConfettiShape.trophy,
        size: RandomGenerator.doubleInRange(16, 26),
        rotation: RandomGenerator.doubleInRange(-0.5, 0.5),
        angularVelocity: RandomGenerator.doubleInRange(-0.08, 0.08),
        lifetime: RandomGenerator.doubleInRange(3.5, 5.0),
        uniqueSeed: RandomGenerator.doubleInRange(0, 100),
        emoji: isTrophy ? '🏆' : RandomGenerator.randomEmoji(['🥇', '🥈', '🥉', '✨', '👑']),
      ));
    }
  }

  void _spawnBalloons(int count) {
    for (int i = 0; i < count; i++) {
      final x = RandomGenerator.doubleInRange(_canvasSize.width * 0.1, _canvasSize.width * 0.9);
      final popHeight = RandomGenerator.doubleInRange(_canvasSize.height * 0.2, _canvasSize.height * 0.5);

      particles.add(Particle(
        position: Offset(x, _canvasSize.height + 40),
        velocity: const Offset(0, -1.5),
        color: RandomGenerator.randomColor([Colors.red, Colors.blue, Colors.orange, Colors.pink, Colors.purple, Colors.cyan]),
        shape: ConfettiShape.circle,
        size: RandomGenerator.doubleInRange(30, 45), // large balloon sizes
        lifetime: 8.0,
        uniqueSeed: RandomGenerator.doubleInRange(0, 100),
        tag: 'balloon',
        extra: {
          'popHeight': popHeight,
        },
      ));
    }
  }

  void _spawnFireworkRocket() {
    final x = RandomGenerator.doubleInRange(_canvasSize.width * 0.15, _canvasSize.width * 0.85);
    final velocityY = RandomGenerator.doubleInRange(-7.0, -12.0);
    final velocityX = RandomGenerator.doubleInRange(-1.5, 1.5);
    final color = RandomGenerator.randomColor([Colors.amber, Colors.redAccent, Colors.blueAccent, Colors.purpleAccent, Colors.pinkAccent]);

    particles.add(Particle(
      position: Offset(x, _canvasSize.height),
      velocity: Offset(velocityX, velocityY),
      color: color,
      shape: ConfettiShape.circle,
      size: 5.0,
      lifetime: 3.5,
      uniqueSeed: RandomGenerator.doubleInRange(0, 100),
      tag: 'rocket',
    ));
  }

  void _spawnLaunchRocket() {
    final x = RandomGenerator.doubleInRange(_canvasSize.width * 0.15, _canvasSize.width * 0.85);
    final velocityY = RandomGenerator.doubleInRange(-9.0, -14.0);

    particles.add(Particle(
      position: Offset(x, _canvasSize.height),
      velocity: Offset(0, velocityY),
      color: Colors.redAccent,
      shape: ConfettiShape.emoji,
      emoji: '🚀',
      size: 22.0,
      lifetime: 4.0,
      uniqueSeed: RandomGenerator.doubleInRange(0, 100),
      tag: 'launch_rocket',
    ));
  }

  void _spawnSparkleFromTrail() {
    // Sparkle trail emitter moves programmatically using Lissajous-like curve
    _sparklePathAngle += 0.08;
    final double cx = _canvasSize.width / 2;
    final double cy = _canvasSize.height * 0.4;
    final double rx = _canvasSize.width * 0.35;
    final double ry = _canvasSize.height * 0.25;

    final Offset emitterPos = Offset(
      cx + rx * math.cos(_sparklePathAngle),
      cy + ry * math.sin(_sparklePathAngle * 2),
    );

    // Spawn 2-4 sparkles at this location
    for (int i = 0; i < 3; i++) {
      final angle = RandomGenerator.doubleInRange(0, 2 * math.pi);
      final speed = RandomGenerator.doubleInRange(0.5, 2.0);

      particles.add(Particle(
        position: emitterPos,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed + 0.5),
        color: RandomGenerator.randomColor([Colors.amber, Colors.yellow, Colors.white, Colors.cyanAccent, Colors.pinkAccent]),
        shape: ConfettiShape.star,
        size: RandomGenerator.doubleInRange(4.0, 8.0),
        rotation: RandomGenerator.doubleInRange(0, 2 * math.pi),
        angularVelocity: RandomGenerator.doubleInRange(-0.1, 0.1),
        lifetime: RandomGenerator.doubleInRange(0.6, 1.2),
        uniqueSeed: RandomGenerator.doubleInRange(0, 100),
        tag: 'sparkle_trail',
      ));
    }
  }

  void _explodeFirework(Offset origin, Color baseColor, {bool isRocketExplosion = false}) {
    final int sparksCount = isRocketExplosion ? 60 : 40;
    for (int i = 0; i < sparksCount; i++) {
      final angle = RandomGenerator.doubleInRange(0, 2 * math.pi);
      final speed = RandomGenerator.doubleInRange(1.5, isRocketExplosion ? 7.0 : 5.0);
      final color = isRocketExplosion
          ? RandomGenerator.randomColor([Colors.redAccent, Colors.cyanAccent, Colors.yellowAccent, Colors.purpleAccent, Colors.greenAccent])
          : baseColor;

      particles.add(Particle(
        position: origin,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: color,
        shape: isRocketExplosion ? ConfettiShape.star : ConfettiShape.circle,
        size: RandomGenerator.doubleInRange(3.0, isRocketExplosion ? 8.0 : 6.0),
        lifetime: RandomGenerator.doubleInRange(1.0, 1.8),
        uniqueSeed: RandomGenerator.doubleInRange(0, 100),
        tag: 'spark',
      ));
    }
  }

  void _explodeBalloon(Offset origin, Color balloonColor) {
    // Burst of 20-30 particles
    for (int i = 0; i < 25; i++) {
      final angle = RandomGenerator.doubleInRange(0, 2 * math.pi);
      final speed = RandomGenerator.doubleInRange(1.5, 4.5);

      particles.add(Particle(
        position: origin,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: balloonColor,
        shape: RandomGenerator.randomShape([ConfettiShape.circle, ConfettiShape.square]),
        size: RandomGenerator.doubleInRange(6, 12),
        rotation: RandomGenerator.doubleInRange(0, 2 * math.pi),
        angularVelocity: RandomGenerator.doubleInRange(-0.08, 0.08),
        lifetime: RandomGenerator.doubleInRange(1.2, 2.0),
        uniqueSeed: RandomGenerator.doubleInRange(0, 100),
      ));
    }
  }

  /// Manually triggers a burst explosion at the given screen offset coordinates.
  void triggerManualExplosion(Offset position, {int count = 40}) {
    if (!_isPlaying && !_isPaused) {
      play();
    }
    _spawnBurst(position, count);
  }

  /// Manually triggers popping a balloon by checking coordinate proximity.
  /// Returns true if a balloon was popped.
  bool triggerBalloonPop(Offset tapPos) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      if (p.tag == 'balloon') {
        final dist = (p.position - tapPos).distance;
        if (dist <= p.size * 1.5) {
          particles.removeAt(i);
          _explodeBalloon(p.position, p.color);
          notifyListeners();
          return true;
        }
      }
    }
    return false;
  }
}
