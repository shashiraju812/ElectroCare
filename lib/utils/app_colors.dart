import 'package:flutter/material.dart';

class AppColors {
  // Electrical/Industrial Theme
  static const Color primaryBlue = Color(0xFF1A237E); // Deep Indigo/Blue
  static const Color accentAmber = Color(0xFFFFC107); // Electric Amber
  static const Color scaffoldBackground = Color(0xFFF5F7FA); // Light Blue-Grey
  static const Color cardWhite = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF263238); // Blue Grey 900
  static const Color textGrey = Color(0xFF78909C); // Blue Grey 400
  static const Color successGreen = Color(0xFF43A047);
  static const Color errorRed = Color(0xFFE53935);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFFCA28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy mappings for backward compatibility during refactor
  // Use these cautiously and replace with improved names where possible
  static const Color primaryGreen = primaryBlue;
  static const Color scaffoldWhite = scaffoldBackground;
  static const Color textBlack = textDark;

  // Mapping old IG colors to new theme to prevent breaks,
  // but these should be phased out.
  static const Color igBlack = scaffoldBackground;
  static const Color igWhite = textDark;
  static const Color igGrey = Color(0xFFCFD8DC);
  static const Color igSecondaryText = textGrey;
  static const Color candyAppleRed = primaryBlue;
}
