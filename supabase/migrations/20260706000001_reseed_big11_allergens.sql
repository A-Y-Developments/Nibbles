-- Reseed the allergen reference table to the Big 11 (allergen tracker redesign).
--
-- The old set was 9 keys (peanut, egg, dairy, tree_nuts, sesame, soy, wheat,
-- fish, shellfish). The redesign tracks 11 individual allergens in a new
-- display order. `allergen_logs.allergen_key` and
-- `allergen_program_state.current_allergen_key` both FK-reference
-- `allergens.key` (NO ACTION on delete), so dependent rows must be cleared
-- before the reference set can be replaced.
--
-- Pre-launch: existing logs / program state are test-only data and safe to
-- wipe (confirmed by product owner).

-- 1. Clear dependent rows that reference the old allergen keys.
DELETE FROM allergen_logs;          -- cascade-deletes reaction_details
DELETE FROM allergen_program_state; -- current_allergen_key is NOT NULL FK

-- 2. Replace the reference set with the Big 11 (display / sequence order).
DELETE FROM allergens;
INSERT INTO allergens (key, display_name, sequence_order) VALUES
  ('milk',    'Milk',    1),
  ('walnut',  'Walnut',  2),
  ('peanut',  'Peanut',  3),
  ('egg',     'Egg',     4),
  ('cashew',  'Cashew',  5),
  ('wheat',   'Wheat',   6),
  ('prawn',   'Prawn',   7),
  ('fish',    'Fish',    8),
  ('sesame',  'Sesame',  9),
  ('soybean', 'Soybean', 10),
  ('almond',  'Almond',  11);

-- 3. Recreate a default program-state row for any existing baby so the app
--    never observes a missing state after the wipe. current_allergen_key is
--    a legacy sequence pointer (status is log-derived per NIB-120); 'peanut'
--    mirrors create_baby_with_program's default and is a valid FK.
INSERT INTO allergen_program_state (
  baby_id, current_allergen_key, current_sequence_order, status
)
SELECT id, 'peanut', 1, 'in_progress' FROM babies
ON CONFLICT (baby_id) DO NOTHING;
