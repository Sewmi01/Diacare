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
    apiKey: 'AIzaSyAwq5_KbMZe1l5mr2r9dcmzotXzV9FZEfg',
    appId: '1:584787447882:web:f0310a88cdd24fa2e816b3',
    messagingSenderId: '584787447882',
    projectId: 'care-de2dd',
    authDomain: 'care-de2dd.firebaseapp.com',
    storageBucket: 'care-de2dd.firebasestorage.app',
    measurementId: 'G-K9YNQT53LW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAEJkUofgnb6Ppq8yfPFGbcFwaiK0b7CTo',
    appId: '1:584787447882:android:1f69ccc667a1bfb4e816b3',
    messagingSenderId: '584787447882',
    projectId: 'care-de2dd',
    storageBucket: 'care-de2dd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAdf4PG1_Sh_bHctPbXqnlo2vZ5g7MtQNY',
    appId: '1:584787447882:ios:70a4ba67df93705ae816b3',
    messagingSenderId: '584787447882',
    projectId: 'care-de2dd',
    storageBucket: 'care-de2dd.firebasestorage.app',
    iosBundleId: 'com.example.diecareApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAdf4PG1_Sh_bHctPbXqnlo2vZ5g7MtQNY',
    appId: '1:584787447882:ios:70a4ba67df93705ae816b3',
    messagingSenderId: '584787447882',
    projectId: 'care-de2dd',
    storageBucket: 'care-de2dd.firebasestorage.app',
    iosBundleId: 'com.example.diecareApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAwq5_KbMZe1l5mr2r9dcmzotXzV9FZEfg',
    appId: '1:584787447882:web:e0e1daa4e8aad8a4e816b3',
    messagingSenderId: '584787447882',
    projectId: 'care-de2dd',
    authDomain: 'care-de2dd.firebaseapp.com',
    storageBucket: 'care-de2dd.firebasestorage.app',
    measurementId: 'G-TMB1H703S2',
  );
}
