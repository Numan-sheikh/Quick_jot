import 'dart:math';
import 'package:flutter/material.dart';

class OrbPainter extends CustomPainter {
  final double progress;
  final bool isDark; // This will no longer affect orb color, but keeping it
  final List<Offset> orbCenters = [
    Offset(100, 150),
    Offset(250, 300),
    Offset(180, 500),
    Offset(80, 400),
    Offset(300, 200),
  ];

  OrbPainter(this.progress, {required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < orbCenters.length; i++) {
      // Calculate the animated position for each orb
      final offset = Offset(
        orbCenters[i].dx + sin(progress * 2 * pi + i) * 15,
        orbCenters[i].dy + cos(progress * 2 * pi + i) * 15,
      );

      // Define the yellow gradient for the glow
      final gradient = RadialGradient(
        colors: [
          // Brighter yellow/gold in the center with some transparency
          const Color.fromARGB(
            255,
            7,
            238,
            255,
          ).withAlpha(40), // Increased alpha slightly for more visibility
          // Softer yellow/orange fading out
          const Color.fromARGB(
            255,
            245,
            34,
            234,
          ).withAlpha(20), // Increased alpha slightly
          // Fully transparent outer edge
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0], // Define where each color stop is
        radius: 0.5, // Increased radius slightly for a wider spread
      );

      final paint =
          Paint()
            ..shader = gradient.createShader(
              Rect.fromCircle(center: offset, radius: 80),
            )
            ..blendMode =
                BlendMode.plus; // Use blendMode.plus for a glowing effect

      // Draw the circle using the gradient as a shader
      canvas.drawCircle(offset, 80, paint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) {
    // Repaint if the animation progress changes
    return oldDelegate.progress != progress;
  }
}
