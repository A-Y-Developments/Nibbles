# Nibbles — Project Context

## What it is
Guided baby solids app. Helps parents introduce allergens confidently via structured journey (9 allergens × 3 days each), meal planning, curated recipes, and reaction logging.

Flutter (iOS 15+ / Android 10+) · Supabase (Auth + Postgres + RLS) · RevenueCat · flutter_riverpod · go_router · Hive · Firebase Crashlytics + Analytics

---

## Linear
- Project: **Nibbles MVP 1** (`772b82b9-9a24-4d1a-b448-e1cf4d63f31b`)
- Team: **NIB**
- Target: **2026-06-05**
- Figma Design: https://www.figma.com/design/ASB9HZLodbzJCo5bjkqjy6/Baby-s-Nutrition-App
- FigJam: https://www.figma.com/board/kV8yFEO7dchPLUnbnkkGvA/Research-and-plan---baby-s-nutrition

---

## Milestones
| # | Milestone | Target |
|---|---|---|
| M0 | Project Setup & Infrastructure | 2026-03-27 |
| M1 | Auth & Onboarding | 2026-04-10 |
| M2 | Paywall & Subscription | 2026-04-17 |
| M3 | Allergen Program (core feature) | 2026-05-01 |
| M4 | Recipes, Meal Plan & Shopping List | 2026-05-15 |
| M5 | Home Dashboard & Profile | 2026-05-22 |
| M6 | QA & Release | 2026-06-05 |

---

## Architecture
```
Screen (ConsumerWidget)
  └── Controller (AsyncNotifier)
        └── Service
              └── Repository
                    ├── Remote: Retrofit → Dio → Supabase REST
                    └── Local: Hive (recipes/allergens cache + local flags)
```

All async ops return `Result<T>` (freezed Success | Failure). No raw throws in UI.
Mappers: DTO → entity before Service. UI never touches DTOs.
Supabase: Repository layer only.

---

## Key Directories
```
lib/src/
  app/config/        # FlavorConfig (dev/prod), AppConfig
  app/constants/     # AllergenEmoji, HiveBoxNames, symptom presets
  app/runner.dart    # Bootstrap: Firebase → RevenueCat → Supabase → Hive → runApp
  app/themes/        # AppTheme, colors, typography (Nunito font)
  common/data/       # DTOs, repositories, mappers, Hive/remote sources
  common/domain/     # entities, enums, formz validators
  common/services/   # AuthService, AllergenService, RecipeService, etc.
  features/          # <feature>_screen + _controller + _state + widgets/
  routing/           # GoRouter: routes.dart, route_enums.dart, routes/
  logging/           # Analytics wrapper (no PII)
```

---

## Supabase Tables
| Table | Notes |
|---|---|
| `babies` | `onboarding_completed` bool drives redirect |
| `allergen_logs` | UNIQUE(baby_id, allergen_key, log_date); `emoji_taste` NOT NULL |
| `allergen_program_state` | UNIQUE(baby_id) — single source of truth for current allergen |
| `reaction_details` | UNIQUE(log_id) — one row per reacted log |
| `meal_plan_entries` | UNIQUE(baby_id, plan_date) |
| `shopping_list_items` | source: recipe/meal_plan/manual |
| `recipes` | Seeded, read-only from app |
| `allergens` | 9 rows seeded, read-only from app |

RLS enabled on all tables. All user data scoped to `auth.uid()` automatically.

---

## Hive Boxes
| Box | Purpose |
|---|---|
| `recipes` | Read-through cache (JSON strings, refreshed on foreground) |
| `allergens` | Read-through cache |
| `local_flags` | `app_has_launched`, `program_completion_shown_{babyId}` |

---

## Navigation (GoRouter)
```
/                              → Splash
/onboarding/intro|readiness|baby-setup
/auth/register|login|forgot-password|reset-password
/subscription/paywall
/home (ShellRoute — 4 tabs)
  /              → Home [Tab 1]
  /meal          → Meal Plan [Tab 2]
  /shopping-list → Shopping List [Tab 3]
  /recipe        → Recipe Library [Tab 4]
    /:recipeId   → Recipe Detail (no bottom nav)
/home/allergen/tracker|/:allergenKey|/complete  (no bottom nav)
/home/profile|/edit  (no bottom nav)
```

Redirect order: app_has_launched → isLoggedIn → onboardingComplete → isSubscribed → proceed

---

## Allergens (9 — introduction order)
peanut(1) → egg(2) → dairy(3) → tree_nuts(4) → sesame(5) → soy(6) → wheat(7) → fish(8) → shellfish(9)

`AllergenStatus.safe` = passed allergen. NEVER `.completed`.

---

## Environments
- `dev`: com.aydev.nibbles.dev / nibbles-dev Supabase + Firebase
- `prod`: com.aydev.nibbles / nibbles-prod Supabase + Firebase
- Keys in `.env.dev` / `.env.prod` (not committed)

---

## Agent Roles
| Agent | Domain |
|---|---|
| `nibbles-frontend` | screens, widgets, controllers, routing |
| `nibbles-backend` | repositories, services, Supabase, Hive, mappers |
| `nibbles-infra` | flavors, Firebase, RevenueCat, deep links, runner |
| `nibbles-qa` | unit / widget / integration tests |
