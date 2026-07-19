// Firebase configuration for the Admin Web Dashboard
//
// Filled in with your real project values. The admin panel is web-only.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    // Admin panel is web-only. Other platforms aren't supported.
    throw UnsupportedError(
      'Admin panel only supports web platform.',
    );
  }

  // Web - real project values
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDI7zL1UXF3cgUwdriZ10coAll9Y7gCHGc',
    appId: '1:48618396707:web:45c79a2eba3a04e5246596',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    authDomain: 'basmah-hrof.firebaseapp.com',
    storageBucket: 'basmah-hrof.firebasestorage.app',
    measurementId: 'G-152YQH87GS',
  );

  // Placeholders for completeness (admin is web-only)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:48618396707:android:PLACEHOLDER',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    storageBucket: 'basmah-hrof.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:48618396707:ios:PLACEHOLDER',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    iosBundleId: 'com.basmahhrof.app',
    storageBucket: 'basmah-hrof.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:48618396707:macos:PLACEHOLDER',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    iosBundleId: 'com.basmahhrof.app',
    storageBucket: 'basmah-hrof.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:48618396707:windows:PLACEHOLDER',
    messagingSenderId: '48618396707',
    projectId: 'basmah-hrof',
    storageBucket: 'basmah-hrof.firebasestorage.app',
  );
}
