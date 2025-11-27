// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web; // ADD THIS - return web configuration for web platform
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

  // ADD WEB CONFIGURATION
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB5lq6ENqiH37ry42H85ybPqf-6csNDREk',
    appId: '1:745124156326:web:d76966e73e4c8414997567',
    messagingSenderId: '745124156326',
    projectId: 'eventhub-859b9',
    authDomain: 'eventhub-859b9.firebaseapp.com',
    storageBucket: 'eventhub-859b9.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5lq6ENqiH37ry42H85ybPqf-6csNDREk',
    appId: '1:745124156326:android:d76966e73e4c8414997567',
    messagingSenderId: '745124156326',
    projectId: 'eventhub-859b9',
    storageBucket: 'eventhub-859b9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB5lq6ENqiH37ry42H85ybPqf-6csNDREk',
    appId: '1:745124156326:ios:d76966e73e4c8414997567',
    messagingSenderId: '745124156326',
    projectId: 'eventhub-859b9',
    storageBucket: 'eventhub-859b9.appspot.com',
    iosBundleId: 'com.example.hereBro',
  );
}