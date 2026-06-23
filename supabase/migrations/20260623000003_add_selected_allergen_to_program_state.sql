-- "Start Introduce" marks an allergen as actively being introduced without
-- creating a log yet. current_allergen_key defaults to 'peanut' (legacy
-- sequence pointer) so it cannot represent "nothing selected". A dedicated
-- nullable column does: NULL = no active introduction.
ALTER TABLE allergen_program_state
  ADD COLUMN IF NOT EXISTS selected_allergen_key TEXT NULL
    REFERENCES allergens(key);
