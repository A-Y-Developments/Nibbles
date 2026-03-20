import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nibbles/src/app.dart';
import 'package:nibbles/src/app/config/flavor_config.dart';
import 'package:nibbles/src/app/firebase/dev_firebase_options.dart';
import 'package:nibbles/src/app/firebase/prod_firebase_options.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Bootstrap order is strict — do not reorder.
Future<void> bootstrap({required Flavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load env file for this flavor
  final envFile = flavor == Flavor.dev ? '.env.dev' : '.env.prod';
  await dotenv.load(fileName: envFile);

  // 2. Initialise FlavorConfig from env
  FlavorConfig.init(
    flavor: flavor,
    supabaseUrl: dotenv.env['SUPABASE_URL']!,
    supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    revenueCatAppleKey: dotenv.env['REVENUECAT_APPLE_KEY']!,
    revenueCatGoogleKey: dotenv.env['REVENUECAT_GOOGLE_KEY']!,
  );

  // 3. Hive init + open boxes
  await Hive.initFlutter();
  await Hive.openBox<String>('recipes');
  await Hive.openBox<String>('allergens');
  await Hive.openBox<dynamic>('local_flags');

  // 4. Firebase init — per-flavor options
  final firebaseOptions = FlavorConfig.instance.isDev
      ? DevFirebaseOptions.currentPlatform
      : ProdFirebaseOptions.currentPlatform;
  await Firebase.initializeApp(options: firebaseOptions);

  // 5. Crashlytics — disabled in dev to avoid noise, enabled in prod
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    FlavorConfig.instance.isProd,
  );

  // Forward Flutter framework errors to Crashlytics in prod
  if (FlavorConfig.instance.isProd) {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // 6. Analytics — always enabled; dev flavor sets a default parameter so
  // events appear in the nibbles-dev Firebase DebugView.
  // To activate DebugView on device:
  //   adb shell setprop debug.firebase.analytics.app com.aydev.nibbles.dev
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  if (FlavorConfig.instance.isDev) {
    await FirebaseAnalytics.instance
        .setDefaultEventParameters({'flavor': 'dev'});
  }

  // 7. RevenueCat configure
  final revenueCatKey = defaultTargetPlatform == TargetPlatform.iOS
      ? FlavorConfig.instance.revenueCatAppleKey
      : FlavorConfig.instance.revenueCatGoogleKey;
  await Purchases.configure(PurchasesConfiguration(revenueCatKey));

  runApp(const ProviderScope(child: App()));
}
