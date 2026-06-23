INSERT INTO allergens (key, display_name, sequence_order) VALUES
  ('peanut',    'Peanut',    1),
  ('egg',       'Egg',       2),
  ('dairy',     'Dairy',     3),
  ('tree_nuts', 'Tree Nuts', 4),
  ('sesame',    'Sesame',    5),
  ('soy',       'Soy',       6),
  ('wheat',     'Wheat',     7),
  ('fish',      'Fish',      8),
  ('shellfish', 'Shellfish', 9)
ON CONFLICT (key) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPES (20 total — "Baby's First Nibbles" e-book, 6 categories)
-- Replaces the previous placeholder set. thumbnail_url left null (the client
-- shows a fallback image); real photos are wired separately.
-- ─────────────────────────────────────────────────────────────────────────────

DELETE FROM recipes;

INSERT INTO recipes (
  id, title, age_range, allergen_tags, ingredients, steps,
  serving_guidance, makes, category, nutrition_tags, utensils,
  storage_note, freezer_note, texture_tip, why_this_meal
) VALUES

-- ── IRON-RICH PURÉES (5) ─────────────────────────────────────────────────────

(
  'e0000000-0000-0000-0000-000000000001',
  'Beef, Sweet Potato & Bone Broth Purée',
  '6m+',
  ARRAY[]::text[],
  '[{"name":"beef mince","quantity":"80g"},{"name":"sweet potato, peeled and cut into small cubes","quantity":"120g"},{"name":"unsalted bone broth (can use water also)","quantity":"80ml"},{"name":"extra virgin olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Add the sweet potato to a small pot and cover with water. Bring to a boil over medium-high heat, then reduce to a simmer and cook for 10–12 minutes, or until very soft. Drain.',
    'While the sweet potato is cooking, heat a small frying pan over medium heat. Add the beef mince and cook for 5–6 minutes, breaking it up with a spoon until fully browned and cooked through.',
    'Add the cooked sweet potato, cooked beef, bone broth, and olive oil to a blender.',
    'Blend for 30–60 seconds until smooth. Add 1–2 extra tablespoons of warm water if you want a thinner consistency.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '2–3 small servings',
  'Iron-Rich Purées',
  ARRAY['Iron-Rich','Protein'],
  ARRAY['small pot','small frying pan','blender or stick blender','spoon'],
  'Fridge up to 48 hours in an airtight container',
  'Freeze up to 3 months in small portions',
  'For a younger baby, blend until very smooth. For a baby further along, leave it slightly thicker.',
  'Beef is one of the best sources of highly absorbable iron, and sweet potato adds gentle sweetness plus vitamin C to support iron absorption.'
),
(
  'e0000000-0000-0000-0000-000000000002',
  'Chicken Liver, Apple & Sweet Potato Purée',
  '6m+',
  ARRAY[]::text[],
  '[{"name":"chicken liver, trimmed","quantity":"70g"},{"name":"sweet potato, peeled and cubed","quantity":"100g"},{"name":"apple, peeled, cored, and chopped","quantity":"70g"},{"name":"water or unsalted bone broth","quantity":"40–60ml"},{"name":"extra virgin olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Add the sweet potato and apple to a small pot with a little water or place them in a steamer basket. Cook for 10–12 minutes, until both are very soft.',
    'Heat a small frying pan over low to medium heat. Add the chicken liver and cook for 2–3 minutes per side, until fully cooked through with no pink remaining in the centre.',
    'Add the cooked liver, sweet potato, apple, olive oil, and 40ml water or broth to a blender.',
    'Blend until smooth. Add a little more liquid if needed to reach your preferred consistency.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '2 small servings',
  'Iron-Rich Purées',
  ARRAY['Iron-Rich'],
  ARRAY['small pot or steamer','small frying pan','blender','spoon'],
  'Fridge up to 24 hours',
  'Freeze up to 2 months',
  'This works best as a smooth purée when first introducing liver.',
  'Chicken liver is extremely rich in iron and other key nutrients, making it a strong intentional addition when focusing on iron-first feeding.'
),
(
  'e0000000-0000-0000-0000-000000000003',
  'Lamb, Carrot & Olive Oil Purée',
  '6m+',
  ARRAY[]::text[],
  '[{"name":"lamb mince","quantity":"80g"},{"name":"carrot, peeled and chopped","quantity":"100g"},{"name":"warm water or unsalted bone broth","quantity":"60ml"},{"name":"extra virgin olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Steam or boil the carrot for 10–12 minutes, until very soft.',
    'Heat a small frying pan over medium heat. Add the lamb mince and cook for 5–6 minutes, breaking it up as it cooks, until fully cooked through.',
    'Add the cooked carrot, lamb, olive oil, and water or broth to a blender.',
    'Blend until smooth.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '2–3 small servings',
  'Iron-Rich Purées',
  ARRAY['Iron-Rich','Healthy Fats'],
  ARRAY['small pot or steamer','small frying pan','blender'],
  'Fridge up to 48 hours',
  'Freeze up to 3 months',
  'Add a little extra warm water for a thinner purée if needed.',
  'Lamb provides highly absorbable iron, while olive oil adds healthy fats to help make the meal more energy-dense.'
),
(
  'e0000000-0000-0000-0000-000000000004',
  'Sardine, Potato & Parsley Mash',
  '6m+',
  ARRAY['fish'],
  '[{"name":"white potato, peeled and chopped","quantity":"120g"},{"name":"canned sardines in spring water, drained well and checked for larger bones","quantity":"60g"},{"name":"finely chopped parsley","quantity":"1 tsp"},{"name":"extra virgin olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Add the potato to a small pot, cover with water, and bring to a boil. Reduce to a simmer and cook for 10–12 minutes, until very soft. Drain.',
    'Place the cooked potato in a bowl and mash thoroughly with a fork.',
    'Add the sardines, parsley, and olive oil. Mash and mix until well combined.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '2 small servings',
  'Iron-Rich Purées',
  ARRAY['Iron-Rich','Omega-3'],
  ARRAY['small pot or steamer','bowl','fork'],
  'Fridge up to 24 hours',
  'Freeze up to 2 months',
  'Keep it smooth and soft at first, then gradually leave a few soft lumps as your baby gets more confident.',
  'Sardines provide iron, omega-3 fats, and soft texture in one simple meal.'
),
(
  'e0000000-0000-0000-0000-000000000005',
  'Slow-Cooked Lamb, Pumpkin & Zucchini Purée',
  '6m+',
  ARRAY[]::text[],
  '[{"name":"lamb shoulder or lamb leg, cut into small cubes","quantity":"180g"},{"name":"pumpkin, peeled and cubed","quantity":"150g"},{"name":"zucchini, chopped","quantity":"80g"},{"name":"water or unsalted bone broth","quantity":"250ml"},{"name":"extra virgin olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Add the lamb, pumpkin, zucchini, and water or broth to the slow cooker.',
    'Cook on LOW for 6–7 hours or HIGH for 3–4 hours, until the lamb is very tender and the vegetables are soft.',
    'Use a spoon to transfer the lamb and vegetables to a blender. Add 60–80ml of the cooking liquid and olive oil.',
    'Blend until smooth. Add extra cooking liquid as needed until you get a silky purée.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '3–4 small servings',
  'Iron-Rich Purées',
  ARRAY['Iron-Rich','Protein'],
  ARRAY['small cooker','blender','spoon','chopping board','knife'],
  'Fridge up to 48 hours',
  'Freeze up to 3 months',
  'This recipe blends beautifully and becomes very soft, making it ideal for babies early in their solids journey.',
  'Slow-cooking makes the lamb incredibly tender while keeping the meal rich in highly absorbable iron and easy to digest.'
),

-- ── WHIPPED BONE MARROW (1) ──────────────────────────────────────────────────

(
  'e0000000-0000-0000-0000-000000000006',
  'Whipped Bone Marrow',
  '6m+',
  ARRAY[]::text[],
  '[{"name":"marrow bones, split lengthways or canoe-cut","quantity":"3"},{"name":"extra virgin olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Preheat the oven to 200ºC.',
    'Place the marrow bones cut-side up on a baking tray.',
    'Roast for 15–18 minutes, until the marrow is soft and loosened.',
    'Allow to cool for 5 minutes, then scoop the marrow out with a spoon.',
    'Add the marrow and olive oil to a small blender and blend for 20–30 seconds until smooth and whipped.'
  ],
  'Stir ½–1 teaspoon through warm purées, mashes, or soft finger foods.',
  'About 8–10 teaspoons',
  'Whipped Bone Marrow',
  ARRAY['Healthy Fats','Energy-Dense'],
  ARRAY['oven','baking tray','spoon','small blender or mini food processor'],
  'Fridge up to 3 days',
  'Freeze up to 3 months in small portions',
  null,
  'This is an easy way to enrich meals with energy-dense fats when feeding with intention.'
),

-- ── IRON-RICH FINGER FOODS (5) ───────────────────────────────────────────────

(
  'e0000000-0000-0000-0000-000000000007',
  'Chicken Liver, Apple & Sweet Potato Patties',
  '6m+',
  ARRAY['egg','wheat','dairy'],
  '[{"name":"chicken liver","quantity":"100g"},{"name":"sweet potato, peeled and cubed","quantity":"120g"},{"name":"apple, peeled and finely grated","quantity":"60g"},{"name":"egg","quantity":"1"},{"name":"oat flour","quantity":"2 tbsp"},{"name":"olive oil or butter for the pan","quantity":"1 tsp"}]',
  ARRAY[
    'Boil or steam the sweet potato for 10–12 minutes until very soft. Mash well in a bowl.',
    'Heat a frying pan over low to medium heat and cook the chicken liver for 2–3 minutes per side, until fully cooked. Mash finely with a fork or chop very finely.',
    'Add the cooked liver, mashed sweet potato, grated apple, egg, and oat flour to a bowl. Mix until combined.',
    'Heat a lightly greased frying pan over low heat.',
    'Spoon small amounts of mixture into the pan and flatten gently into patties.',
    'Cook for 3–4 minutes on the first side, then flip carefully and cook for another 3 minutes, until set and lightly golden.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '6–8 small patties',
  'Iron-Rich Finger Foods',
  ARRAY['Iron-Rich','Finger Food'],
  ARRAY['small pot','frying pan','mixing bowl','fork or masher','spoon'],
  'Fridge up to 2 days',
  'Freeze up to 2 months',
  'Keep them small and soft so they''re easy for baby to hold and gum.',
  'This is one of the strongest iron-focused meals in the book and a practical way to include liver without making it feel over the top.'
),
(
  'e0000000-0000-0000-0000-000000000008',
  'Sardine, Potato & Parsley Patties',
  '6m+',
  ARRAY['fish','wheat','egg'],
  '[{"name":"canned sardines in spring water, drained","quantity":"200g"},{"name":"white potato, peeled and chopped","quantity":"150g"},{"name":"egg","quantity":"1"},{"name":"oat flour","quantity":"2 tbsp"},{"name":"finely chopped parsley","quantity":"1 tbsp"},{"name":"olive oil for the pan","quantity":"1 tsp"}]',
  ARRAY[
    'Boil the potato for 10–12 minutes until very soft. Drain and mash in a bowl.',
    'Add the sardines and mash them into the potato.',
    'Add the egg, oat flour, and parsley. Mix well.',
    'Heat a lightly oiled frying pan over low to medium heat.',
    'Form the mixture into small patties.',
    'Cook for 3–4 minutes on each side until lightly golden and cooked through.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '6 small patties',
  'Iron-Rich Finger Foods',
  ARRAY['Iron-Rich','Omega-3','Finger Food'],
  ARRAY['small pot','bowl','fork','frying pan'],
  'Fridge up to 2 days',
  'Freeze up to 2 months',
  'They should stay soft in the middle. Let them cool fully before serving.',
  'A simple way to give baby iron, omega-3 fats, and a soft finger food texture in one.'
),
(
  'e0000000-0000-0000-0000-000000000009',
  'Barramundi, Zucchini & Dill Fritters',
  '6m+',
  ARRAY['fish','wheat','egg'],
  '[{"name":"barramundi fillet","quantity":"200g"},{"name":"zucchini, grated","quantity":"100g"},{"name":"egg","quantity":"1"},{"name":"plain flour or oat flour","quantity":"2 tbsp"},{"name":"finely chopped dill","quantity":"1 tsp"},{"name":"olive oil for cooking","quantity":"1 tsp"}]',
  ARRAY[
    'Cook the barramundi first. Heat a frying pan over medium heat and cook the fillet for 3–4 minutes per side, until fully cooked and flaky. Let cool slightly, then flake finely.',
    'Squeeze excess moisture out of the grated zucchini using your hands or a clean tea towel.',
    'In a bowl, combine the flaked barramundi, zucchini, egg, flour, and dill. Mix well.',
    'Heat a lightly oiled pan over low to medium heat.',
    'Spoon in small portions of the mixture and flatten gently.',
    'Cook for 3 minutes on each side until firm and lightly golden.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '6–7 small fritters',
  'Iron-Rich Finger Foods',
  ARRAY['Protein','Finger Food'],
  ARRAY['small frying pan','bowl','grater','spoon'],
  'Fridge up to 2 days',
  'Freeze up to 2 months',
  'These should be soft and moist inside, not dry.',
  'Barramundi gives quality protein and fish-based nutrients in a very baby-friendly format.'
),
(
  'e0000000-0000-0000-0000-000000000010',
  'Beef, Potato & Mozzarella Balls',
  '6m+',
  ARRAY['wheat','dairy'],
  '[{"name":"beef mince","quantity":"150g"},{"name":"white potato, peeled and cubed","quantity":"120g"},{"name":"mozzarella, finely grated","quantity":"40g"},{"name":"oat flour","quantity":"1 tbsp"}]',
  ARRAY[
    'Preheat oven to 180ºC. Line a baking tray with baking paper.',
    'Boil the potato for 10–12 minutes until soft. Drain and mash well.',
    'Add the beef mince, mashed potato, mozzarella, and oat flour to a bowl. Mix thoroughly.',
    'Roll into small balls, about walnut size or smaller.',
    'Place on the tray and bake for 14–16 minutes, turning once halfway, until cooked through.',
    'Air fryer option: cook at 180ºC for 10–12 minutes.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '8 small balls',
  'Iron-Rich Finger Foods',
  ARRAY['Iron-Rich','Finger Food'],
  ARRAY['small pot','mixing bowl','oven or air fryer','baking tray'],
  'Fridge up to 2 days',
  'Freeze up to 3 months',
  'These should be soft inside and easy to squash between fingers.',
  'Beef supports iron intake, while mozzarella and potato make the meal more energy-dense for growing babies.'
),
(
  'e0000000-0000-0000-0000-000000000011',
  'Lamb & Pumpkin Soft Koftas',
  '6m+',
  ARRAY['wheat'],
  '[{"name":"lamb mince","quantity":"150g"},{"name":"pumpkin, peeled and cubed","quantity":"120g"},{"name":"oat flour","quantity":"1 tbsp"},{"name":"olive oil for cooking","quantity":"1 tsp"}]',
  ARRAY[
    'Boil or steam the pumpkin for 10–12 minutes until soft. Drain and mash well.',
    'Add the lamb mince, mashed pumpkin, and oat flour to a bowl. Mix until combined.',
    'Shape into small koftas or short finger-shaped pieces.',
    'Heat a lightly oiled frying pan over low to medium heat.',
    'Cook the koftas for 3–4 minutes per side, turning until browned lightly and fully cooked through.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '6–8 mini koftas',
  'Iron-Rich Finger Foods',
  ARRAY['Iron-Rich','Finger Food'],
  ARRAY['small pot','bowl','frying pan'],
  'Fridge up to 2 days',
  'Freeze up to 3 months',
  'These should stay soft and tender, not firm or dry.',
  'Lamb is a strong iron source, and pumpkin makes the texture naturally softer and more baby-friendly.'
),

-- ── STOOL-SOFTENING MEALS (3) ────────────────────────────────────────────────

(
  'e0000000-0000-0000-0000-000000000012',
  'Pear, Oat & Cinnamon Mash',
  '6m+',
  ARRAY['wheat'],
  '[{"name":"ripe pear, peeled, cored, and chopped","quantity":"1"},{"name":"rolled oats","quantity":"2 tbsp"},{"name":"water","quantity":"80ml"},{"name":"cinnamon","quantity":"small pinch"}]',
  ARRAY[
    'Add the pear, oats, and water to a small pot.',
    'Bring to a gentle simmer over medium heat.',
    'Cook for 8–10 minutes, stirring occasionally, until the pear is soft and the oats are cooked.',
    'Mash with a fork until soft and spoonable. Stir through the cinnamon.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '2 servings',
  'Stool-Softening Meals',
  ARRAY['Fibre','Digestion'],
  ARRAY['small pot','fork or masher'],
  'Fridge up to 2 days',
  'Freeze up to 2 months',
  'Add a splash of warm water if it thickens too much.',
  'Pear and oats provide gentle fibre to help support digestion.'
),
(
  'e0000000-0000-0000-0000-000000000013',
  'Prune, Apple & Chia Blend',
  '6m+',
  ARRAY[]::text[],
  '[{"name":"prunes","quantity":"4"},{"name":"apple, peeled and chopped","quantity":"80g"},{"name":"chia seeds","quantity":"1 tsp"},{"name":"warm water","quantity":"60ml"}]',
  ARRAY[
    'Place the prunes in a bowl with the warm water and soak for 10 minutes.',
    'Add the soaked prunes, soaking water, apple, and chia seeds to a blender.',
    'Blend until smooth.',
    'Let sit for 5 minutes so the chia softens further.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '2 servings',
  'Stool-Softening Meals',
  ARRAY['Fibre','Digestion'],
  ARRAY['small bowl','blender'],
  'Fridge up to 2 days',
  'Freeze up to 2 months',
  'This works best smooth.',
  'Prunes and chia are practical ingredients to support bowel regularity when baby seems a little backed up.'
),
(
  'e0000000-0000-0000-0000-000000000014',
  'Sweet Potato, Lentil & Olive Oil Mash',
  '6m+',
  ARRAY[]::text[],
  '[{"name":"sweet potato, peeled and cubed","quantity":"120g"},{"name":"red lentils","quantity":"2 tbsp"},{"name":"water","quantity":"200ml"},{"name":"extra virgin olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Add the sweet potato, lentils, and water to a small pot.',
    'Bring to a boil, then reduce to a simmer.',
    'Cook for 12–15 minutes, until the sweet potato is very soft and the lentils have broken down.',
    'Drain any excess water if needed.',
    'Mash well with a fork and stir through the olive oil.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '2 servings',
  'Stool-Softening Meals',
  ARRAY['Fibre','Healthy Fats'],
  ARRAY['small pot','fork or masher'],
  'Fridge up to 2 days',
  'Freeze up to 3 months',
  'Mash until soft and spoonable, or blend for a smoother texture.',
  'This meal combines fibre and healthy fats in a simple way to support digestion.'
),

-- ── 10-MINUTE MEALS (MINIMAL PREP) (3) ───────────────────────────────────────

(
  'e0000000-0000-0000-0000-000000000015',
  'Scrambled Egg & Avocado Mash',
  '6m+',
  ARRAY['egg','dairy'],
  '[{"name":"egg","quantity":"1"},{"name":"avocado","quantity":"½"},{"name":"butter or olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Crack the egg into a bowl and whisk lightly with a fork.',
    'Heat a small frying pan over low heat and add the butter or olive oil.',
    'Pour in the egg and cook gently for 2–3 minutes, stirring slowly until softly scrambled.',
    'Mash the avocado in a bowl.',
    'Serve the scrambled egg mixed into the avocado or side by side.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '1–2 small servings',
  '10-Minute Meals (Minimal Prep)',
  ARRAY['Quick','Healthy Fats','Protein'],
  ARRAY['small frying pan','bowl','fork','spatula'],
  'Best served fresh, or fridge up to 24 hours',
  'Not recommended',
  'Keep the egg soft, not dry.',
  'Quick, easy, and full of healthy fats and protein when you need something fast but still intentional.'
),
(
  'e0000000-0000-0000-0000-000000000016',
  'Quick Beef & Zucchini Bowl',
  '6m+',
  ARRAY[]::text[],
  '[{"name":"beef mince","quantity":"80g"},{"name":"small zucchini, finely grated","quantity":"½"},{"name":"olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Heat a frying pan over medium heat.',
    'Add the beef mince and cook for 4–5 minutes until browned.',
    'Add the grated zucchini and cook for another 2–3 minutes until softened.',
    'Stir through the olive oil and let it cool before serving.',
    'Be sure to blend all ingredients to a suitable consistency for your baby.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '1–2 small servings',
  '10-Minute Meals (Minimal Prep)',
  ARRAY['Quick','Iron-Rich'],
  ARRAY['small frying pan','grater','spoon','bowl'],
  'Fridge up to 24 hours',
  'Freeze up to 2 months',
  'The zucchini keeps the mixture softer and more moist.',
  'A realistic, fast iron-rich option for busy days.'
),
(
  'e0000000-0000-0000-0000-000000000017',
  'Soft Salmon & Sweet Potato Bowl',
  '6m+',
  ARRAY['fish'],
  '[{"name":"salmon fillet","quantity":"80g"},{"name":"sweet potato, peeled and cubed","quantity":"100g"},{"name":"olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Cook the sweet potato in the microwave with a splash of water for 5–6 minutes, or steam until soft.',
    'While that cooks, heat a frying pan over medium heat and cook the salmon for 3–4 minutes per side, until fully cooked.',
    'Mash the sweet potato in a bowl, flake the salmon finely, and mix together with olive oil.',
    'Be sure to blend all ingredients to a suitable consistency for your baby.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '1–2 small servings',
  '10-Minute Meals (Minimal Prep)',
  ARRAY['Quick','Omega-3'],
  ARRAY['microwave or steamer','small frying pan','bowl','fork'],
  'Fridge up to 24 hours',
  'Freeze up to 2 months',
  'Keep the salmon in very soft flakes and mix well through the mash.',
  'Salmon adds healthy fats and protein, while sweet potato keeps the meal soft and easy to eat.'
),

-- ── HIGH-ENERGY MEALS FOR SMALL APPETITES (3) ────────────────────────────────

(
  'e0000000-0000-0000-0000-000000000018',
  'Beef & Ghee Mini Mash',
  '6m+',
  ARRAY['dairy'],
  '[{"name":"beef mince","quantity":"80g"},{"name":"white potato, peeled and cubed","quantity":"100g"},{"name":"ghee","quantity":"1 tsp"}]',
  ARRAY[
    'Boil the potato for 10–12 minutes until very soft. Drain and mash well.',
    'Heat a frying pan over medium heat and cook the beef for 5–6 minutes until fully browned.',
    'Mix the cooked beef through the mashed potato and stir in the ghee.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '2 servings',
  'High-Energy Meals for Small Appetites',
  ARRAY['Energy-Dense','Iron-Rich'],
  ARRAY['small frying pan','small pot','bowl','fork'],
  'Fridge up to 2 days',
  'Freeze up to 3 months',
  'Mash more thoroughly for an earlier stage baby.',
  'A simple way to combine iron and extra energy in one easy meal for babies who don''t eat big volumes.'
),
(
  'e0000000-0000-0000-0000-000000000019',
  'Salmon, Avocado & Olive Oil Bowl',
  '6m+',
  ARRAY['fish'],
  '[{"name":"salmon fillet","quantity":"80g"},{"name":"avocado","quantity":"½"},{"name":"extra virgin olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Heat a frying pan over medium heat and cook the salmon for 3–4 minutes per side until fully cooked.',
    'Flake the salmon well with a fork.',
    'Mash the avocado in a bowl.',
    'Add the salmon and olive oil and mix gently.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '1 small serving',
  'High-Energy Meals for Small Appetites',
  ARRAY['Energy-Dense','Healthy Fats','Omega-3'],
  ARRAY['small frying pan','bowl','fork'],
  'Fridge up to 24 hours',
  'Not recommended',
  'This should stay very soft and creamy.',
  'High in healthy fats, this is a great option when you want more calories packed into a smaller amount of food.'
),
(
  'e0000000-0000-0000-0000-000000000020',
  'Egg, Ricotta & Butter Soft Scramble',
  '6m+',
  ARRAY['egg','dairy'],
  '[{"name":"egg","quantity":"1"},{"name":"ricotta","quantity":"1 tbsp"},{"name":"butter","quantity":"1 tsp"}]',
  ARRAY[
    'Crack the egg into a bowl and whisk lightly.',
    'Heat a small frying pan over low heat and add the butter.',
    'Pour in the egg and cook gently for 2 minutes, stirring slowly.',
    'Just before it''s done, stir through the ricotta and cook for another 30–60 seconds until soft and creamy.'
  ],
  'Serve at a texture suitable for your baby''s stage.',
  '1 small serving',
  'High-Energy Meals for Small Appetites',
  ARRAY['Energy-Dense','Protein'],
  ARRAY['small frying pan','bowl','fork','spatula'],
  'Best served fresh, or fridge up to 24 hours',
  'Not recommended',
  'Keep it loose and soft rather than fully set.',
  'This is soft, energy-dense, and easy to eat for babies who do better with smaller, richer meals.'
)

ON CONFLICT (id) DO NOTHING;
