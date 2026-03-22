# Feature Paths

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

# Routing

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
2. Not logged in → `/auth/login`
3. Logged in, onboarding incomplete → `/onboarding/intro`
4. Logged in, no subscription → `/subscription/paywall`
5. All good → proceed
