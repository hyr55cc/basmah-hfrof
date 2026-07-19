// Firebase configuration for Arabic Word Puzzle
//
// Web config is filled in with the actual project values.
// Android, iOS, macOS, and Windows configs are placeholders —
// run `flutterfire configure` to generate real values from your Firebase project.
//
// Steps:
//   1. dart pub global activate flutterfire_cli
//   2. flutterfire configure
//   3. The CLI will overwrite this file with the correct per-platform configs.
//
// The web block below is what the JS SDK uses and works for Flutter web builds.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web - filled in with your real Firebase project values
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDI7zL1UXF3cgUwdriZ10coAll9Y7gCHGc',
    appId: '1:48618396707:web:45c79a2eba3a04e5246596',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    authDomain: 'basmah-hrof.firebaseapp.com',
    storageBucket: 'basmah-hrof.firebasestorage.app',
    measurementId: 'G-152YQH87GS',
  );

  // Android - placeholder. Run `flutterfire configure` to populate.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER_ANDROID_API_KEY',
    appId: '1:48618396707:android:PLACEHOLDER',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    storageBucket: 'basmah-hrof.firebasestorage.app',
  );

  // iOS - placeholder. Run `flutterfire configure` to populate.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_IOS_API_KEY',
    appId: '1:48618396707:ios:PLACEHOLDER',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    iosBundleId: 'com.basmahhrof.app',
    storageBucket: 'basmah-hrof.firebasestorage.app',
  );

  // macOS - placeholder. Run `flutterfire configure` to populate.
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PLACEHOLDER_MACOS_API_KEY',
    appId: '1:48618396707:macos:PLACEHOLDER',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    iosBundleId: 'com.basmahhrof.app',
    storageBucket: 'basmah-hrof.firebasestorage.app',
  );

  // Windows - placeholder. Run `flutterfire configure` to populate.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'PLACEHOLDER_WINDOWS_API_KEY',
    appId: '1:48618396707:windows:PLACEHOLDER',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    storageBucket: 'basmah-hrof.firebasestorage.app',
  );

  // Linux - placeholder. Run `flutterfire configure` to populate.
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'PLACEHOLDER_LINUX_API_KEY',
    appId: '1:48618396707:linux:PLACEHOLDER',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    storageBucket: 'basmah-hrof.firebasestorage.app',
  );
}
