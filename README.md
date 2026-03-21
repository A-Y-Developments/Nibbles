# Nibbles

Guided baby solids app. iOS 15+ / Android 10+.

## Stack

- **Framework**: Flutter (Dart)
- **State**: flutter_riverpod (AsyncNotifier pattern)
- **Navigation**: go_router
- **Backend**: Supabase (Auth + Postgres + RLS)
- **Networking**: Dio + Retrofit
- **Local storage**: Hive (cache + flags) + flutter_secure_storage (JWT)
- **Subscriptions**: RevenueCat
- **Analytics / Crash**: Firebase Analytics + Crashlytics

## Prerequisites

- Flutter SDK `^3.10.7` — [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK `^3.10.7` (bundled with Flutter)
- Xcode 15+ (iOS)
- Android Studio / Android SDK (Android)
- A Supabase project (dev + prod)
- A RevenueCat account with iOS + Android apps configured

## Local setup

### 1. Clone and install dependencies

```bash
git clone https://github.com/A-Y-Developments/Nibbles.git
cd Nibbles
flutter pub get
```

### 2. Create environment files

Copy `.env.example` twice — once for dev, once for prod:

```bash
cp .env.example .env.dev
cp .env.example .env.prod
```

Then fill in the values in each file:

| Key | Where to find it |
|---|---|
| `SUPABASE_URL` | Supabase Dashboard → Project Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Supabase Dashboard → Project Settings → API → anon public |
| `REVENUECAT_APPLE_KEY` | RevenueCat Dashboard → Apps → iOS app → Public SDK key |
| `REVENUECAT_GOOGLE_KEY` | RevenueCat Dashboard → Apps → Android app → Public SDK key |

> `.env.dev` and `.env.prod` are gitignored — never commit them.

### 3. Run the app

**Dev flavor:**
```bash
flutter run -t lib/main_dev.dart
```

**Prod flavor:**
```bash
flutter run -t lib/main.dart
```

### 4. Code generation

Run after any change to `@freezed`, `@JsonSerializable`, `@RestApi`, or `@riverpod` annotated code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files (`*.freezed.dart`, `*.g.dart`) are committed to source control.

## Project structure

```
lib/
  main.dart           # prod entry point
  main_dev.dart       # dev entry point
  src/
    app/              # FlavorConfig, AppTheme, bootstrap runner
    common/
      data/           # repositories, DTOs, mappers, Hive + Dio config
      domain/         # entities, enums, formz validators
      services/       # business logic (AuthService, AllergenService, etc.)
      components/     # shared widgets
    features/         # one folder per screen/flow
    routing/          # GoRouter config + redirect logic
```

See `CLAUDE.md` for full architecture rules and agent roles.

## Environments

| | Dev | Prod |
|---|---|---|
| Entry point | `lib/main_dev.dart` | `lib/main.dart` |
| Bundle ID (iOS) | `com.aydev.nibbles.dev` | `com.aydev.nibbles` |
| Env file | `.env.dev` | `.env.prod` |

## Linting

Zero warnings policy — all PRs must pass:

```bash
flutter analyze --fatal-infos --fatal-warnings
```
