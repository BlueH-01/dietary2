// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC9o6NF466kVfLkneVQAS3EQQmthpFXM3w',
    appId: '1:293844531550:web:522a5954a2f28573d037cf',
    messagingSenderId: '293844531550',
    projectId: 'dietary-bfad4',
    authDomain: 'dietary-bfad4.firebaseapp.com',
    storageBucket: 'dietary-bfad4.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoWQXA3wh8DLSvRcr3KJN7BpsGJOI1qqs',
    appId: '1:293844531550:android:b728bee1654518b1d037cf',
    messagingSenderId: '293844531550',
    projectId: 'dietary-bfad4',
    storageBucket: 'dietary-bfad4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDK-fGCvRDX4tkul8Ro1waA6VVxt9Iqge8',
    appId: '1:293844531550:ios:0e9b1ff3885bf6f6d037cf',
    messagingSenderId: '293844531550',
    projectId: 'dietary-bfad4',
    storageBucket: 'dietary-bfad4.firebasestorage.app',
    iosBundleId: 'com.example.dietary2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDK-fGCvRDX4tkul8Ro1waA6VVxt9Iqge8',
    appId: '1:293844531550:ios:0e9b1ff3885bf6f6d037cf',
    messagingSenderId: '293844531550',
    projectId: 'dietary-bfad4',
    storageBucket: 'dietary-bfad4.firebasestorage.app',
    iosBundleId: 'com.example.dietary2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC9o6NF466kVfLkneVQAS3EQQmthpFXM3w',
    appId: '1:293844531550:web:ba7f8c678768e62ad037cf',
    messagingSenderId: '293844531550',
    projectId: 'dietary-bfad4',
    authDomain: 'dietary-bfad4.firebaseapp.com',
    storageBucket: 'dietary-bfad4.firebasestorage.app',
  );

}