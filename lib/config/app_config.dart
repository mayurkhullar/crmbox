import 'package:flutter/material.dart';

class AppConfig {
  static const companyName = 'K. Holiday Maps';

  // --- Main Colors ---
  static const Color primaryColor = Color(0xFF54627A); // Muted Indigo
  static const Color primaryLight = Color(0xFF8A99B3); // Muted Blue Grey
  static const Color primaryDark = Color(0xFF384052); // Dusty Navy

  // --- Accent Colors ---
  static const Color accentColor = Color(0xFFE4B363); // Muted Gold
  static const Color accentBlue = Color(0xFFB7D4E7); // Powder Blue
  static const Color accentCoral = Color(0xFFD18F88); // Dusty Coral

  // --- Background & Surfaces ---
  static const Color backgroundColor = Color(0xFFF7F7FA); // Mist Grey
  static const Color surfaceColor = Color(0xFFFFFFFF); // Cloud White
  static const Color cardColor = surfaceColor;
  static const Color dividerColor = Color(0xFFE3E4EA); // Ash Grey

  // --- Text Colors ---
  static const Color textMain = Color(0xFF30333A); // Charcoal
  static const Color textMuted = Color(0xFF838A95); // Muted Blue Grey

  // --- Status Colors ---
  static const Color success = Color(0xFF71B09C); // Soft Green
  static const Color warning = accentColor; // Muted Gold
  static const Color danger = Color(0xFFC15662); // Soft Red

  // --- Spacing ---
  static const double spacing = 16.0;
  static const double spacingSmall = 8.0;
  static const double spacingLarge = 24.0;

  // --- Border Radius ---
  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 12.0;

  // --- Shadows ---
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
}
