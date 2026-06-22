/// A production-ready celebration and particle animation engine for Flutter
/// containing multiple confetti effects inside a single package.
library flutter_confetti_master;

// Export Models
export 'src/models/confetti_shape.dart' show ConfettiShape;
export 'src/models/confetti_options.dart' show ConfettiOptions;
export 'src/models/particle.dart' show Particle;

// Export Controllers
export 'src/controllers/confetti_controller.dart' show ConfettiController, ConfettiEffect;

// Export Widgets
export 'src/widgets/confetti_widget.dart' show ConfettiMaster, ConfettiWidget;
export 'src/widgets/cannon_widget.dart' show CannonWidget;
export 'src/widgets/fireworks_widget.dart' show FireworksWidget;
export 'src/widgets/rain_widget.dart' show RainWidget;
