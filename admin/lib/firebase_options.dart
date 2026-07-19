// Stub file - replace with `flutterfire configure` output for your project.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:1234567890:web:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'arabic-word-puzzle',
    authDomain: 'arabic-word-puzzle.firebaseapp.com',
    storageBucket: 'arabic-word-puzzle.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:1234567890:android:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'arabic-word-puzzle',
    storageBucket: 'arabic-word-puzzle.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'arabic-word-puzzle',
    iosBundleId: 'com.arabicwordpuzzle.app',
    storageBucket: 'arabic-word-puzzle.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:1234567890:macos:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'arabic-word-puzzle',
    iosBundleId: 'com.arabicwordpuzzle.app',
    storageBucket: 'arabic-word-puzzle.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:1234567890:windows:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'arabic-word-puzzle',
    storageBucket: 'arabic-word-puzzle.appspot.com',
  );
}
