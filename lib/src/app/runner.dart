import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nibbles/firebase_options.dart';
import 'package:nibbles/src/app.dart';
import 'package:nibbles/src/app/config/flavor_config.dart';
import 'package:nibbles/src/app/qa_bypass.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bootstrap order is strict — do not reorder.
Future<void> bootstrap({required Flavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Figtree (body font) is bundled under google_fonts/ — resolve from assets,
  // never fetch over HTTP, so first paint never depends on the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });

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
    firebaseAndroidApiKey: dotenv.env['FIREBASE_ANDROID_API_KEY']!,
    firebaseAndroidAppId: dotenv.env['FIREBASE_ANDROID_APP_ID']!,
    firebaseIosApiKey: dotenv.env['FIREBASE_IOS_API_KEY']!,
    firebaseIosAppId: dotenv.env['FIREBASE_IOS_APP_ID']!,
    firebaseMessagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
    firebaseProjectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    firebaseStorageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
    firebaseIosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID']!,
  );

  // 3. Hive init + open boxes (wired in NIB-8)
  await Hive.initFlutter();
  await Hive.openBox<String>('recipes');
  await Hive.openBox<String>('allergens');
  await Hive.openBox<dynamic>('local_flags');

  // 3a. QA bypass — when `--dart-define=NIBBLES_QA_BYPASS=true` is set, pre-
  // populate the four onboarding flags so the GoRouter redirect reaches
  // `/home` without auth. No-op when the flag is false.
  await seedQaLocalFlags();

  // 4. Firebase init (firebase options wired in NIB-3)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Route uncaught Flutter framework + platform errors to Crashlytics. Wired
  // immediately after Firebase init so any subsequent boot crash is captured.
  // No PII is recorded — only the framework error/stack.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 5. Supabase init
  await Supabase.initialize(
    url: FlavorConfig.instance.supabaseUrl,
    anonKey: FlavorConfig.instance.supabaseAnonKey,
  );

  // 6. RevenueCat configure
  final revenueCatKey = defaultTargetPlatform == TargetPlatform.iOS
      ? FlavorConfig.instance.revenueCatAppleKey
      : FlavorConfig.instance.revenueCatGoogleKey;
  await Purchases.configure(PurchasesConfiguration(revenueCatKey));

  runApp(ProviderScope(overrides: qaBypassOverrides(), child: const App()));
}
