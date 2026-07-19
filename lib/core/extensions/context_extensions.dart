import 'package:flutter/material.dart';

/// Context extension to get screen size, theme, etc.
extension ContextExtensions on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Is small device (less than 360 dp wide)
  bool get isSmallDevice => screenWidth < 360;

  /// Is medium device
  bool get isMediumDevice => screenWidth >= 360 && screenWidth < 600;

  /// Is large device (tablet)
  bool get isLargeDevice => screenWidth >= 600;

  /// Is landscape orientation
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get status bar padding
  double get statusBarHeight => MediaQuery.paddingOf(this).top;

  /// Get navigation bar padding
  double get bottomBarHeight => MediaQuery.paddingOf(this).bottom;

  /// Get safe area height
  double get safeAreaHeight => screenHeight -
      MediaQuery.paddingOf(this).top -
      MediaQuery.paddingOf(this).bottom;

  /// Get locale
  Locale get locale => Localizations.localeOf(this);

  /// Is RTL
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Pop the route if possible
  /// Note: use GoRouter.of(context).pop() if using GoRouter to avoid ambiguity
  void popRoute<T>([T? result]) => Navigator.of(this).pop(result);

  /// Hide keyboard
  void hideKeyboard() => FocusScope.of(this).unfocus();

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  /// Navigate to route
  Future<T?> pushRoute<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }
}

/// Number formatting
extension IntExtensions on int {
  /// Format as coin count (1,234 -> 1,234)
  String get formatted => toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );

  /// Format as compact (1.2K, 1.5M)
  String get compact {
    if (this < 1000) return toString();
    if (this < 1000000) {
      return '${(this / 1000).toStringAsFixed(this % 1000 == 0 ? 0 : 1)}K';
    }
    if (this < 1000000000) {
      return '${(this / 1000000).toStringAsFixed(this % 1000000 == 0 ? 0 : 1)}M';
    }
    return '${(this / 1000000000).toStringAsFixed(1)}B';
  }
}

/// String extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Get first character (handles Arabic)
  String get firstChar => isEmpty ? '' : this[0];

  /// Get last character
  String get lastChar => isEmpty ? '' : this[length - 1];

  /// Is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Truncate
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Get initials
  String get initials {
    if (isEmpty) return '';
    final parts = trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length > 1 ? 2 : 1);
    }
    return '${parts[0][0]}${parts[1][0]}';
  }
}
