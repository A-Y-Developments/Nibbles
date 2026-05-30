-- NIB-129: Extend recipes with nutrition_tags + category (per NIB-120 locked decisions).
--
-- nutrition_tags: ad-hoc tag groups consumed by NIB-87 Browse Meal sheet and
-- Starting Guide-style sections (e.g. 'Iron-rich Purees', 'Quick weekday meals').
-- Distinct from allergen_tags, which lists allergens a recipe contains.
--
-- category: single top-level grouping for NIB-53 horizontal category rows
-- (e.g. 'Purees', 'Finger Foods', 'Toddler Meals', 'Soups', 'Snacks').
-- Nullable for back-compat — legacy rows have null and fall into the 'Other'
-- bucket on the client.

ALTER TABLE recipes
  ADD COLUMN IF NOT EXISTS nutrition_tags TEXT[] NOT NULL DEFAULT '{}';

ALTER TABLE recipes
  ADD COLUMN IF NOT EXISTS category TEXT;
