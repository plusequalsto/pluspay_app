import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF2B2B2B); // Dark Gray
  static const Color accentColor = Color(0xFFCD182C); // Red
  static const Color backgroundColor = Color(0xFFFAFAFA); // Light Gray/White

  // Text Colors
  static const Color textPrimary = backgroundColor; // Primary Text Color
  static const Color textSecondary = primaryColor; // Secondary Text Color
  static const Color textTertiary = accentColor; // Tertiary Text Color
  static const Color textLink = accentColor; // Link Text Color
  static const Color textInverse =
      Colors.white; // Inverse Text Color for dark backgrounds
  static const Color subText = Color(0xFFA9A9A9);

  // Shadow Colors
  static const Color shadowLight = Color(0xFFEDEDED); // Light Shadow
  static const Color shadowDark = Color(0x4D000000); // Darker Shadow

  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0); // Light Gray for Borders

  // Additional Colors
  static const Color warningColor = Color(0xFFFFC107); // Amber for warnings
  static const Color successColor =
      Color(0xFF28A745); // Green for success messages
  static const Color errorColor = Color(0xFFCD182C); // Red for error messages
  static const Color infoColor =
      Color(0xFF17A2B8); // Blue for informational messages

  // Optional: Define your shades if needed
  static const Color primaryColorLight =
      Color(0xFF4F4F4F); // Light shade of primary color
  static const Color primaryColorDark =
      Color(0xFF1F1F1F); // Dark shade of primary color
}
