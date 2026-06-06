-- Recipe Detail fields: surface the Utensils / Storage / Texture-Tip /
-- Why-this-meal sections on RC-02 (UI already built but data-starved).
--
-- utensils:      text[] of utensils / appliances (e.g. {'Spoon','Steamer'}).
-- storage_note:  fridge storage guidance copy.
-- freezer_note:  freezer storage guidance copy.
-- texture_tip:   "Texture Tip" body copy.
-- why_this_meal: "Why this meal" body copy.
--
-- All nullable for back-compat — legacy rows have null and the client
-- conditionally hides each section. Per-recipe CONTENT is populated
-- separately by the owner.

ALTER TABLE recipes
  ADD COLUMN IF NOT EXISTS utensils TEXT[],
  ADD COLUMN IF NOT EXISTS storage_note TEXT,
  ADD COLUMN IF NOT EXISTS freezer_note TEXT,
  ADD COLUMN IF NOT EXISTS texture_tip TEXT,
  ADD COLUMN IF NOT EXISTS why_this_meal TEXT;
