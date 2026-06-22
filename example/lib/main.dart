import 'package:flutter/material.dart';
import 'package:flutter_confetti_master/flutter_confetti_master.dart';

void main() {
  runApp(const ConfettiShowcaseApp());
}

class ConfettiShowcaseApp extends StatelessWidget {
  const ConfettiShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confetti Master Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const ConfettiShowcaseScreen(),
    );
  }
}

class ConfettiShowcaseScreen extends StatefulWidget {
  const ConfettiShowcaseScreen({super.key});

  @override
  State<ConfettiShowcaseScreen> createState() => _ConfettiShowcaseScreenState();
}

class _ConfettiShowcaseScreenState extends State<ConfettiShowcaseScreen> {
  // Current settings
  ConfettiEffect _selectedEffect = ConfettiEffect.fireworks;
  double _particleCount = 100.0;
  double _gravity = 0.15;
  double _minVelocity = 2.0;
  double _maxVelocity = 8.0;
  bool _loop = true;
  Duration? _duration;

  // Controller
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = ConfettiController(
      effect: _selectedEffect,
      options: _buildOptions(),
      duration: _duration,
      autoPlay: true,
    );
  }

  ConfettiOptions _buildOptions() {
    return ConfettiOptions(
      particleCount: _particleCount.toInt(),
      gravity: _gravity,
      minVelocity: _minVelocity,
      maxVelocity: _maxVelocity,
      loop: _loop,
      colors: const [
        Colors.pinkAccent,
        Colors.purpleAccent,
        Colors.blueAccent,
        Colors.cyanAccent,
        Colors.yellowAccent,
        Colors.orangeAccent,
      ],
      shapes: const [
        ConfettiShape.circle,
        ConfettiShape.square,
        ConfettiShape.triangle,
        ConfettiShape.star,
        ConfettiShape.heart,
      ],
    );
  }

  void _applySettings() {
    setState(() {
      _controller.options = _buildOptions();
      _controller.replay();
    });
  }

  void _changeEffect(ConfettiEffect effect) {
    setState(() {
      _selectedEffect = effect;
      
      // Load typical defaults for selected effect
      switch (effect) {
        case ConfettiEffect.burst:
          _particleCount = 80;
          _gravity = 0.15;
          _minVelocity = 3.0;
          _maxVelocity = 9.0;
          _loop = false;
          _duration = const Duration(seconds: 3);
          break;
        case ConfettiEffect.cannon:
          _particleCount = 100;
          _gravity = 0.22;
          _minVelocity = 9.0;
          _maxVelocity = 17.0;
          _loop = false;
          _duration = const Duration(seconds: 4);
          break;
        case ConfettiEffect.rain:
          _particleCount = 120;
          _gravity = 0.08;
          _minVelocity = 1.0;
          _maxVelocity = 3.2;
          _loop = true;
          _duration = null;
          break;
        case ConfettiEffect.moneyRain:
          _particleCount = 50;
          _gravity = 0.05;
          _minVelocity = 0.8;
          _maxVelocity = 2.0;
          _loop = true;
          _duration = null;
          break;
        case ConfettiEffect.fireworks:
          _particleCount = 60;
          _gravity = 0.16;
          _minVelocity = 2.0;
          _maxVelocity = 5.0;
          _loop = true;
          _duration = null;
          break;
        case ConfettiEffect.rocketLaunch:
          _particleCount = 18;
          _gravity = 0.13;
          _minVelocity = 1.2;
          _maxVelocity = 3.8;
          _loop = true;
          _duration = null;
          break;
        case ConfettiEffect.stars:
          _particleCount = 70;
          _gravity = 0.12;
          _minVelocity = 2.5;
          _maxVelocity = 7.5;
          _loop = false;
          _duration = const Duration(seconds: 3);
          break;
        case ConfettiEffect.hearts:
          _particleCount = 60;
          _gravity = 0.09;
          _minVelocity = 1.5;
          _maxVelocity = 4.0;
          _loop = false;
          _duration = const Duration(seconds: 3);
          break;
        case ConfettiEffect.emoji:
          _particleCount = 50;
          _gravity = 0.11;
          _minVelocity = 2.0;
          _maxVelocity = 6.0;
          _loop = false;
          _duration = const Duration(seconds: 3);
          break;
        case ConfettiEffect.spiral:
          _particleCount = 90;
          _gravity = 0.0;
          _minVelocity = 0.0;
          _maxVelocity = 0.0;
          _loop = false;
          _duration = const Duration(seconds: 4);
          break;
        case ConfettiEffect.wave:
          _particleCount = 85;
          _gravity = 0.07;
          _minVelocity = 1.0;
          _maxVelocity = 2.5;
          _loop = true;
          _duration = null;
          break;
        case ConfettiEffect.trophy:
          _particleCount = 35;
          _gravity = 0.18;
          _minVelocity = 6.0;
          _maxVelocity = 11.0;
          _loop = false;
          _duration = const Duration(seconds: 3);
          break;
        case ConfettiEffect.balloonBurst:
          _particleCount = 8;
          _gravity = 0.1;
          _minVelocity = 1.0;
          _maxVelocity = 2.0;
          _loop = true;
          _duration = null;
          break;
        case ConfettiEffect.sparkleTrail:
          _particleCount = 140;
          _gravity = 0.04;
          _minVelocity = 0.5;
          _maxVelocity = 1.8;
          _loop = true;
          _duration = null;
          break;
        default:
          break;
      }
      
      _controller.dispose();
      _initController();
    });
  }

  String _getEffectDescription(ConfettiEffect effect) {
    switch (effect) {
      case ConfettiEffect.burst:
        return 'Explosion Burst: Colorful shapes bursting outwards from the center.';
      case ConfettiEffect.cannon:
        return 'Cannon Shot: High-speed spray shot upwards from the bottom.';
      case ConfettiEffect.rain:
        return 'Rain Confetti: Endless gentle rain falling from top to bottom.';
      case ConfettiEffect.fireworks:
        return 'Fireworks: Rising rockets that explode at the peak into colorful sparks.';
      case ConfettiEffect.stars:
        return 'Star Confetti: Shiny 5-pointed stars floating and spinning.';
      case ConfettiEffect.hearts:
        return 'Heart Confetti: Floating hearts, perfect for romantic events.';
      case ConfettiEffect.emoji:
        return 'Emoji Confetti: Fun emojis drifting around the viewport.';
      case ConfettiEffect.spiral:
        return 'Spiral Motion: Swirling vortex of particles expanding from a point.';
      case ConfettiEffect.wave:
        return 'Wave Motion: Particles oscillating side-to-side like paper in breeze.';
      case ConfettiEffect.particles:
        return 'Advanced Particles: Customizable physics sandbox.';
      case ConfettiEffect.moneyRain:
        return 'Money Rain: Stacked green bills tumbling down in 3D rotation.';
      case ConfettiEffect.balloonBurst:
        return 'Balloon Burst: Floating balloons. TAP on a balloon to pop it!';
      case ConfettiEffect.sparkleTrail:
        return 'Sparkle Trail: Twinkling stars trailing a moving orbital emitter.';
      case ConfettiEffect.trophy:
        return 'Trophy Celebration: Gold trophies and champion medals blasting upwards.';
      case ConfettiEffect.rocketLaunch:
        return 'Rocket Launch: 🚀 rockets taking off with flame smoke trails and peak fireworks.';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background color scheme
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Main Center Visual Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedEffect == ConfettiEffect.balloonBurst ? Icons.touch_app : Icons.auto_awesome,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedEffect.name.toUpperCase(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _getEffectDescription(_selectedEffect),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_selectedEffect == ConfettiEffect.balloonBurst)
                  Text(
                    'TAP THE FLOATING BALLOONS!',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    'TAP ANYWHERE TO SPAWN EXTRA PARTICLES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // Confetti Overlay Layer
          Positioned.fill(
            child: ConfettiMaster(
              effect: _selectedEffect,
              controller: _controller,
            ),
          ),

          // Top Header bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONFETTI MASTER',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                    Text(
                      'Celebration & Particle Physics Engine',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => _controller.replay(),
                      tooltip: 'Replay animation',
                    ),
                    const SizedBox(width: 8),
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        final playing = _controller.isPlaying;
                        return IconButton.filled(
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            if (playing) {
                              _controller.pause();
                            } else {
                              if (_controller.isPaused) {
                                _controller.resume();
                              } else {
                                _controller.play();
                              }
                            }
                            setState(() {});
                          },
                          tooltip: playing ? 'Pause' : 'Play',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Sheet Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.0,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Effect Chips Selector
                    const Text(
                      'SELECT CELEBRATION EFFECT',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: ConfettiEffect.values.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final effect = ConfettiEffect.values[index];
                          final isSelected = effect == _selectedEffect;
                          return ChoiceChip(
                            label: Text(effect.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                _changeEffect(effect);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24, thickness: 0.5),

                    // Tuning Sliders
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PARTICLE COUNT: ${_particleCount.toInt()}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              Slider(
                                value: _particleCount,
                                min: 5,
                                max: 300,
                                onChanged: (val) {
                                  setState(() {
                                    _particleCount = val;
                                  });
                                  _controller.options = _buildOptions();
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GRAVITY: ${_gravity.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              Slider(
                                value: _gravity,
                                min: 0.0,
                                max: 0.8,
                                onChanged: (val) {
                                  setState(() {
                                    _gravity = val;
                                  });
                                  _controller.options = _buildOptions();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VELOCITY: ${_minVelocity.toStringAsFixed(1)} - ${_maxVelocity.toStringAsFixed(1)}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              RangeSlider(
                                values: RangeValues(_minVelocity, _maxVelocity),
                                min: 0.0,
                                max: 25.0,
                                onChanged: (val) {
                                  setState(() {
                                    _minVelocity = val.start;
                                    _maxVelocity = val.end;
                                  });
                                  _controller.options = _buildOptions();
                                },
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'LOOP EFFECT',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            Switch(
                              value: _loop,
                              onChanged: (val) {
                                setState(() {
                                  _loop = val;
                                });
                                _controller.options = _buildOptions();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _applySettings,
                        icon: const Icon(Icons.bolt),
                        label: const Text('RE-TRIGGER BLAST'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
