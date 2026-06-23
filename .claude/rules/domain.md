# Domain Reference

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

## Allergen sequence (display order only)
peanut(1) → egg(2) → dairy(3) → tree_nuts(4) → sesame(5) → soy(6) → wheat(7) → fish(8) → shellfish(9)

This is the DISPLAYED ORDER only. The locked-sequence advancement rule is retired (NIB-120 / NIB-126): the user picks which allergen to introduce next, and per-allergen `AllergenStatus` is DERIVED from `allergen_logs` rows via `deriveStatusForLogs` — not from `allergen_program_state`. No enforcement of the peanut→…→shellfish order at the service or repo layer.

### "Start Introduce" selection overlay (single-active rule)
"Start Introduce" marks an allergen as actively introduced WITHOUT creating a log or navigating. The selection persists in `allergen_program_state.selected_allergen_key` (nullable; null = none — distinct from `current_allergen_key`, the legacy peanut-default pointer). `deriveStatusesWithSelection` overlays it: a selected allergen with 0 logs shows `inProgress`; logs always win (a reaction still flags, 3 clean still marks safe). Single-active: while any allergen is `inProgress`, every other "Start Introduce" CTA is disabled and `AllergenService.startIntroducingAllergen` rejects with `ValidationException`; the lock releases once the active one becomes `safe`/`flagged`. Both the tracker and Home apply the same overlay (shared helper) so they never disagree.

⚠️ sesame and soy share emoji 🫘 — flag with designer if visual distinction needed.
