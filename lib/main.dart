import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/helpers/arabic_dictionary.dart';
import 'services/ads/ad_service.dart';
import 'services/notifications/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Error boundary - never let an init error block the app
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set system UI overlay for status bar (mobile only)
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    }

    // Initialize dependencies
    try {
      await initDependencies();
    } catch (e) {
      if (kDebugMode) debugPrint('DI init error: $e');
    }

    // Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Firebase init error: $e');
    }

    // Initialize App Check (release mode only, not on web)
    if (!kDebugMode && !kIsWeb) {
      try {
        await FirebaseAppCheck.instance.activate(
          webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.appAttest,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('AppCheck init error: $e');
      }
    }

    // Load Arabic dictionary
    try {
      await ArabicDictionary.instance.initialize();
    } catch (e) {
      if (kDebugMode) debugPrint('Dictionary init error: $e');
    }

    // Initialize services - wrap each so one failure doesn't break the app
    if (!kIsWeb) {
      try {
        await sl<NotificationService>().initialize();
      } catch (e) {
        if (kDebugMode) debugPrint('Notification init error: $e');
      }
    }

    if (!kIsWeb) {
      try {
        await sl<AdService>().initialize();
      } catch (e) {
        if (kDebugMode) debugPrint('AdService init error: $e');
      }
    }

    // Run app
    runApp(const ProviderScope(child: ArabicWordPuzzleApp()));
  }, (error, stack) {
    if (kDebugMode) {
      debugPrint('Uncaught zone error: $error\n$stack');
    }
  });
}
