import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCOQClkQeA4sfBkF84KMao__Z2bbG89uXI',
    appId: '1:472617724499:web:9cd58c9a75a072abc9f4a6',
    messagingSenderId: '472617724499',
    projectId: 'auto-port-d3655',
    authDomain: 'auto-port-d3655.firebaseapp.com',
    databaseURL: 'https://auto-port-d3655-default-rtdb.firebaseio.com',
    storageBucket: 'auto-port-d3655.firebasestorage.app',
    measurementId: 'G-944CNVBTGJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCX_BAyE-mMMOULKRgFXgywEUSjoOq14q8',
    appId: '1:472617724499:android:d7ea196caf6b9f42c9f4a6',
    messagingSenderId: '472617724499',
    projectId: 'auto-port-d3655',
    databaseURL: 'https://auto-port-d3655-default-rtdb.firebaseio.com',
    storageBucket: 'auto-port-d3655.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAi4xUuPSpF-9HEB5--Y8wMix1b0ytKTw8',
    appId: '1:472617724499:ios:3a70a199a054d4bcc9f4a6',
    messagingSenderId: '472617724499',
    projectId: 'auto-port-d3655',
    databaseURL: 'https://auto-port-d3655-default-rtdb.firebaseio.com',
    storageBucket: 'auto-port-d3655.firebasestorage.app',
    iosClientId:
        '472617724499-ebkpv7qq11uvm74pl3bulf9j6si8q5mt.apps.googleusercontent.com',
    iosBundleId: 'com.example.autoPort',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAi4xUuPSpF-9HEB5--Y8wMix1b0ytKTw8',
    appId: '1:472617724499:ios:3a70a199a054d4bcc9f4a6',
    messagingSenderId: '472617724499',
    projectId: 'auto-port-d3655',
    databaseURL: 'https://auto-port-d3655-default-rtdb.firebaseio.com',
    storageBucket: 'auto-port-d3655.firebasestorage.app',
    iosClientId:
        '472617724499-ebkpv7qq11uvm74pl3bulf9j6si8q5mt.apps.googleusercontent.com',
    iosBundleId: 'com.example.autoPort',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCOQClkQeA4sfBkF84KMao__Z2bbG89uXI',
    appId: '1:472617724499:web:d8fd4bbcd56ecbb4c9f4a6',
    messagingSenderId: '472617724499',
    projectId: 'auto-port-d3655',
    authDomain: 'auto-port-d3655.firebaseapp.com',
    databaseURL: 'https://auto-port-d3655-default-rtdb.firebaseio.com',
    storageBucket: 'auto-port-d3655.firebasestorage.app',
    measurementId: 'G-576ZJKCZ67',
  );
}
