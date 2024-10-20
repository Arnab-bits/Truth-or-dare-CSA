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
    apiKey: 'AIzaSyCVNZ3_5LOoxujGOWc96fZhLfI5ArARAz0',
    appId: '1:730538388169:web:c608fb53618ba161c5fb18',
    messagingSenderId: '730538388169',
    projectId: 'csa-proj',
    authDomain: 'csa-proj.firebaseapp.com',
    storageBucket: 'csa-proj.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAO6ARfE0wkyF64NDMgB3HX8im1Zaq72Nk',
    appId: '1:730538388169:android:04c17b2f02ea498cc5fb18',
    messagingSenderId: '730538388169',
    projectId: 'csa-proj',
    storageBucket: 'csa-proj.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBR2oNjpg1ueBWykKKFpbuZE4py-vUBIBk',
    appId: '1:730538388169:ios:4520ba24e8c5cd09c5fb18',
    messagingSenderId: '730538388169',
    projectId: 'csa-proj',
    storageBucket: 'csa-proj.appspot.com',
    iosBundleId: 'com.example.truthOrDare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBR2oNjpg1ueBWykKKFpbuZE4py-vUBIBk',
    appId: '1:730538388169:ios:4520ba24e8c5cd09c5fb18',
    messagingSenderId: '730538388169',
    projectId: 'csa-proj',
    storageBucket: 'csa-proj.appspot.com',
    iosBundleId: 'com.example.truthOrDare',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCVNZ3_5LOoxujGOWc96fZhLfI5ArARAz0',
    appId: '1:730538388169:web:8f516d5bf4eb8ef5c5fb18',
    messagingSenderId: '730538388169',
    projectId: 'csa-proj',
    authDomain: 'csa-proj.firebaseapp.com',
    storageBucket: 'csa-proj.appspot.com',
  );
}