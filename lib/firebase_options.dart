// File generated for SmartFrost Firebase configuration.
// ignore_for_file: type=lint
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
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQkp792yzJm4IF78E5RXab59J0lA5iLRI',
    appId: '1:144256451538:android:478d591b4d982e826bfe0b',
    messagingSenderId: '144256451538',
    projectId: 'frost-score',
    databaseURL: 'https://frost-score-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'frost-score.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBQkp792yzJm4IF78E5RXab59J0lA5iLRI',
    appId: '1:144256451538:web:smartfrost_web',
    messagingSenderId: '144256451538',
    projectId: 'frost-score',
    databaseURL: 'https://frost-score-default-rtdb.asia-southeast1.firebasedatabase.app',
    authDomain: 'frost-score.firebaseapp.com',
    storageBucket: 'frost-score.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQkp792yzJm4IF78E5RXab59J0lA5iLRI',
    appId: '1:144256451538:ios:smartfrost_ios',
    messagingSenderId: '144256451538',
    projectId: 'frost-score',
    databaseURL: 'https://frost-score-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'frost-score.firebasestorage.app',
  );
}
