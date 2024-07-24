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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDOuT906S5k38BKUUjLgyLy8VJkrRcf3Jw',
    appId: '1:626517897437:web:232a7e5270dae2aadb6b34',
    messagingSenderId: '626517897437',
    projectId: 'portfolio-plus-c2a7a',
    authDomain: 'portfolio-plus-c2a7a.firebaseapp.com',
    storageBucket: 'portfolio-plus-c2a7a.appspot.com',
    measurementId: 'G-HNRFW2KDEL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4zWCB5DRPYqyxy0JyHLrCXkIN738DJKE',
    appId: '1:626517897437:android:6feb5c8c76b4d9ffdb6b34',
    messagingSenderId: '626517897437',
    projectId: 'portfolio-plus-c2a7a',
    storageBucket: 'portfolio-plus-c2a7a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxS6a5bGBrUBJPUIAGCSHvxkze8TyhQoY',
    appId: '1:626517897437:ios:7686fb4b28c5f353db6b34',
    messagingSenderId: '626517897437',
    projectId: 'portfolio-plus-c2a7a',
    storageBucket: 'portfolio-plus-c2a7a.appspot.com',
    iosBundleId: 'com.example.portfolioPlus',
  );
}