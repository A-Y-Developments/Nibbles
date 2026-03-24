# Nibbles — Project Rules

## What is Nibbles
Guided baby solids app. iOS 15+ / Android 10+. Flutter + Supabase + RevenueCat.
Target: MVP by 2026-06-05. Urgent priority.

---

## Stack (locked)
- State: `flutter_riverpod` — AsyncNotifier pattern
- Navigation: `go_router`
- Networking: `dio` + `retrofit` (code-gen via `retrofit_generator`)
- Local: `hive_flutter` (read-through cache + flags) + `flutter_secure_storage` (JWT only)
- Code gen: `freezed`, `json_serializable`, `retrofit_generator`, `flutter_gen`, `riverpod_generator`
- Backend: `supabase_flutter` (Auth + Postgres + RLS)
- Subscriptions: `purchases_flutter` (RevenueCat)
- Analytics/Crash: `firebase_analytics` + `firebase_crashlytics`
- Font: Nunito
- Linting: `very_good_analysis` + `riverpod_lint` — zero warnings merged to main

---

## Architecture (mandatory — no exceptions)

```
Screen (ConsumerWidget)
  └── Controller (AsyncNotifier via Riverpod)
        └── Service (business logic, composes repositories)
              └── Repository
                    ├── Remote: Retrofit → Dio → Supabase REST
                    └── Local: Hive (read-through cache for recipes/allergens; local flags)
```

### Hard rules
1. **Result<T>** — all async ops return `Result<T>` (freezed `Success<T> | Failure`). No raw throws in UI. Ever.
2. **Mappers** — every Supabase response DTO maps to a domain entity before reaching Service. UI/Service never touch DTOs.
3. **Supabase** — Repository layer only. No direct Supabase calls in Service, Controller, or Screen.
4. **Hive** — 3 boxes only: `recipes`, `allergens`, `local_flags`. Read-through cache for recipes/allergens. LocalFlagService wraps `local_flags` box.
5. **JWT** — stored in `flutter_secure_storage` ONLY. Never Hive, never SharedPreferences.
6. **Online only** — no offline write queue. If no connectivity on write → P1 error.
7. **Subscription guard** — GoRouter redirect checks `SubscriptionService.isActive` on every nav event. ⚠️ Currently removed from `routes.dart` while M2 is deferred — do not treat as a bug.

---

## Error Levels (mandatory)

| Level | Definition | UI behaviour |
|---|---|---|
| P0 | Fatal — app cannot function (auth lost, subscription check fails on launch) | Full-screen error + retry CTA |
| P1 | Blocking — user action failed, can't proceed | Modal/inline error + retry button |
| P2 | Non-blocking — action failed, user can continue | Toast/snackbar, auto-dismiss 3s |
| P3 | Silent — background read failed, fallback available | No UI. Log to Crashlytics. Show stale cache. |

### Error rules per feature
| Feature | Level | Message |
|---|---|---|
| Allergen log save fails | P1 | "Couldn't save your log. Please try again." + Retry |
| Reaction modal save fails | P1 | "Couldn't save reaction. Please try again." + Retry |
| Recipe list fetch fails | P3 | Show cached. Log to Crashlytics. |
| Meal plan assignment fails | P2 | Toast: "Couldn't add to meal plan. Try again." |
| Shopping list add fails | P2 | Toast: "Couldn't add items. Try again." |
| Shopping list delete fails | P2 | Toast: "Couldn't delete item. Try again." |
| Subscription purchase fails | P1 | Show RevenueCat error verbatim |
| Subscription restore fails | P1 | "No active subscription found." |
| Auth sign up / login fails | P1 | Show Supabase error message |
| Password update fails (AU-03) | P1 | Show Supabase error inline |
| Session refresh fails (401) | P0 | Sign out + redirect to login |
| No connectivity on write | P1 | "No internet connection. Please check and try again." |

---

## Folder Structure

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

---

## Feature Module Pattern (every feature, no exceptions)

```
<feature>/
├── <feature>_controller.dart   # AsyncNotifier / Notifier (Riverpod)
├── <feature>_state.dart        # @freezed state class
├── <feature>_screen.dart       # ConsumerWidget root screen
└── widgets/                    # sub-widgets scoped to this feature
```

### All feature paths
| Path | Screen |
|---|---|
| `splash` | Boot, session check, redirect |
| `onboarding/intro` | OB-01 + OB-02 |
| `onboarding/readiness` | OB-03 to OB-09 |
| `onboarding/baby_setup` | OB-11 to OB-13 |
| `auth/register` | Sign up |
| `auth/login` | Log in |
| `auth/forgot_password` | Forgot password |
| `auth/reset_password` | AU-03 — password reset via deep link |
| `subscription/paywall` | SB-01 |
| `home` | HM-01 Dashboard |
| `allergen/tracker` | AL-01 + AL-02 |
| `allergen/detail` | AL-03 |
| `allergen/reaction_log` | AL-06 modal |
| `allergen/complete` | AL-08 (shown once per baby) |
| `meal_plan` | MP-01 |
| `recipe/library` | RC-01 |
| `recipe/detail` | RC-02 |
| `shopping_list` | SL-01 |
| `profile` | PR-01 |
| `profile/edit` | PR-02 |

---

## Key Domain Entities
`Baby` · `Allergen` · `AllergenLog` · `AllergenBoardItem` · `AllergenProgramState` · `ReactionDetail` · `MealPlanEntry` · `ShoppingListItem` · `Recipe` · `Ingredient`

## Key Enums
- `AllergenStatus`: `notStarted` · `inProgress` · `safe` · `flagged`
  ⚠️ Use `.safe` — NEVER `.completed` — for passed allergens. This is canonical.
- `AllergenProgramStatus`: `inProgress` · `completed` · `flagged`
- `EmojiTaste`: `love` · `neutral` · `dislike`
- `Gender`: `male` · `female` · `preferNotToSay`
- `ReactionSeverity`: `mild` · `moderate` · `severe`
- `ShoppingListSource`: `recipe` · `mealPlan` · `manual`

## Allergen sequence (locked)
peanut(1) → egg(2) → dairy(3) → tree_nuts(4) → sesame(5) → soy(6) → wheat(7) → fish(8) → shellfish(9)

⚠️ sesame and soy share emoji 🫘 — flag with designer if visual distinction needed.

---

## Routing

Bottom nav — 4 tabs inside `/home` ShellRoute:
- Tab 1: `/home` — Home dashboard
- Tab 2: `/home/meal` — Meal Plan
- Tab 3: `/home/shopping-list` — Shopping List
- Tab 4: `/home/recipe` — Recipe Library

Pushed without bottom nav (full-screen on top of shell):
- `/home/allergen/tracker` — pushed from Home allergen widget
- `/home/allergen/:allergenKey` — Allergen detail
- `/home/allergen/complete` — AL-08 (shown once)
- `/home/recipe/:recipeId` — Recipe detail
- `/home/profile` — pushed from Home avatar
- `/home/profile/edit` — Edit profile

Redirect logic (GoRouter, runs on every nav event):
1. `app_has_launched` = false → `/onboarding/intro`
2. Not logged in → `/auth/login` (only auth + intro paths allowed pre-login)
3. Logged in, `onboarding_readiness_done` = false → `/onboarding/readiness`
4. Logged in, `onboarding_baby_setup_done` = false → `/onboarding/baby_setup`
5. ~~Logged in, no subscription → `/subscription/paywall`~~ — **removed, M2 deferred**
6. All good → proceed

---

## Hive Boxes
| Box | Purpose |
|---|---|
| `recipes` | Read-through cache — JSON strings |
| `allergens` | Read-through cache — JSON strings |
| `local_flags` | `app_has_launched` (bool), `onboarding_readiness_done` (bool), `onboarding_baby_setup_done` (bool), `program_completion_shown_{babyId}` (bool) |

LocalFlagService reads synchronously (boxes opened before runApp).

---

## Environments
- `dev`: `main_dev.dart` · bundle `com.aydev.nibbles.dev` · Supabase `nibbles-dev` · Firebase `nibbles-dev`
- `prod`: `main.dart` · bundle `com.aydev.nibbles` · Supabase `nibbles-prod` · Firebase `nibbles-prod`
- Keys in `.env.dev` / `.env.prod` — NOT committed, in .gitignore

---

## Code Generation

Run after any `@freezed`, `@JsonSerializable`, `@RestApi`, `@riverpod` change:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files (`*.freezed.dart`, `*.g.dart`) ARE committed to source control.

---

## Naming Conventions
- Controllers: `<feature>_controller.dart` → `class <Feature>Controller extends _$<Feature>Controller`
- States: `<feature>_state.dart` → `@freezed class <Feature>State`
- Repositories: `<feature>_repository.dart` → interface + `<Feature>RepositoryImpl`
- Services: `<feature>_service.dart` → `class <Feature>Service`
- Mappers: `<feature>_mapper.dart` → extension on DTO or standalone class
- Screens: `<feature>_screen.dart` → `class <Feature>Screen extends ConsumerWidget`

---

## Agent Roles
| Agent | Domain |
|---|---|
| `nibbles-frontend` | screens, widgets, controllers, navigation |
| `nibbles-backend` | repositories, services, Supabase queries, Hive, mappers, DTOs |
| `nibbles-infra` | flavors, Firebase, RevenueCat, deep links, runner.dart, store prep |
| `nibbles-qa` | unit tests, widget tests, integration tests |

Use these agents when implementing tickets. The linear-agent orchestrates them.

## Linear Workflow Rules

**Before working any Linear ticket**, always do this first:
1. Look up the ticket's milestone via Linear MCP.
2. Fetch all tickets in that milestone.
3. Bulk-transition any tickets still in `Backlog` → `Todo`.
4. Skip tickets already in `Todo`, `In Progress`, `Done`, or `Cancelled`.
5. Never move tickets backwards.

This applies whether starting from a single ticket (e.g. `NIB-15`) or a full milestone batch.

---

## Commit Format
`feat(scope): message` / `fix(scope): message` / `refactor(scope): message` / `chore(scope): message`

Scope = feature name: `auth` · `allergen` · `meal-plan` · `recipe` · `shopping-list` · `home` · `profile` · `infra` · `routing`

---

## Critical Don'ts
- Never call Supabase directly from Service, Controller, or Screen
- Never expose DTOs above the Repository layer
- Never store JWT in Hive
- Never throw raw exceptions from async ops — always wrap in `Result<T>`
- Never use `AllergenStatus.completed` — use `AllergenStatus.safe`
- Never add offline write queueing (out of scope for MVP 1)
- No CI/CD setup (out of scope for MVP 1)
- No staging environment (dev + prod only)
- Zero linting warnings merged to main
