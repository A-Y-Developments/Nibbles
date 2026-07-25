-- Display-name only: "Milk" -> "Dairy" on the Big 11 reference row.
--
-- The `milk` KEY is deliberately left alone. It is referenced by
-- allergen_logs.allergen_key, allergen_program_state.current_allergen_key /
-- selected_allergen_key (all FKs), the `/home/allergen/:allergenKey` route,
-- and the bundled icon assets (assets/icons/allergen/*, allergen_milk.png).
-- Renaming the key would need an FK-wide migration plus asset renames for no
-- user-visible gain — the label is what the copy change asked for.

UPDATE allergens SET display_name = 'Dairy' WHERE key = 'milk';
