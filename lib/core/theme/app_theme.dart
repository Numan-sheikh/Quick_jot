// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.seedLight,
      brightness: Brightness.light,
      surfaceTint:
          Colors.transparent, // Ensures no default tinting from ColorScheme
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor:
          Colors.transparent, // Make app bar background transparent
      foregroundColor:
          AppColors.lightOnPrimary, // Keep foreground color for icons/text
      elevation: 0, // Remove shadow for a flat, modern look
      systemOverlayStyle:
          SystemUiOverlayStyle
              .dark, // Ensures status bar icons are visible on a light background
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightSecondary,
      foregroundColor: AppColors.lightOnSecondary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // --- Modernized Card Theme for Light Mode ---
    cardTheme: CardThemeData(
      color: AppColors.lightSurface.withAlpha(229), // 90% opaque white
      elevation: 6, // Increased elevation for a more prominent floating effect
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Rounded corners for modern aesthetic
      shadowColor: Colors.grey.withAlpha(76), // 30% opaque (255 * 0.3 = 76.5)
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightSecondary,
        foregroundColor: AppColors.lightOnSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textTheme: _textTheme(AppColors.lightOnSurface),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.seedDark,
      brightness: Brightness.dark,
      surfaceTint:
          Colors.transparent, // Ensures no default tinting from ColorScheme
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor:
          Colors.transparent, // Make app bar background transparent
      foregroundColor:
          AppColors.darkOnPrimary, // Keep foreground color for icons/text
      elevation: 0, // Remove shadow for a flat, modern look
      systemOverlayStyle:
          SystemUiOverlayStyle
              .light, // Ensures status bar icons are visible on a dark background
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkSecondary,
      foregroundColor: AppColors.darkOnSecondary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // --- Modernized Card Theme for Dark Mode ---
    cardTheme: CardThemeData(
      color: AppColors.darkSurface.withAlpha(204), // 80% opaque dark grey
      elevation: 6, // Increased elevation for a more prominent floating effect
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Rounded corners for modern aesthetic
      shadowColor: Colors.black.withAlpha(102), // 40% opaque (255 * 0.4 = 102)
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkSecondary,
        foregroundColor: AppColors.darkOnSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textTheme: _textTheme(AppColors.darkOnSurface),
  );

  static TextTheme _textTheme(Color defaultColor) => TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: defaultColor,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: defaultColor,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: defaultColor,
    ),
    bodyLarge: GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: defaultColor,
    ),
    bodyMedium: GoogleFonts.openSans(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: defaultColor,
    ),
    bodySmall: GoogleFonts.openSans(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: defaultColor,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: defaultColor,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: defaultColor,
    ),
  );
}
// This code defines a custom theme for a Flutter application, including light and dark themes with modernized card styles, button styles, and text styles using Google Fonts. The themes are designed to provide a consistent and visually appealing user interface across the app.