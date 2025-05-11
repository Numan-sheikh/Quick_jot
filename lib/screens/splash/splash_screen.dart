import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:animated_text_kit/animated_text_kit.dart';
import 'orb_painter.dart';
import 'particle_overlay.dart';
import 'package:quickjot/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 2), () {
      // Check if the widget is still mounted before using the BuildContext
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (_, __, ___) => const HomeScreen(), // Replace with HomePage()
          transitionsBuilder: (_, animation, __, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 0.5).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(
            milliseconds: 500,
          ), // Balanced speed
        ),
      );
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors =
        isDark
            ? [
              const Color(0xFF0c0118),
              const Color(0xFF1d023a),
              const Color(0xFF2b0455),
              const Color(0xFF380570),
              const Color(0xFF46068c),
              const Color(0xFF5707ad),
            ]
            : [
              const Color(0xFFe3d5f6),
              const Color(0xFFcbb6f0),
              const Color(0xFFb49adc),
              const Color(0xFFa185cb),
              const Color(0xFF8f71b9),
              const Color(0xFF7b5ca8),
            ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _orbController,
            builder:
                (_, __) => CustomPaint(
                  painter: OrbPainter(_orbController.value, isDark: isDark),
                  child: const SizedBox.expand(),
                ),
          ),
          const Positioned.fill(child: ParticleOverlay()),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutExpo,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: const Text(
                'QUICK JOT',
                style: TextStyle(
                  shadows: [
                    Shadow(
                      blurRadius: 30,
                      color: Color.fromARGB(
                        117,
                        255,
                        0,
                        0,
                      ), // The color is defined here
                      offset: Offset(0, 0),
                    ),
                  ],

                  fontSize: 48,
                  fontFamily:
                      'Montserrat', // Use 'Gotham' if available or custom
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 130, 243, 234),
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
