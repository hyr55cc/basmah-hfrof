import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification service for FCM and local notifications
class NotificationService {
  NotificationService();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _enabled = true;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  /// Initialize notifications
  Future<void> initialize() async {
    try {
      // Initialize timezone for scheduled notifications
      tz.initializeTimeZones();

      // Request permission
      await _requestPermission();

      // Initialize local notifications
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        macOS: iosInit,
      );
      await _local.initialize(settings);

      // Get FCM token
      _fcmToken = await _fcm.getToken();
      if (kDebugMode) {
        debugPrint('FCM Token: $_fcmToken');
      }

      // Listen for FCM messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

      // Schedule daily reminder
      await _scheduleDailyReminder();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Notification init error: $e');
      }
    }
  }

  Future<void> _requestPermission() async {
    try {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Permission request error: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (!_enabled) return;
    _showLocalNotification(
      title: message.notification?.title ?? 'إشعار',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    // Handle deep linking / routing
    if (kDebugMode) {
      debugPrint('Opened notification: ${message.data}');
    }
  }

  /// Show a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_enabled) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'arabic_word_puzzle_channel',
        'إشعارات اللعبة',
        channelDescription: 'إشعارات لعبة ألغاز الكلمات العربية',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Show notification error: $e');
      }
    }
  }

  /// Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(title: title, body: body, payload: payload);
  }

  /// Schedule daily reminder
  Future<void> _scheduleDailyReminder() async {
    if (!_enabled) return;
    try {
      await _local.zonedSchedule(
        0,
        'حان وقت اللعب!',
        'لديك تحديات جديدة في انتظارك',
        _nextInstanceOfTime(20, 0), // 8:00 PM
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'تذكير يومي',
            channelDescription: 'تذكير يومي للعب',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Schedule reminder error: $e');
      }
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Subscribe topic error: $e');
      }
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unsubscribe topic error: $e');
      }
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    try {
      await _local.cancelAll();
    } catch (_) {}
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    try {
      await _local.cancel(id);
    } catch (_) {}
  }

  /// Toggle notifications
  void toggle(bool value) {
    _enabled = value;
    if (!value) {
      cancelAll();
    }
  }
}
