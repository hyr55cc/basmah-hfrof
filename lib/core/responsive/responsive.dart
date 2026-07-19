import 'package:flutter/material.dart';

/// Responsive helper for sizing UI across devices
class Responsive {
  Responsive._();

  /// Get scaled font size based on screen width
  static double fontSize(BuildContext context, double size) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return size * 0.85;
    if (width < 400) return size * 0.9;
    if (width < 600) return size;
    if (width < 900) return size * 1.1;
    if (width < 1200) return size * 1.2;
    return size * 1.3;
  }

  /// Get scaled spacing
  static double spacing(BuildContext context, double value) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return value * 0.85;
    if (width < 400) return value * 0.9;
    if (width < 600) return value;
    if (width < 900) return value * 1.1;
    if (width < 1200) return value * 1.2;
    return value * 1.3;
  }

  /// Get scaled icon size
  static double iconSize(BuildContext context, double size) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return size;
    if (width < 900) return size * 1.15;
    return size * 1.3;
  }

  /// Get scaled radius
  static double radius(BuildContext context, double value) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return value;
    if (width < 900) return value * 1.2;
    return value * 1.4;
  }

  /// Value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200 && desktop != null) return desktop;
    if (width >= 600 && tablet != null) return tablet;
    return mobile;
  }

  /// Get the letter circle radius for the game
  static double gameCircleRadius(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 130;
    if (width < 400) return 145;
    if (width < 600) return 160;
    if (width < 900) return 200;
    return 240;
  }

  /// Get the letter widget size in the game circle
  static double gameLetterSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 56;
    if (width < 400) return 60;
    if (width < 600) return 64;
    if (width < 900) return 80;
    return 96;
  }
}
