// The generated line-length rule is intentionally suppressed for
// platform-generated Firebase options files — long string literals in
// FirebaseOptions constructors cannot be broken without losing readability.
// ignore_for_file: lines_longer_than_80_chars
// Values populated from nibbles-prod Firebase project.
// Do NOT commit google-services.json or GoogleService-Info.plist.
// Run `flutterfire configure --project nibbles-prod` to regenerate.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// [FirebaseOptions] for the nibbles-prod Firebase project.
class ProdFirebaseOptions {
  ProdFirebaseOptions._();

  /// Returns [FirebaseOptions] for the current platform targeting nibbles-prod.
  ///
  /// Throws [UnsupportedError] for unsupported platforms (web, macOS, Windows,
  /// Linux).
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'ProdFirebaseOptions: web is not supported.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('ProdFirebaseOptions: macOS is not supported.');
      case TargetPlatform.windows:
        throw UnsupportedError(
          'ProdFirebaseOptions: Windows is not supported.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError('ProdFirebaseOptions: Linux is not supported.');
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'ProdFirebaseOptions: Fuchsia is not supported.',
        );
    }
  }

  /// [FirebaseOptions] for the nibbles-prod Android app.
  ///
  /// Populate with values from android/app/src/prod/google-services.json
  /// after running `flutterfire configure --project nibbles-prod`.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER_PROD_ANDROID_API_KEY',
    appId: 'PLACEHOLDER_PROD_ANDROID_APP_ID',
    messagingSenderId: 'PLACEHOLDER_PROD_MESSAGING_SENDER_ID',
    projectId: 'nibbles-prod',
    storageBucket: 'nibbles-prod.firebasestorage.app',
  );

  /// [FirebaseOptions] for the nibbles-prod iOS app.
  ///
  /// Populate with values from ios/config/prod/GoogleService-Info.plist
  /// after running `flutterfire configure --project nibbles-prod`.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_PROD_IOS_API_KEY',
    appId: 'PLACEHOLDER_PROD_IOS_APP_ID',
    messagingSenderId: 'PLACEHOLDER_PROD_MESSAGING_SENDER_ID',
    projectId: 'nibbles-prod',
    storageBucket: 'nibbles-prod.firebasestorage.app',
    iosBundleId: 'com.aydev.nibbles',
  );
}
