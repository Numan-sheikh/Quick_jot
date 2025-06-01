// lib/core/utils/app_utils.dart

import 'package:flutter/material.dart';

class AppUtils {
  /// Applies opacity to a given [Color] using Color.fromARGB.
  static Color applyOpacity(Color color, double opacity) {
    // Use 'color.a', 'color.r', 'color.g', 'color.b' as per deprecation warnings.
    final int newAlpha = (color.a * opacity).round();
    return Color.fromARGB(
      newAlpha.clamp(0, 255), // Ensure alpha is within 0-255 range
      color.r as int, // Corrected: use .r
      color.g as int, // Corrected: use .g
      color.b as int, // Corrected: use .b
    );
  }

  // You can add other general utility functions here, e.g.,
  // static void showSnackBar(BuildContext context, String message) { ... }
}
