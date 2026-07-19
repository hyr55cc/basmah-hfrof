import 'package:flutter/services.dart';

/// Haptic feedback intensities
enum HapticType { light, medium, heavy, success, warning, error, selection }

/// Centralized haptic feedback service
class HapticService {
  HapticService();

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  /// Play a haptic feedback
  Future<void> trigger(HapticType type) async {
    if (!_enabled) return;
    try {
      switch (type) {
        case HapticType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          await HapticFeedback.selectionClick();
          break;
        case HapticType.success:
          await HapticFeedback.lightImpact();
          await Future<void>.delayed(const Duration(milliseconds: 80));
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.warning:
          await HapticFeedback.mediumImpact();
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await HapticFeedback.heavyImpact();
          break;
        case HapticType.error:
          await HapticFeedback.heavyImpact();
          await Future<void>.delayed(const Duration(milliseconds: 60));
          await HapticFeedback.heavyImpact();
          break;
      }
    } catch (_) {
      // Haptics not available on this device
    }
  }

  /// Light tap (for button presses)
  Future<void> light() => trigger(HapticType.light);

  /// Medium tap (for selections)
  Future<void> medium() => trigger(HapticType.medium);

  /// Heavy tap (for big moments)
  Future<void> heavy() => trigger(HapticType.heavy);

  /// Selection (for toggles / radio)
  Future<void> selection() => trigger(HapticType.selection);

  /// Word found
  Future<void> wordFound() => trigger(HapticType.success);

  /// Wrong word
  Future<void> wrong() => trigger(HapticType.error);

  /// Level complete
  Future<void> levelComplete() async {
    await trigger(HapticType.heavy);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await trigger(HapticType.medium);
  }

  /// Coin earned
  Future<void> coinEarned() => trigger(HapticType.light);

  /// Button tap
  Future<void> button() => trigger(HapticType.selection);
}
