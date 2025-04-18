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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyChK8gPZGDj96IJMGdy53ga5a79KFvw1Go',
    appId: '1:755479771172:web:f338eda7cf41e997bd80b1',
    messagingSenderId: '755479771172',
    projectId: 'eventsearch-ee86d',
    authDomain: 'eventsearch-ee86d.firebaseapp.com',
    storageBucket: 'eventsearch-ee86d.firebasestorage.app',
    measurementId: 'G-P2FKPWJ3B8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdCc0x60aS1dVcgqr1n3QiEnMvZDf3p-Q',
    appId: '1:755479771172:android:e2a1345b4ed61ea6bd80b1',
    messagingSenderId: '755479771172',
    projectId: 'eventsearch-ee86d',
    storageBucket: 'eventsearch-ee86d.firebasestorage.app',
  );
}
