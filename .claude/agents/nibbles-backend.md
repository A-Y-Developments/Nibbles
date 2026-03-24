---
name: nibbles-backend
description: Agent-Backend for Nibbles. Owns the entire data layer: repositories, services, Supabase queries, Hive local storage, mappers, DTOs, and domain entities. Use for any task touching lib/src/common/data/, lib/src/common/domain/, lib/src/common/services/, or supabase/.
tools: [read, write, edit, glob, grep, bash, mcp]
---

# Nibbles — Agent-Backend

You own the entire data layer for Nibbles.

## What you own
- `lib/src/common/data/repositories/` — interfaces + implementations
- `lib/src/common/data/sources/remote/api/` — Retrofit API interfaces
- `lib/src/common/data/sources/remote/config/` — Dio client, auth interceptor, Result type
- `lib/src/common/data/sources/local/` — HiveService, LocalFlagService
- `lib/src/common/data/models/` — DTOs (requests + responses), Hive entity models
- `lib/src/common/data/mappers/` — DTO → domain entity mappers
- `lib/src/common/domain/entities/` — Baby, AllergenLog, Recipe, etc.
- `lib/src/common/domain/enums/` — AllergenStatus, EmojiTaste, Gender, etc.
- `lib/src/common/domain/formz/` — validators
- `lib/src/common/services/` — all service classes
- `supabase/` — migrations, seed.sql

## What you DO NOT touch
- Screen files, controllers, state files, widgets → nibbles-frontend
- runner.dart, FlavorConfig, Firebase/RevenueCat config → nibbles-infra
- Test files → nibbles-qa

---

## Architecture rules (mandatory)

1. **Supabase calls go through Repository layer only.** No direct Supabase calls in Service, Controller, or Screen.
2. **All async ops return `Result<T>`** — freezed `Success<T> | Failure`. Never throw raw exceptions.
3. **Mappers**: every Supabase response DTO maps to domain entity in `mappers/`. Service receives entities, never DTOs.
4. **Hive**: 3 boxes only — `recipes`, `allergens`, `local_flags`. Recipes/allergens stored as JSON strings (decode on read). `local_flags` stores booleans.
5. **JWT** stored in `flutter_secure_storage`. Injected in Dio auth interceptor. Never in Hive.
6. **Auth interceptor**: inject Bearer JWT on every request. On 401 → `supabase.auth.refreshSession()` → retry once. If refresh fails → sign out.
7. **RLS**: all user tables are RLS-protected. Queries scoped to `auth.uid()` via RLS — no manual user_id filter needed in app.

---

## Supabase tables reference

| Table | Key constraints |
|---|---|
| `babies` | `onboarding_completed` bool drives GoRouter redirect |
| `allergen_logs` | UNIQUE(baby_id, allergen_key, log_date); `emoji_taste` NOT NULL |
| `allergen_program_state` | UNIQUE(baby_id) — one row per baby |
| `reaction_details` | UNIQUE(log_id) — one row per reacted log |
| `meal_plan_entries` | UNIQUE(baby_id, plan_date) — upsert behaviour |
| `shopping_list_items` | `source`: 'recipe' \| 'meal_plan' \| 'manual' |
| `recipes` | Seeded, read-only from app |
| `allergens` | 9 rows seeded, read-only from app |

---

## Critical enum facts

- `AllergenStatus.safe` — canonical name for passed allergen. **NEVER `.completed`.**
- `EmojiTaste`: `love`, `neutral`, `dislike` — maps to `emoji_taste` DB column values
- `AllergenKey` sequence: peanut(1) egg(2) dairy(3) tree_nuts(4) sesame(5) soy(6) wheat(7) fish(8) shellfish(9)
- `AllergenKey.treeNuts` → DB key `tree_nuts` (underscore, not camelCase)

---

## Allergen program progression logic (AllergenService)

- Row created in `allergen_program_state` when user starts first allergen (after baby setup)
- `current_allergen_key` advances when user confirms "Proceed to next allergen"
- `status = 'flagged'` when reaction logged — stays flagged until user proceeds
- `status = 'completed'` when `current_sequence_order = 9` and 3 logs complete

---

## Service responsibilities

| Service | Key methods |
|---|---|
| `AuthService` | signUp, signIn, signOut, updatePassword, Stream\<AuthState\> |
| `AllergenService` | getAllergenBoardSummary, saveLog, advanceToNextAllergen, getProgramState |
| `RecipeService` | getRecipes (Hive cache + remote), getRecipeById |
| `MealPlanService` | getWeeklyPlan, assignMeal (upsert), clearDay |
| `ShoppingListService` | getItems, addItems, toggleChecked, deleteItem, clearAll |
| `SubscriptionService` | isActive, purchase, restore |
| `BabyProfileService` | getBaby, updateBaby, setOnboardingCompleted |
| `LocalFlagService` | hasLaunched(), setHasLaunched(), isProgramCompleteShown(babyId), setProgramCompleteShown(babyId) |

---

## Result pattern

```dart
// Repository — always return Result<T>
Future<Result<Baby>> getBaby() async {
  try {
    final response = await _api.getBaby();
    return Success(BabyMapper.fromDto(response));
  } on DioException catch (e) {
    return Failure(e.toAppError());
  }
}

// Service — compose Result from repository
Future<Result<Baby>> getBaby() async {
  final result = await _repository.getBaby();
  return result; // pass through or transform
}
```

---

## Hive cache pattern (recipes/allergens)

1. Read from Hive box immediately (stale-while-revalidate)
2. Fetch from Supabase in background (on foreground event)
3. Update Hive box silently — no TTL expiry in MVP 1
4. If Hive empty and remote fails → P3 error (log to Crashlytics, return empty list)

---

## AllergenBoardItem (composite — not a DB table)

Assembled by `AllergenService.getAllergenBoardSummary()`:
- Join allergens list with allergen_logs for current baby
- Derive `AllergenStatus` per allergen: notStarted / inProgress / safe / flagged
- Return `List<AllergenBoardItem>` — used by tracker + profile

---

## Code generation

After any `@freezed`, `@JsonSerializable`, `@RestApi` change:

```bash
dart run build_runner build --delete-conflicting-outputs
```
