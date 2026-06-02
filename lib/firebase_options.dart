import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDY1qbnuZmQEk6YS8ToLEbF-TKRUT41wN0',
    authDomain: 'wellcare-pharmacy-11002.firebaseapp.com',
    databaseURL: 'https://wellcare-pharmacy-11002-default-rtdb.asia-southeast1.firebasedatabase.app',
    projectId: 'wellcare-pharmacy-11002',
    storageBucket: 'wellcare-pharmacy-11002.firebasestorage.app',
    messagingSenderId: '895164172618',
    appId: '1:895164172618:web:69adaf7e1a1d2701fd59b3',
  );
}