# Routing

## Bottom nav — 4 tabs inside `/home` ShellRoute
- Tab 1: `/home` — Home dashboard
- Tab 2: `/home/meal` — Meal Plan
- Tab 3: `/home/shopping-list` — Shopping List
- Tab 4: `/home/recipe` — Recipe Library

## Full-screen pushes (no bottom nav)
- `/home/allergen/tracker` — pushed from Home allergen widget
- `/home/allergen/:allergenKey` — Allergen detail
- `/home/allergen/complete` — AL-08 (shown once)
- `/home/recipe/:recipeId` — Recipe detail
- `/home/profile` — pushed from Home avatar
- `/home/profile/edit` — Edit profile

## Redirect logic (GoRouter, runs on every nav event)
1. `app_has_launched` = false → `/onboarding/intro`
2. Not logged in → `/auth/login` (only auth + intro paths allowed pre-login)
3. Logged in, `onboarding_readiness_done` = false → `/onboarding/readiness`
4. Logged in, `onboarding_baby_setup_done` = false → `/onboarding/baby_setup`
5. ~~Logged in, no subscription → `/subscription/paywall`~~ — **removed, M2 deferred**
6. All good → proceed

## Hive Boxes

| Box | Purpose |
|---|---|
| `recipes` | Read-through cache — JSON strings |
| `allergens` | Read-through cache — JSON strings |
| `local_flags` | `app_has_launched` (bool), `onboarding_readiness_done` (bool), `onboarding_baby_setup_done` (bool), `program_completion_shown_{babyId}` (bool) |

LocalFlagService reads synchronously (boxes opened before runApp).

## Environments
- `dev`: `main_dev.dart` · bundle `com.aydev.nibbles.dev` · Supabase `nibbles-dev` · Firebase `nibbles-dev`
- `prod`: `main.dart` · bundle `com.aydev.nibbles` · Supabase `nibbles-prod` · Firebase `nibbles-prod`
- Keys in `.env.dev` / `.env.prod` — NOT committed, in .gitignore
