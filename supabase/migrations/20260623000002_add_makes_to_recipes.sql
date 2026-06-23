-- Recipe yield ("Makes: X servings") shown in the ebook header of every recipe.
-- Nullable for back-compat — legacy rows have null and the client hides it.

ALTER TABLE recipes ADD COLUMN IF NOT EXISTS makes TEXT;
