enum Flavor { dev, prod }

class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.revenueCatAppleKey,
    required this.revenueCatGoogleKey,
  });

  static late FlavorConfig instance;

  final Flavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String revenueCatAppleKey;
  final String revenueCatGoogleKey;

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;

  static void init({
    required Flavor flavor,
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String revenueCatAppleKey,
    required String revenueCatGoogleKey,
  }) {
    instance = FlavorConfig._(
      flavor: flavor,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      revenueCatAppleKey: revenueCatAppleKey,
      revenueCatGoogleKey: revenueCatGoogleKey,
    );
  }
}
