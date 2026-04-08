// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:nibbles/src/app/config/flavor_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: FlavorConfig.instance.firebaseAndroidApiKey,
        appId: FlavorConfig.instance.firebaseAndroidAppId,
        messagingSenderId: FlavorConfig.instance.firebaseMessagingSenderId,
        projectId: FlavorConfig.instance.firebaseProjectId,
        storageBucket: FlavorConfig.instance.firebaseStorageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: FlavorConfig.instance.firebaseIosApiKey,
        appId: FlavorConfig.instance.firebaseIosAppId,
        messagingSenderId: FlavorConfig.instance.firebaseMessagingSenderId,
        projectId: FlavorConfig.instance.firebaseProjectId,
        storageBucket: FlavorConfig.instance.firebaseStorageBucket,
        iosBundleId: FlavorConfig.instance.firebaseIosBundleId,
      );
}
