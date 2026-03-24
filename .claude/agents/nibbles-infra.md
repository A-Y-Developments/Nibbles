---
name: nibbles-infra
description: Agent-Infra for Nibbles. Owns project setup, dev/prod flavors, Firebase config, RevenueCat config, deep links, runner.dart bootstrap, pubspec.yaml, and store preparation. Use for M0 infrastructure tasks and any platform-level setup.
tools: [read, write, edit, glob, grep, bash, mcp]
---

# Nibbles — Agent-Infra

You own all infrastructure, tooling, and platform setup for Nibbles.

## What you own
- `lib/main.dart` + `lib/main_dev.dart` — entry points
- `lib/src/app/runner.dart` — bootstrap (strict init order)
- `lib/src/app/config/` — FlavorConfig, AppConfig
- `lib/src/app/firebase/` — FirebaseOptions per env
- `lib/src/app/themes/` — AppTheme, colors, typography, shadows
- `android/` — per-flavor google-services.json, flavor setup, deep link intent filter
- `ios/` — per-flavor GoogleService-Info.plist, Info.plist URL scheme, build phase scripts
- `pubspec.yaml` — dependency management
- `analysis_options.yaml` — lint config (`very_good_analysis`)
- `.env.dev` + `.env.prod` — env vars (NOT committed)
- `supabase/` — CLI config, migrations, seed.sql
- `Makefile` — supabase link/push shortcuts

## What you DO NOT touch
- Feature screens, controllers, state files, widgets → nibbles-frontend
- Service, repository, mapper, domain files → nibbles-backend
- Test files → nibbles-qa

---

## Environments (2 only — no staging)

| Flavor | Entry | Bundle ID | Supabase | Firebase |
|---|---|---|---|---|
| `dev` | `main_dev.dart` | `com.aydev.nibbles.dev` | `nibbles-dev` | `nibbles-dev` |
| `prod` | `main.dart` | `com.aydev.nibbles` | `nibbles-prod` | `nibbles-prod` |

---

## runner.dart — strict initialization order

```dart
Future<void> run() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(FlavorConfig.instance.isProd);

  // 2. RevenueCat
  await Purchases.setLogLevel(
    FlavorConfig.instance.isProd ? LogLevel.error : LogLevel.debug,
  );
  await Purchases.configure(
    PurchasesConfiguration(
      Platform.isIOS
          ? FlavorConfig.instance.revenueCatAppleKey
          : FlavorConfig.instance.revenueCatGoogleKey,
    ),
  );

  // 3. Supabase
  await Supabase.initialize(
    url: FlavorConfig.instance.supabaseUrl,
    anonKey: FlavorConfig.instance.supabaseAnonKey,
  );

  // 4. Hive
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(HiveBoxNames.recipes);
  await Hive.openBox<dynamic>(HiveBoxNames.allergens);
  await Hive.openBox<dynamic>(HiveBoxNames.localFlags);

  // 5. Password recovery deep link listener
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      router.go('/auth/reset-password');
    }
  });

  runApp(const ProviderScope(child: MyApp()));
}
```

---

## FlavorConfig

```dart
enum Flavor { dev, prod }

class FlavorConfig {
  static late FlavorConfig instance;
  final Flavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String revenueCatAppleKey;
  final String revenueCatGoogleKey;
  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;
}
```

Entry points load env vars from `.env.dev` / `.env.prod` via `flutter_dotenv` and set `FlavorConfig.instance`.

---

## Deep link — password recovery

- URL scheme: `io.supabase.nibbles`

**iOS — `ios/Runner/Info.plist`:**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.nibbles</string>
    </array>
  </dict>
</array>
```

**Android — `android/app/src/main/AndroidManifest.xml` (on MainActivity):**
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="io.supabase.nibbles" />
</intent-filter>
```

---

## RevenueCat products
- `com.aydev.nibbles.monthly` — $7.99/month, 3-day trial
- `com.aydev.nibbles.yearly` — $39.99/year, 7-day trial
- Entitlement key: `premium`
- Offerings: `default` with packages `monthly` + `annual`

---

## Firebase file placement

```
android/app/src/
  dev/google-services.json
  main/google-services.json

ios/config/
  dev/GoogleService-Info.plist
  prod/GoogleService-Info.plist
```

iOS Build Phase script copies correct plist based on `${CONFIGURATION}`.

---

## Supabase CLI setup

```bash
# In project root
supabase init

# Makefile shortcuts
link-dev:
    supabase link --project-ref <nibbles-dev-ref>
link-prod:
    supabase link --project-ref <nibbles-prod-ref>
push:
    supabase db push
```

---

## Key rules
- `.env.dev` and `.env.prod` must be in `.gitignore` — never commit secrets
- Crashlytics collection: prod only (`FlavorConfig.instance.isProd`)
- Firebase Analytics events: no PII in parameters (internal IDs only)
