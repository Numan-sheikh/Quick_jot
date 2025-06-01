// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Seed colors for Material 3 theming
  static const Color seedLight = Color(0xFF4B5DFF); // Modern Indigo
  static const Color seedDark = Color(0xFF6C70FF); // Soft Neon Indigo

  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF4B5DFF);
  static const Color lightOnPrimary = Colors.white;
  static const Color lightSecondary = Color(0xFF00C2A8);
  static const Color lightOnSecondary = Colors.white;
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1C1C1E);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1C1C1E);
  static const Color lightError = Color(0xFFFF6B6B);
  static const Color lightOnError = Colors.white;

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF6C70FF);
  static const Color darkOnPrimary = Colors.white;
  static const Color darkSecondary = Color(0xFF00E6C3);
  static const Color darkOnSecondary = Colors.black;
  static const Color darkBackground = Color(0xFF000000); // Pure black
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  // Adjusted darkSurface to be a bit lighter for better visual distinction from background
  static const Color darkSurface = Color(0xFF1D1D1D);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkError = Color(0xFFFF7070);
  static const Color darkOnError = Colors.black;
}
