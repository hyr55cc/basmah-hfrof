import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Centralized analytics & crashlytics service
class AnalyticsService {
  AnalyticsService();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  bool _enabled = true;

  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    if (!_enabled) return;
    try {
      await _analytics.setUserId(id: userId);
      if (userId != null) {
        await _crashlytics.setUserIdentifier(userId);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Analytics setUserId error: $e');
      }
    }
  }

  /// Set user property
  Future<void> setUserProperty(String name, String value) async {
    if (!_enabled) return;
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Analytics setUserProperty error: $e');
      }
    }
  }

  /// Log an analytics event
  Future<void> logEvent(String name, {Map<String, dynamic>? params}) async {
    if (!_enabled) return;
    try {
      final convertedParams = params?.map(
        (k, v) => MapEntry(k, v.toString()),
      );
      await _analytics.logEvent(name: name, parameters: convertedParams);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Analytics logEvent error: $e');
      }
    }
  }

  /// Set current screen
  Future<void> setCurrentScreen(String screenName) async {
    if (!_enabled) return;
    try {
      await _analytics.setCurrentScreen(screenName: screenName);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Analytics setCurrentScreen error: $e');
      }
    }
  }

  /// Log level start
  Future<void> logLevelStart(int levelId, {String? difficulty}) async {
    await logEvent('level_start', params: {
      'level_id': levelId,
      if (difficulty != null) 'difficulty': difficulty,
    });
  }

  /// Log level complete
  Future<void> logLevelComplete(
    int levelId, {
    int? timeSpent,
    int? wordsFound,
    int? stars,
  }) async {
    await logEvent('level_complete', params: {
      'level_id': levelId,
      if (timeSpent != null) 'time_spent': timeSpent,
      if (wordsFound != null) 'words_found': wordsFound,
      if (stars != null) 'stars': stars,
    });
  }

  /// Log level fail
  Future<void> logLevelFail(int levelId, {String? reason}) async {
    await logEvent('level_fail', params: {
      'level_id': levelId,
      if (reason != null) 'reason': reason,
    });
  }

  /// Log word found
  Future<void> logWordFound(String word, {bool isBonus = false}) async {
    await logEvent('word_found', params: {
      'word_length': word.length,
      'is_bonus': isBonus,
    });
  }

  /// Log hint used
  Future<void> logHintUsed(String hintType, {int? coinsSpent}) async {
    await logEvent('hint_used', params: {
      'hint_type': hintType,
      if (coinsSpent != null) 'coins_spent': coinsSpent,
    });
  }

  /// Log shop purchase
  Future<void> logShopPurchase(String productId, double price, String currency) async {
    await logEvent('shop_purchase', params: {
      'product_id': productId,
      'price': price,
      'currency': currency,
    });
  }

  /// Log rewarded ad watched
  Future<void> logAdWatched(String adType, {String? rewardType, int? rewardAmount}) async {
    await logEvent('ad_watched', params: {
      'ad_type': adType,
      if (rewardType != null) 'reward_type': rewardType,
      if (rewardAmount != null) 'reward_amount': rewardAmount,
    });
  }

  /// Log login
  Future<void> logLogin(String method) async {
    await logEvent('login', params: {'method': method});
  }

  /// Log sign up
  Future<void> logSignUp(String method) async {
    await logEvent('sign_up', params: {'method': method});
  }

  /// Log logout
  Future<void> logLogout() async {
    await logEvent('logout');
  }

  /// Log achievement unlocked
  Future<void> logAchievement(String achievementId) async {
    await logEvent('achievement_unlocked', params: {
      'achievement_id': achievementId,
    });
  }

  /// Log share
  Future<void> logShare(String contentType, {String? itemId}) async {
    await logEvent('share', params: {
      'content_type': contentType,
      if (itemId != null) 'item_id': itemId,
    });
  }

  /// Log tutorial complete
  Future<void> logTutorialComplete() async {
    await logEvent('tutorial_complete');
  }

  /// Log crash
  Future<void> logError(
    String message, {
    StackTrace? stackTrace,
    Object? error,
    Map<String, dynamic>? context,
  }) async {
    try {
      if (context != null) {
        for (final entry in context.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }
      if (stackTrace != null) {
        await _crashlytics.recordError(error ?? message, stackTrace);
      } else {
        await _crashlytics.log(message);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Crashlytics log error: $e');
      }
    }
  }

  /// Log non-fatal error
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(error, stack, reason: reason, fatal: fatal);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Crashlytics record error: $e');
      }
    }
  }

  /// Set custom key
  Future<void> setCustomKey(String key, String value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (_) {}
  }

  /// Toggle analytics
  void toggle(bool enabled) {
    _enabled = enabled;
  }
}
