// lib/firebase_options.dart
// Auto-generated FirebaseOptions — bypasses google-services.json
// Values from your Firebase project: electrocare-fd844

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
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5FXf6sIQz5mtXWPmcmS7rw_4ngwfopno',
    appId: '1:200399727960:android:1839b9de15333720b7892d',
    messagingSenderId: '200399727960',
    projectId: 'electrocare-fd844',
    storageBucket: 'electrocare-fd844.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5FXf6sIQz5mtXWPmcmS7rw_4ngwfopno',
    appId: '1:200399727960:android:1839b9de15333720b7892d',
    messagingSenderId: '200399727960',
    projectId: 'electrocare-fd844',
    storageBucket: 'electrocare-fd844.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA5FXf6sIQz5mtXWPmcmS7rw_4ngwfopno',
    appId: '1:200399727960:android:1839b9de15333720b7892d',
    messagingSenderId: '200399727960',
    projectId: 'electrocare-fd844',
    storageBucket: 'electrocare-fd844.firebasestorage.app',
    authDomain: 'electrocare-fd844.firebaseapp.com',
  );
}
