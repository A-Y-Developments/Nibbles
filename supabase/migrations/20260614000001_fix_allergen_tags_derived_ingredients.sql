-- NIB-181: seed recipes under-tagged allergens entering via a processed/derived
-- ingredient (butter/milk/cream cheese -> dairy, sesame oil -> sesame,
-- soy sauce -> soy). Whole-food allergens were already tagged correctly.
-- Idempotent: each UPDATE only touches rows still missing the tag.

UPDATE recipes SET allergen_tags = array_append(allergen_tags, 'dairy')
WHERE title IN (
  'Soft Scrambled Eggs', 'French Omelette Fingers', 'Soft Bread Fingers',
  'Whole Wheat Banana Pancakes', 'Buttery Soft Pasta', 'Tuna Pasta',
  'Soft Shrimp Noodles'
) AND NOT ('dairy' = ANY(allergen_tags));

UPDATE recipes SET allergen_tags = array_append(allergen_tags, 'sesame')
WHERE title IN ('Egg Fried Rice', 'Tofu Veggie Stir-Fry Puree')
  AND NOT ('sesame' = ANY(allergen_tags));

UPDATE recipes SET allergen_tags = array_append(allergen_tags, 'soy')
WHERE title = 'Peanut Noodles'
  AND NOT ('soy' = ANY(allergen_tags));
