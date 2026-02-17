import 'package:flutter/material.dart';

class AppColors {
  // Green & White Theme
  static const Color primaryGreen = Color(0xFF2E7D32); // Professional Green
  static const Color scaffoldWhite = Color(0xFFF5F5F5); // Light Grey/White
  static const Color textBlack = Color(0xFF212121);
  static const Color textGrey = Color(0xFF757575);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color iconGrey = Color(0xFF9E9E9E);

  // Keep legacy for safety but map them to new theme
  static const Color igBlack = scaffoldWhite;
  static const Color igDarkGrey = inputFill;
  static const Color igGrey = Color(0xFFE0E0E0);
  static const Color igWhite = textBlack;
  static const Color igSecondaryText = textGrey;
  static const Color igButtonGrey = Color(0xFFEEEEEE);

  static const Color candyAppleRed = primaryGreen; // Map Red to Green

  // RGB Gradient - map to Green Gradient for consistency
  static const LinearGradient rgbGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
