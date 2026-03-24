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

## Allergen sequence (locked)
peanut(1) → egg(2) → dairy(3) → tree_nuts(4) → sesame(5) → soy(6) → wheat(7) → fish(8) → shellfish(9)

⚠️ sesame and soy share emoji 🫘 — flag with designer if visual distinction needed.
