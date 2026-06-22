# flutter_confetti_master

[![pub package](https://img.shields.io/pub/v/flutter_confetti_master.svg)](https://pub.dev/packages/flutter_confetti_master)
[![license](https://img.shields.io/github/license/brijeshkumar/flutter_confetti_master.svg)](https://github.com/brijeshkumar/flutter_confetti_master/blob/master/LICENSE)

A production-ready, high-performance celebration and particle animation engine for Flutter. Contains 15 distinct confetti and celebration effects out of the box with zero external dependencies. Optimized to run at 60 FPS across Mobile, Web, and Desktop.

---

## Features

* **15 Built-in Effects**: Explosion Burst, Cannon Shot, Rain, Fireworks, Stars, Hearts, Emojis, Spiral, Wave, Advanced Particles, Money Rain, Balloon Burst, Sparkle Trail, Trophy Celebration, and Rocket Launch.
* **Granular Controls**: Play, Pause, Resume, Stop, Loop, and Replay controls.
* **Physics Simulation**: Custom gravity, drag, velocity vectors, and 3D tumbling (flip oscillations).
* **Interactive Gestures**: Tap gestures to pop balloons or trigger manual blast explosions in real-time.
* **Overlay Support**: Wrap any widget to display beautiful, high-fps celebrations on top.
* **Null Safe & Material 3 Compatible**: Ready for modern Flutter apps.

---

## Getting Started

### Installation

Add `flutter_confetti_master` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_confetti_master: ^1.0.0
```

Run:
```bash
flutter pub get
```

---

## Supported Effects

| Effect | Description |
| :--- | :--- |
| `burst` | Radial circular explosion of colorful shapes from the center. |
| `cannon` | High-velocity spray shot upwards at an angle from bottom corners. |
| `rain` | Continuous falling confetti drifting downwards. |
| `fireworks` | Rising rockets that detonate at their peak into secondary colorful spark explosions. |
| `stars` | Swirling and tumbling 5-pointed metallic star foil. |
| `hearts` | Softly falling red and pink hearts, perfect for romantic celebrations. |
| `emoji` | Drifting emoji characters (🎉, 🥳, 🌟, ❤️) that fade out. |
| `spiral` | Swirling vortex expanding outwards from a central point. |
| `wave` | Fluttering, swaying motion imitating paper drifting in wind. |
| `particles` | Advanced configurable particle physics sandbox. |
| `moneyRain` | Tumbling green dollar bills falling in 3D rotation. |
| `balloonBurst` | Interactive floating balloons. Tap to POP them into mini bursts. |
| `sparkleTrail` | Twinkling stars trailing behind a programmatic orbital emitter. |
| `trophy` | Blasting trophies (🏆) and gold medals (🥇, 🥈) shooting upwards. |
| `rocketLaunch` | Launching rockets (🚀) leaving smoke trails that explode into starbursts. |

---

## Usage

### Simple Quickstart

To run an effect automatically, overlay `ConfettiMaster` on top of your layout:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_confetti_master/flutter_confetti_master.dart';

class MyCelebrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConfettiMaster(
        effect: ConfettiEffect.fireworks,
        particleCount: 100,
        autoPlay: true,
        duration: Duration(seconds: 4), // stop emitting after 4 seconds
      ),
    );
  }
}
```

### Advanced Manual Controls

Use `ConfettiController` to play, pause, or trigger bursts programmatically (e.g. upon user success or completing a level):

```dart
class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      effect: ConfettiEffect.cannon,
      options: ConfettiOptions(
        loop: false,
        minVelocity: 8.0,
        maxVelocity: 15.0,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLevelComplete() {
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _onLevelComplete,
              child: Text('Complete Level!'),
            ),
          ),
          // Overlay celebration
          Positioned.fill(
            child: ConfettiMaster(
              effect: ConfettiEffect.cannon,
              controller: _controller,
              autoPlay: false,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## API Documentation

### ConfettiMaster Properties

* `effect`: The active `ConfettiEffect` enum value.
* `options`: An optional `ConfettiOptions` object to configure physics and shapes.
* `colors`: List of custom colors for the particles.
* `particleCount`: The number of particles.
* `autoPlay`: Whether the animation starts automatically (defaults to `true`).
* `duration`: How long the animation emits particles.
* `controller`: An optional custom `ConfettiController`.
* `child`: Optional child widget to draw confetti on top of.

### ConfettiOptions Properties

* `colors`: Array of colors (defaults to 8 vibrant colors).
* `gravity`: Pull force (defaults to `0.15`).
* `minVelocity` / `maxVelocity`: Velocity bounds (defaults to `2.0` / `8.0`).
* `minScale` / `maxScale`: 3D width scale limits.
* `particleCount`: Total count (defaults to `80`).
* `shapes`: Active shapes (Circle, Square, Triangle, Star, Heart, Emoji, Money).
* `emojis`: List of emoji strings.
* `blastDirection`: Emission angle in radians.
* `spread`: Emission spread angle in radians.
* `drag`: Air resistance (defaults to `0.98`).
* `loop`: Loop continuous generation.
* `blastPosition`: Absolute emitter origin offset coordinate.

---

## Performance Optimizations

1. **Repaint Boundaries**: The engine automatically wraps canvas paints in `RepaintBoundary` objects. This separates the animation repaint tree from the rest of the application layout, protecting UI render times.
2. **Dynamic Disposal**: Memory is conserved by automatically destroying and garbage collecting particles that fall outside viewport bounds.
3. **No Heavy Text Layouts**: Opacity and scale flips are calculated during ticks rather than using expensive widgets, guaranteeing high performance.
