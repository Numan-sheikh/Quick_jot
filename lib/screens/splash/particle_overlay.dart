import 'dart:math';
import 'package:flutter/material.dart';

// Helper class to hold the properties of a single firefly particle
class FireflyParticle {
  Offset position;
  double radius;
  int initialAlpha; // Max brightness for this particle
  double twinklePhase; // To make them twinkle at different times

  FireflyParticle({
    required this.position,
    required this.radius,
    required this.initialAlpha,
    required this.twinklePhase,
  });
}

class ParticleOverlay extends StatefulWidget {
  const ParticleOverlay({super.key});

  @override
  ParticleOverlayState createState() => ParticleOverlayState();
}

class ParticleOverlayState extends State<ParticleOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<FireflyParticle> _particles = [];
  final Random _random = Random();
  final int numberOfParticles = 150; // Increased number of fireflies

  @override
  void initState() {
    super.initState();

    // Controller for driving the animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 5,
      ), // Duration for one complete twinkle cycle
    )..repeat(); // Repeat the animation indefinitely

    // Generate particles after the layout is built to get the size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateParticles();
    });
  }

  // Generate the initial positions and properties for the fireflies
  void _generateParticles() {
    final size = context.size;
    if (size == null || size.isEmpty) {
      return;
    }

    for (int i = 0; i < numberOfParticles; i++) {
      final dx = _random.nextDouble() * size.width;
      final dy = _random.nextDouble() * size.height;
      // Increased random radius between 1.0 and 3.0
      final radius = _random.nextDouble() * 2.0 + 1.0;
      // Increased random initial alpha (max brightness) between 55 and 255
      final initialAlpha = _random.nextInt(200) + 55;
      // Random phase for the sine wave to desynchronize twinkling
      final twinklePhase = _random.nextDouble() * 2 * pi;

      _particles.add(
        FireflyParticle(
          position: Offset(dx, dy),
          radius: radius,
          initialAlpha: initialAlpha,
          twinklePhase: twinklePhase,
        ),
      );
    }
    // Rebuild the widget to paint the generated particles
    setState(() {}); // Trigger a build after particles are generated
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder to rebuild only the CustomPaint when the animation value changes
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // If particles haven't been generated yet, return an empty box
        if (_particles.isEmpty) {
          // We should ideally not paint if particles aren't ready,
          // but addPostFrameCallback ensures they are generated before the first animated frame.
          // A more robust solution might involve listening to size changes if the widget can resize.
          return const SizedBox.expand();
        }
        return CustomPaint(
          painter: _FireflyPainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FireflyPainter extends CustomPainter {
  final List<FireflyParticle> particles;
  final double
  animationValue; // Value from 0.0 to 1.0 from the animation controller

  _FireflyPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw each particle based on its properties and the current animation state
    for (final particle in particles) {
      // Calculate the current alpha using a sine wave for twinkling effect
      // The sine wave goes from -1 to 1. We shift and scale it to go from 0 to 1.
      // Then multiply by the particle's initialAlpha for its brightness range.
      final currentAlphaDouble =
          (sin(animationValue * 2 * pi + particle.twinklePhase) + 1) /
          2 *
          particle.initialAlpha;

      // Ensure the alpha is an integer between 0 and 255
      final currentAlpha = currentAlphaDouble.toInt().clamp(0, 255);

      // Only draw if the particle is visible
      if (currentAlpha > 0) {
        final paint =
            Paint()
              // Changed color to lightBlueAccent and used the calculated alpha
              ..color = Colors.lightBlueAccent.withAlpha(currentAlpha)
              ..maskFilter = const MaskFilter.blur(
                BlurStyle.normal,
                2.0,
              ); // Keep the blur for glow

        canvas.drawCircle(particle.position, particle.radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireflyPainter oldDelegate) {
    // Repaint if the animation value changes (driven by AnimatedBuilder)
    // or if the list of particles changes (not changing in this example after init)
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.particles != particles;
  }
}
