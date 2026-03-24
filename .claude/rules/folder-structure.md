# Folder Structure

```
lib/
  gen/                         # flutter_gen auto-generated (committed)
  main.dart                    # prod entry point
  main_dev.dart                # dev entry point
  src/
    app.dart                   # Root widget (ProviderScope + MaterialApp.router)
    app/
      config/                  # FlavorConfig, AppConfig
      constants/               # AllergenEmoji, HiveBoxNames, allergen list, symptom presets, enums
      firebase/                # FirebaseOptions per env (dev + prod)
      runner.dart              # Bootstrap (strict init order — see infra agent)
      themes/                  # AppTheme, colors, typography, shadows, sizes
    common/
      components/              # Shared widgets
        boilerplate/           # Dev-only component showcase
      data/
        mappers/               # DTO → domain entity mappers
        models/
          entity/              # Hive data models (freezed)
          requests/            # API request bodies (freezed + json)
          responses/           # API response DTOs (freezed + json)
        repositories/          # Interfaces + implementations
        sources/
          local/               # HiveService, LocalFlagService
          remote/
            api/               # Retrofit API interfaces (+ .g.dart)
            config/            # Dio client, auth interceptor, Result type
      domain/
        entities/              # Baby, AllergenLog, ReactionDetail, Recipe, etc.
        enums/                 # AllergenStatus, EmojiTaste, Gender, ReactionSeverity, etc.
        formz/                 # Email, password, babyName validators
      services/                # AuthService, AllergenService, RecipeService,
                               # MealPlanService, ShoppingListService,
                               # SubscriptionService, BabyProfileService, LocalFlagService
    features/                  # Feature modules
    routing/
      routes.dart              # GoRouter provider + redirect logic
      route_enums.dart         # Routes enum (path + name)
      routes/                  # auth_routes, onboarding_routes, main_routes
    localization/              # easy_localization codegen
    logging/
      analytics.dart           # Firebase Analytics wrapper (no PII)
    utils/
      extensions/              # BuildContext, DateTime, String, Widget, Result
      validators/
```
