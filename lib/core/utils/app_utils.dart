// lib/core/utils/app_utils.dart

import 'package:flutter/material.dart';

class AppUtils {
  /// Applies opacity to a given [Color].
  ///
  /// [color]: The original color.
  /// [opacity]: The desired opacity (0.0 to 1.0).
  static Color applyOpacity(Color color, double opacity) {
    // Calculate the new alpha value by multiplying original alpha by opacity.
    final int newAlpha = (color.a * opacity).round().clamp(0, 255);

    // Reconstruct the color using the new alpha and original RGB components.
    return Color.fromARGB(newAlpha, color.r.round(), color.g.round(), color.b.round());
  }

  /// Builds and returns a SnackBar widget.
  /// This method creates the SnackBar but does not display it.
  ///
  /// [message]: The text message to display in the SnackBar.
  /// [isError]: Optional boolean to indicate if the SnackBar should display an error style.
  static SnackBar buildSnackBar(String message, {bool isError = false}) {
    return SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
  }

  /// Shows a SnackBar at the bottom of the screen.
  ///
  /// [context]: The BuildContext from which to show the SnackBar.
  /// [message]: The text message to display in the SnackBar.
  /// [isError]: Optional boolean to indicate if the SnackBar should display an error style.
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    // Check if the context is still mounted.
    if (!context.mounted) {
      return;
    }

    // Determine the background color based on the isError flag.
    final Color snackBarBackgroundColor =
        isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary;

    // Determine the text color for readability against the background.
    final Color snackBarTextColor =
        isError
            ? Theme.of(context).colorScheme.onError
            : Theme.of(context).colorScheme.onSecondary;

    // Hide any currently visible SnackBar.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // Show a new SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: snackBarTextColor)),
        backgroundColor: snackBarBackgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
