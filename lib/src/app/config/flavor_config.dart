enum Flavor { dev, prod }

class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.revenueCatAppleKey,
    required this.revenueCatGoogleKey,
    required this.firebaseAndroidApiKey,
    required this.firebaseAndroidAppId,
    required this.firebaseIosApiKey,
    required this.firebaseIosAppId,
    required this.firebaseMessagingSenderId,
    required this.firebaseProjectId,
    required this.firebaseStorageBucket,
    required this.firebaseIosBundleId,
  });

  static late FlavorConfig instance;

  final Flavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String revenueCatAppleKey;
  final String revenueCatGoogleKey;
  final String firebaseAndroidApiKey;
  final String firebaseAndroidAppId;
  final String firebaseIosApiKey;
  final String firebaseIosAppId;
  final String firebaseMessagingSenderId;
  final String firebaseProjectId;
  final String firebaseStorageBucket;
  final String firebaseIosBundleId;

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;

  String get appScheme => isDev ? 'com.aydev.nibbles.dev' : 'com.aydev.nibbles';

  static void init({
    required Flavor flavor,
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String revenueCatAppleKey,
    required String revenueCatGoogleKey,
    required String firebaseAndroidApiKey,
    required String firebaseAndroidAppId,
    required String firebaseIosApiKey,
    required String firebaseIosAppId,
    required String firebaseMessagingSenderId,
    required String firebaseProjectId,
    required String firebaseStorageBucket,
    required String firebaseIosBundleId,
  }) {
    instance = FlavorConfig._(
      flavor: flavor,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      revenueCatAppleKey: revenueCatAppleKey,
      revenueCatGoogleKey: revenueCatGoogleKey,
      firebaseAndroidApiKey: firebaseAndroidApiKey,
      firebaseAndroidAppId: firebaseAndroidAppId,
      firebaseIosApiKey: firebaseIosApiKey,
      firebaseIosAppId: firebaseIosAppId,
      firebaseMessagingSenderId: firebaseMessagingSenderId,
      firebaseProjectId: firebaseProjectId,
      firebaseStorageBucket: firebaseStorageBucket,
      firebaseIosBundleId: firebaseIosBundleId,
    );
  }
}
