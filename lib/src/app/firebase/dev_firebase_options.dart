// The generated line-length rule is intentionally suppressed for
// platform-generated Firebase options files — long string literals in
// FirebaseOptions constructors cannot be broken without losing readability.
// ignore_for_file: lines_longer_than_80_chars
// Values populated from nibbles-dev Firebase project.
// Do NOT commit google-services.json or GoogleService-Info.plist.
// Run `flutterfire configure --project nibbles-dev` to regenerate.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// [FirebaseOptions] for the nibbles-dev Firebase project.
class DevFirebaseOptions {
  DevFirebaseOptions._();

  /// Returns [FirebaseOptions] for the current platform targeting nibbles-dev.
  ///
  /// Throws [UnsupportedError] for unsupported platforms (web, macOS, Windows,
  /// Linux).
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DevFirebaseOptions: web is not supported.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('DevFirebaseOptions: macOS is not supported.');
      case TargetPlatform.windows:
        throw UnsupportedError('DevFirebaseOptions: Windows is not supported.');
      case TargetPlatform.linux:
        throw UnsupportedError('DevFirebaseOptions: Linux is not supported.');
      case TargetPlatform.fuchsia:
        throw UnsupportedError('DevFirebaseOptions: Fuchsia is not supported.');
    }
  }

  /// [FirebaseOptions] for the nibbles-dev Android app.
  ///
  /// Populate with values from android/app/src/dev/google-services.json
  /// after running `flutterfire configure --project nibbles-dev`.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER_DEV_ANDROID_API_KEY',
    appId: 'PLACEHOLDER_DEV_ANDROID_APP_ID',
    messagingSenderId: 'PLACEHOLDER_DEV_MESSAGING_SENDER_ID',
    projectId: 'nibbles-dev',
    storageBucket: 'nibbles-dev.firebasestorage.app',
  );

  /// [FirebaseOptions] for the nibbles-dev iOS app.
  ///
  /// Populate with values from ios/config/dev/GoogleService-Info.plist
  /// after running `flutterfire configure --project nibbles-dev`.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_DEV_IOS_API_KEY',
    appId: 'PLACEHOLDER_DEV_IOS_APP_ID',
    messagingSenderId: 'PLACEHOLDER_DEV_MESSAGING_SENDER_ID',
    projectId: 'nibbles-dev',
    storageBucket: 'nibbles-dev.firebasestorage.app',
    iosBundleId: 'com.aydev.nibbles.dev',
  );
}
