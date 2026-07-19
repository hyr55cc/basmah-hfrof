import 'package:flutter/material.dart';

/// App-wide color palette
/// Modern, premium design with glassmorphism and elegant gradients
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF3F3D9C);

  // Secondary / accent
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFF8FA3);
  static const Color secondaryDark = Color(0xFFCC4D69);

  // Tertiary
  static const Color tertiary = Color(0xFF00D4AA);
  static const Color tertiaryLight = Color(0xFF4DDFC2);
  static const Color tertiaryDark = Color(0xFF00A88A);

  // Game / coins
  static const Color gold = Color(0xFFFFC93C);
  static const Color goldLight = Color(0xFFFFD970);
  static const Color goldDark = Color(0xFFD4A100);

  // Status
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFA53D);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3FC1F0);

  // Letter states
  static const Color letterDefault = Color(0xFFFFFFFF);
  static const Color letterSelected = Color(0xFF6C63FF);
  static const Color letterFound = Color(0xFF00C48C);
  static const Color letterHint = Color(0xFFFFC93C);
  static const Color letterWrong = Color(0xFFE74C3C);
  static const Color letterBonus = Color(0xFFFF6584);

  // Backgrounds - Light
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Backgrounds - Dark
  static const Color backgroundDark = Color(0xFF0F0E17);
  static const Color surfaceDark = Color(0xFF1A1925);
  static const Color cardDark = Color(0xFF252334);

  // Text
  static const Color textPrimaryLight = Color(0xFF0F0E17);
  static const Color textSecondaryLight = Color(0xFF6E6C7E);
  static const Color textDisabledLight = Color(0xFFB5B3C5);

  static const Color textPrimaryDark = Color(0xFFFFFEFF);
  static const Color textSecondaryDark = Color(0xFFB5B3C5);
  static const Color textDisabledDark = Color(0xFF6E6C7E);

  // Borders
  static const Color borderLight = Color(0xFFE5E4F0);
  static const Color borderDark = Color(0xFF2D2C3D);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFF8FA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFC93C), Color(0xFFFFD970)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFF8F9FE), Color(0xFFEDE9FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF0F0E17), Color(0xFF1A1925)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFFC93C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism overlay
  static Color glassLight = Colors.white.withOpacity(0.6);
  static Color glassDark = Colors.white.withOpacity(0.08);
  static Color glassBorderLight = Colors.white.withOpacity(0.8);
  static Color glassBorderDark = Colors.white.withOpacity(0.15);
}
