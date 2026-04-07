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
-- RECIPES (57 total — covers all 9 allergens + allergen-free options)
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO recipes (id, title, age_range, allergen_tags, ingredients, steps, serving_guidance, notes) VALUES

-- ── PEANUT (10) ──────────────────────────────────────────────────────────────

(
  'a0000001-0000-0000-0000-000000000001',
  'Peanut Butter Banana Puree',
  '6+ months',
  ARRAY['peanut'],
  '[{"name":"ripe banana","quantity":"1 medium"},{"name":"smooth peanut butter","quantity":"1 tsp"},{"name":"breast milk or formula","quantity":"1–2 tbsp"}]',
  ARRAY[
    'Peel and slice the banana.',
    'Blend banana with peanut butter until smooth.',
    'Add breast milk or formula to reach desired consistency.'
  ],
  'Serve chilled or at room temperature on a spoon or preloaded spoon.',
  'Use smooth, no-added-sugar peanut butter. Thin further for first introduction.'
),
(
  'a0000001-0000-0000-0000-000000000002',
  'Peanut Butter Sweet Potato Mash',
  '6+ months',
  ARRAY['peanut'],
  '[{"name":"sweet potato","quantity":"1 small"},{"name":"smooth peanut butter","quantity":"1 tsp"},{"name":"water or formula","quantity":"2 tbsp"}]',
  ARRAY[
    'Peel and cube sweet potato.',
    'Steam for 12–15 minutes until very soft.',
    'Mash with peanut butter and water until smooth.'
  ],
  'Serve warm on a spoon.',
  'Sweet potato masks the peanut taste well — good for first introduction.'
),
(
  'a0000001-0000-0000-0000-000000000003',
  'Peanut Butter Apple Sauce',
  '6+ months',
  ARRAY['peanut'],
  '[{"name":"apple","quantity":"1 medium"},{"name":"smooth peanut butter","quantity":"1 tsp"}]',
  ARRAY[
    'Peel, core, and dice the apple.',
    'Cook in a small saucepan with 2 tbsp water for 8–10 minutes until soft.',
    'Blend until smooth, then stir in peanut butter.'
  ],
  'Serve at room temperature.',
  NULL
),
(
  'a0000001-0000-0000-0000-000000000004',
  'Peanut Oat Porridge',
  '6+ months',
  ARRAY['peanut'],
  '[{"name":"rolled oats","quantity":"3 tbsp"},{"name":"water or formula","quantity":"150 ml"},{"name":"smooth peanut butter","quantity":"1 tsp"}]',
  ARRAY[
    'Cook oats with liquid over medium heat for 5 minutes, stirring constantly.',
    'Remove from heat and stir in peanut butter.',
    'Allow to cool to lukewarm.'
  ],
  'Serve warm. Thin with extra formula if needed.',
  NULL
),
(
  'a0000001-0000-0000-0000-000000000005',
  'Peanut Butter Avocado Mash',
  '6+ months',
  ARRAY['peanut'],
  '[{"name":"ripe avocado","quantity":"½"},{"name":"smooth peanut butter","quantity":"1 tsp"},{"name":"lemon juice","quantity":"a few drops"}]',
  ARRAY[
    'Scoop avocado flesh into a bowl.',
    'Add peanut butter and lemon juice.',
    'Mash together until smooth and combined.'
  ],
  'Serve immediately on a spoon or spread on soft toast fingers.',
  'Lemon juice prevents browning and adds vitamin C.'
),
(
  'a0000001-0000-0000-0000-000000000006',
  'Peanut Butter Pear Puree',
  '6+ months',
  ARRAY['peanut'],
  '[{"name":"ripe pear","quantity":"1 medium"},{"name":"smooth peanut butter","quantity":"1 tsp"}]',
  ARRAY[
    'Peel, core, and dice the pear.',
    'Steam for 6–8 minutes until very soft.',
    'Blend with peanut butter until smooth.'
  ],
  'Serve at room temperature on a spoon.',
  NULL
),
(
  'a0000001-0000-0000-0000-000000000007',
  'Peanut Butter Carrot Puree',
  '7+ months',
  ARRAY['peanut'],
  '[{"name":"carrots","quantity":"2 medium"},{"name":"smooth peanut butter","quantity":"1 tsp"},{"name":"water","quantity":"3 tbsp"}]',
  ARRAY[
    'Peel and chop carrots.',
    'Boil for 15 minutes until tender.',
    'Blend with peanut butter and water until smooth.'
  ],
  'Serve warm. Can be chilled and stored for 48 hours.',
  NULL
),
(
  'a0000001-0000-0000-0000-000000000008',
  'Peanut Butter Yogurt Dip',
  '7+ months',
  ARRAY['peanut','dairy'],
  '[{"name":"plain whole-milk yogurt","quantity":"4 tbsp"},{"name":"smooth peanut butter","quantity":"1 tsp"}]',
  ARRAY[
    'Stir peanut butter into yogurt until fully combined.'
  ],
  'Serve as a dip with soft fruit slices or as a spoonable puree.',
  'Also introduces dairy — check allergens individually first.'
),
(
  'a0000001-0000-0000-0000-000000000009',
  'Peanut Noodles',
  '10+ months',
  ARRAY['peanut','wheat'],
  '[{"name":"soft-cooked spaghetti","quantity":"30 g"},{"name":"smooth peanut butter","quantity":"1 tbsp"},{"name":"warm water","quantity":"2 tbsp"},{"name":"splash of low-sodium soy sauce","quantity":"½ tsp"}]',
  ARRAY[
    'Cook spaghetti until very soft. Cut into short pieces.',
    'Whisk peanut butter with warm water and soy sauce until saucy.',
    'Toss noodles in sauce and cool slightly.'
  ],
  'Serve in a bowl; let baby self-feed with hands or a fork.',
  'Introduces peanut and wheat together — only serve if both have been cleared individually.'
),
(
  'a0000001-0000-0000-0000-000000000010',
  'Peanut Butter Banana Pancakes',
  '10+ months',
  ARRAY['peanut','egg','wheat'],
  '[{"name":"ripe banana","quantity":"1 small"},{"name":"egg","quantity":"1"},{"name":"smooth peanut butter","quantity":"1 tbsp"},{"name":"whole wheat flour","quantity":"2 tbsp"}]',
  ARRAY[
    'Mash banana in a bowl.',
    'Whisk in egg and peanut butter.',
    'Stir in flour until just combined.',
    'Cook small dollops in a lightly oiled pan over medium heat, 2 minutes per side.'
  ],
  'Cut into small pieces. Serve warm or at room temperature.',
  'Multi-allergen — only serve when peanut, egg, and wheat have each been cleared.'
),

-- ── EGG (8) ──────────────────────────────────────────────────────────────────

(
  'a0000002-0000-0000-0000-000000000001',
  'Soft Scrambled Eggs',
  '6+ months',
  ARRAY['egg'],
  '[{"name":"egg","quantity":"1"},{"name":"breast milk or formula","quantity":"1 tbsp"},{"name":"unsalted butter","quantity":"a small knob"}]',
  ARRAY[
    'Whisk egg with breast milk or formula.',
    'Melt butter in a pan over low heat.',
    'Pour in egg mixture and stir gently until just set and custardy.'
  ],
  'Serve warm. Mash further with a fork for younger babies.',
  'Do not overcook — rubbery eggs are harder for babies to manage.'
),
(
  'a0000002-0000-0000-0000-000000000002',
  'Egg Yolk Puree',
  '6+ months',
  ARRAY['egg'],
  '[{"name":"egg","quantity":"1"},{"name":"breast milk or formula","quantity":"1–2 tsp"}]',
  ARRAY[
    'Hard-boil the egg for 10 minutes.',
    'Peel and separate the yolk.',
    'Mash yolk with breast milk until smooth and lump-free.'
  ],
  'Serve on a spoon. Can be mixed into vegetable purees.',
  'Starting with just the yolk reduces reaction risk for sensitive babies.'
),
(
  'a0000002-0000-0000-0000-000000000003',
  'French Omelette Fingers',
  '7+ months',
  ARRAY['egg'],
  '[{"name":"eggs","quantity":"2"},{"name":"water","quantity":"1 tbsp"},{"name":"unsalted butter","quantity":"a small knob"}]',
  ARRAY[
    'Whisk eggs with water.',
    'Melt butter in a small non-stick pan over medium-low heat.',
    'Pour in egg mixture; when edges set, fold omelette in half.',
    'Slide onto a board and cut into finger-width strips.'
  ],
  'Serve warm or at room temperature as finger food.',
  NULL
),
(
  'a0000002-0000-0000-0000-000000000004',
  'Egg and Avocado Mash',
  '7+ months',
  ARRAY['egg'],
  '[{"name":"hard-boiled egg","quantity":"1"},{"name":"ripe avocado","quantity":"½"}]',
  ARRAY[
    'Mash the peeled hard-boiled egg.',
    'Mash avocado separately, then combine.',
    'Mix until desired consistency is reached.'
  ],
  'Serve on a spoon or spread on soft toast.',
  NULL
),
(
  'a0000002-0000-0000-0000-000000000005',
  'Mini Egg Muffins',
  '8+ months',
  ARRAY['egg','dairy'],
  '[{"name":"eggs","quantity":"3"},{"name":"whole-milk ricotta","quantity":"2 tbsp"},{"name":"finely grated zucchini","quantity":"¼ cup"},{"name":"grated cheddar","quantity":"2 tbsp"}]',
  ARRAY[
    'Preheat oven to 180 °C. Grease a mini-muffin tin.',
    'Whisk eggs and ricotta together.',
    'Stir in zucchini and cheddar.',
    'Spoon into tin and bake 12–14 minutes until set.'
  ],
  'Allow to cool, then cut in half for younger babies. Great as finger food.',
  'Can be stored refrigerated for 3 days.'
),
(
  'a0000002-0000-0000-0000-000000000006',
  'Soft-Boiled Egg Soldiers',
  '9+ months',
  ARRAY['egg','wheat'],
  '[{"name":"egg","quantity":"1"},{"name":"wholemeal bread slice","quantity":"1"}]',
  ARRAY[
    'Boil egg for 6 minutes for a jammy yolk.',
    'Toast bread lightly and cut into thin fingers.',
    'Place egg in an egg cup and cut the top off.'
  ],
  'Dip toast soldiers into the runny yolk.',
  'Soft-boiled egg is safe if the egg is lion-stamped (UK) or pasteurised.'
),
(
  'a0000002-0000-0000-0000-000000000007',
  'Egg Fried Rice',
  '10+ months',
  ARRAY['egg'],
  '[{"name":"cooked white rice","quantity":"½ cup"},{"name":"egg","quantity":"1"},{"name":"frozen peas","quantity":"2 tbsp"},{"name":"sesame oil","quantity":"½ tsp"}]',
  ARRAY[
    'Heat oil in a wok or pan over medium heat.',
    'Add rice and peas; stir for 2 minutes.',
    'Push rice to the side, crack in the egg, and scramble.',
    'Mix egg through rice and cook 1 more minute.'
  ],
  'Serve warm in small pieces. Encourage self-feeding with a spoon.',
  'Skip salt. Use very low-sodium soy sauce if desired at 12+ months.'
),
(
  'a0000002-0000-0000-0000-000000000008',
  'Veggie Egg Frittata',
  '10+ months',
  ARRAY['egg','dairy'],
  '[{"name":"eggs","quantity":"4"},{"name":"milk","quantity":"3 tbsp"},{"name":"cherry tomatoes","quantity":"6, halved"},{"name":"baby spinach","quantity":"handful"},{"name":"grated cheddar","quantity":"3 tbsp"}]',
  ARRAY[
    'Preheat oven to 180 °C.',
    'Whisk eggs with milk.',
    'Pour into an oven-safe pan, scatter tomatoes, spinach, and cheese.',
    'Bake 18–20 minutes until puffed and golden.'
  ],
  'Cool and cut into small squares. Serve at room temperature.',
  NULL
),

-- ── DAIRY (8) ────────────────────────────────────────────────────────────────

(
  'a0000003-0000-0000-0000-000000000001',
  'Greek Yogurt Banana Bowl',
  '6+ months',
  ARRAY['dairy'],
  '[{"name":"plain whole-milk Greek yogurt","quantity":"4 tbsp"},{"name":"ripe banana","quantity":"½"}]',
  ARRAY[
    'Mash banana with a fork.',
    'Swirl mashed banana through yogurt.'
  ],
  'Serve chilled or at room temperature on a spoon.',
  'Use plain, unsweetened yogurt only.'
),
(
  'a0000003-0000-0000-0000-000000000002',
  'Cottage Cheese and Peach',
  '7+ months',
  ARRAY['dairy'],
  '[{"name":"full-fat cottage cheese","quantity":"3 tbsp"},{"name":"ripe peach","quantity":"½"}]',
  ARRAY[
    'Peel and dice peach (or blend if puree consistency needed).',
    'Stir peach through cottage cheese.'
  ],
  'Serve chilled. Blend smooth for younger babies.',
  NULL
),
(
  'a0000003-0000-0000-0000-000000000003',
  'Creamy Mashed Potato',
  '7+ months',
  ARRAY['dairy'],
  '[{"name":"potato","quantity":"1 medium"},{"name":"unsalted butter","quantity":"1 tsp"},{"name":"whole milk","quantity":"2 tbsp"}]',
  ARRAY[
    'Peel and cube potato.',
    'Boil for 15 minutes until very soft.',
    'Drain and mash with butter and milk until lump-free.'
  ],
  'Serve warm. Add extra milk to thin for younger babies.',
  NULL
),
(
  'a0000003-0000-0000-0000-000000000004',
  'Cheese and Broccoli Bites',
  '8+ months',
  ARRAY['dairy','egg'],
  '[{"name":"broccoli florets","quantity":"1 cup"},{"name":"egg","quantity":"2"},{"name":"grated cheddar","quantity":"½ cup"},{"name":"plain flour","quantity":"3 tbsp"}]',
  ARRAY[
    'Preheat oven to 190 °C. Line a baking sheet.',
    'Finely chop or pulse broccoli.',
    'Mix with beaten egg, cheddar, and flour.',
    'Shape into small patties and bake 18 minutes, flipping halfway.'
  ],
  'Serve warm as finger food.',
  NULL
),
(
  'a0000003-0000-0000-0000-000000000005',
  'Yogurt Berry Swirl',
  '7+ months',
  ARRAY['dairy'],
  '[{"name":"plain whole-milk yogurt","quantity":"5 tbsp"},{"name":"blueberries or strawberries","quantity":"¼ cup"}]',
  ARRAY[
    'Cook berries in a small pan with 1 tsp water for 3–4 minutes until soft.',
    'Cool, then gently mash or puree.',
    'Swirl berry mixture through yogurt.'
  ],
  'Serve chilled or at room temperature.',
  'Cooking berries reduces choking risk and improves digestibility.'
),
(
  'a0000003-0000-0000-0000-000000000006',
  'Ricotta Toast',
  '8+ months',
  ARRAY['dairy','wheat'],
  '[{"name":"wholemeal bread","quantity":"1 slice"},{"name":"full-fat ricotta","quantity":"2 tbsp"},{"name":"ripe banana slices","quantity":"a few"}]',
  ARRAY[
    'Toast bread lightly, then cut into fingers.',
    'Spread ricotta generously over fingers.',
    'Top with banana slices, pressed in gently.'
  ],
  'Serve as finger food.',
  NULL
),
(
  'a0000003-0000-0000-0000-000000000007',
  'Milk Porridge',
  '7+ months',
  ARRAY['dairy'],
  '[{"name":"rolled oats","quantity":"3 tbsp"},{"name":"whole milk","quantity":"150 ml"},{"name":"mashed banana","quantity":"1 tbsp"}]',
  ARRAY[
    'Combine oats and milk in a saucepan.',
    'Cook over medium heat for 5 minutes, stirring.',
    'Stir in mashed banana and cool to lukewarm.'
  ],
  'Serve warm in a bowl.',
  NULL
),
(
  'a0000003-0000-0000-0000-000000000008',
  'Soft Cheese Pasta',
  '9+ months',
  ARRAY['dairy','wheat'],
  '[{"name":"small pasta (stelline or orzo)","quantity":"30 g"},{"name":"cream cheese","quantity":"1 tbsp"},{"name":"grated Parmesan","quantity":"1 tsp"},{"name":"steamed peas","quantity":"2 tbsp"}]',
  ARRAY[
    'Cook pasta until very soft.',
    'Drain, reserving 2 tbsp pasta water.',
    'Stir through cream cheese and Parmesan with pasta water to make a sauce.',
    'Mix in peas.'
  ],
  'Serve warm.',
  NULL
),

-- ── TREE NUTS (6) ────────────────────────────────────────────────────────────

(
  'a0000004-0000-0000-0000-000000000001',
  'Almond Butter Banana Puree',
  '6+ months',
  ARRAY['tree_nuts'],
  '[{"name":"ripe banana","quantity":"1 medium"},{"name":"smooth almond butter","quantity":"1 tsp"},{"name":"formula or breast milk","quantity":"1 tbsp"}]',
  ARRAY[
    'Mash banana until smooth.',
    'Stir in almond butter and formula.',
    'Mix until fully combined.'
  ],
  'Serve on a spoon or preloaded spoon.',
  'Use 100% almond butter with no added salt or sugar.'
),
(
  'a0000004-0000-0000-0000-000000000002',
  'Cashew Cream Pasta',
  '10+ months',
  ARRAY['tree_nuts','wheat'],
  '[{"name":"small pasta","quantity":"30 g"},{"name":"raw cashews soaked overnight","quantity":"¼ cup"},{"name":"water","quantity":"¼ cup"},{"name":"garlic powder","quantity":"a pinch"}]',
  ARRAY[
    'Drain soaked cashews and blend with water and garlic powder until completely smooth.',
    'Cook pasta until very soft, drain.',
    'Toss pasta in cashew cream, adding pasta water to loosen.'
  ],
  'Serve warm.',
  'Blend cashew sauce extra smooth — no lumps for young babies.'
),
(
  'a0000004-0000-0000-0000-000000000003',
  'Walnut and Banana Porridge',
  '8+ months',
  ARRAY['tree_nuts'],
  '[{"name":"rolled oats","quantity":"3 tbsp"},{"name":"water","quantity":"150 ml"},{"name":"walnut butter (finely ground walnuts)","quantity":"1 tsp"},{"name":"mashed banana","quantity":"1 tbsp"}]',
  ARRAY[
    'Cook oats with water for 5 minutes.',
    'Stir in walnut butter and banana.',
    'Cool to lukewarm.'
  ],
  'Serve warm.',
  'Ground walnuts must be very fine — whole or chopped walnuts are a choking hazard.'
),
(
  'a0000004-0000-0000-0000-000000000004',
  'Almond Milk Oatmeal',
  '7+ months',
  ARRAY['tree_nuts'],
  '[{"name":"rolled oats","quantity":"3 tbsp"},{"name":"unsweetened almond milk","quantity":"150 ml"},{"name":"cinnamon","quantity":"a pinch"}]',
  ARRAY[
    'Combine oats, almond milk, and cinnamon in a saucepan.',
    'Cook over medium heat 5 minutes, stirring constantly.',
    'Cool to lukewarm.'
  ],
  'Serve warm.',
  'Use unsweetened, calcium-fortified almond milk.'
),
(
  'a0000004-0000-0000-0000-000000000005',
  'Pecan Sweet Potato Mash',
  '8+ months',
  ARRAY['tree_nuts'],
  '[{"name":"sweet potato","quantity":"1 small"},{"name":"pecan butter (finely ground pecans)","quantity":"1 tsp"}]',
  ARRAY[
    'Roast or steam sweet potato until very soft.',
    'Mash, then stir in pecan butter until smooth.'
  ],
  'Serve warm.',
  NULL
),
(
  'a0000004-0000-0000-0000-000000000006',
  'Hazelnut Porridge',
  '8+ months',
  ARRAY['tree_nuts'],
  '[{"name":"rolled oats","quantity":"3 tbsp"},{"name":"water","quantity":"150 ml"},{"name":"hazelnut butter","quantity":"1 tsp"},{"name":"ripe pear","quantity":"¼, grated"}]',
  ARRAY[
    'Cook oats with water for 5 minutes.',
    'Stir in hazelnut butter and grated pear.',
    'Cool to lukewarm.'
  ],
  'Serve warm.',
  'Use 100% hazelnut butter, no added sugar.'
),

-- ── SESAME (5) ───────────────────────────────────────────────────────────────

(
  'a0000005-0000-0000-0000-000000000001',
  'Tahini Banana Puree',
  '6+ months',
  ARRAY['sesame'],
  '[{"name":"ripe banana","quantity":"1 medium"},{"name":"tahini","quantity":"1 tsp"},{"name":"formula or breast milk","quantity":"1 tbsp"}]',
  ARRAY[
    'Mash banana until smooth.',
    'Stir in tahini and formula until fully combined.'
  ],
  'Serve on a spoon.',
  'Tahini (sesame paste) is a gentle way to introduce sesame.'
),
(
  'a0000005-0000-0000-0000-000000000002',
  'Hummus Dip',
  '7+ months',
  ARRAY['sesame'],
  '[{"name":"canned chickpeas (no salt)","quantity":"200 g, drained"},{"name":"tahini","quantity":"1 tbsp"},{"name":"lemon juice","quantity":"1 tsp"},{"name":"water","quantity":"3 tbsp"}]',
  ARRAY[
    'Blend all ingredients until completely smooth.',
    'Add more water if needed to reach a spreadable consistency.'
  ],
  'Serve as a dip with soft pita strips or vegetable sticks.',
  NULL
),
(
  'a0000005-0000-0000-0000-000000000003',
  'Sesame Sweet Potato Fingers',
  '8+ months',
  ARRAY['sesame'],
  '[{"name":"sweet potato","quantity":"1 medium"},{"name":"sesame oil","quantity":"½ tsp"}]',
  ARRAY[
    'Preheat oven to 200 °C.',
    'Slice sweet potato into finger-sized sticks, skin on.',
    'Toss in sesame oil and roast 25 minutes until soft inside and lightly caramelised.'
  ],
  'Cool to finger-food temperature. Serve as self-feeding finger food.',
  NULL
),
(
  'a0000005-0000-0000-0000-000000000004',
  'Sesame Chicken Puree',
  '7+ months',
  ARRAY['sesame'],
  '[{"name":"chicken thigh (boneless, skinless)","quantity":"60 g"},{"name":"sesame oil","quantity":"¼ tsp"},{"name":"water","quantity":"4 tbsp"}]',
  ARRAY[
    'Steam chicken for 12 minutes until cooked through.',
    'Blend with sesame oil and water until smooth.'
  ],
  'Serve warm on a spoon or mix into vegetable purees.',
  NULL
),
(
  'a0000005-0000-0000-0000-000000000005',
  'Sesame Noodles',
  '10+ months',
  ARRAY['sesame','wheat'],
  '[{"name":"soft-cooked spaghetti","quantity":"30 g"},{"name":"tahini","quantity":"1 tsp"},{"name":"warm water","quantity":"1 tbsp"},{"name":"grated cucumber","quantity":"1 tbsp"}]',
  ARRAY[
    'Cook spaghetti until very soft. Cut into short pieces.',
    'Whisk tahini with warm water to make a sauce.',
    'Toss noodles with tahini sauce and cucumber.'
  ],
  'Serve at room temperature.',
  'Introduces sesame and wheat — clear individually first.'
),

-- ── SOY (5) ──────────────────────────────────────────────────────────────────

(
  'a0000006-0000-0000-0000-000000000001',
  'Soft Tofu and Broccoli Puree',
  '6+ months',
  ARRAY['soy'],
  '[{"name":"silken tofu","quantity":"50 g"},{"name":"broccoli florets","quantity":"½ cup"}]',
  ARRAY[
    'Steam broccoli for 10 minutes until very soft.',
    'Blend with silken tofu until smooth.'
  ],
  'Serve warm on a spoon.',
  'Silken tofu blends very smoothly and is a gentle soy introduction.'
),
(
  'a0000006-0000-0000-0000-000000000002',
  'Edamame Mash',
  '7+ months',
  ARRAY['soy'],
  '[{"name":"shelled edamame (frozen)","quantity":"½ cup"},{"name":"water","quantity":"3 tbsp"},{"name":"lemon juice","quantity":"a few drops"}]',
  ARRAY[
    'Cook edamame according to package instructions.',
    'Blend with water and lemon juice until smooth.'
  ],
  'Serve warm or at room temperature.',
  NULL
),
(
  'a0000006-0000-0000-0000-000000000003',
  'Tofu Veggie Stir-Fry Puree',
  '8+ months',
  ARRAY['soy'],
  '[{"name":"firm tofu","quantity":"60 g"},{"name":"carrot","quantity":"½, diced"},{"name":"zucchini","quantity":"½, diced"},{"name":"sesame oil","quantity":"½ tsp"}]',
  ARRAY[
    'Steam carrot and zucchini until very soft, about 12 minutes.',
    'Cube tofu and pan-fry in sesame oil until lightly golden.',
    'Blend all together, adding water to reach desired consistency.'
  ],
  'Serve warm, chunky for older babies or blended smooth for younger ones.',
  NULL
),
(
  'a0000006-0000-0000-0000-000000000004',
  'Edamame and Sweet Potato Puree',
  '7+ months',
  ARRAY['soy'],
  '[{"name":"shelled edamame (frozen)","quantity":"¼ cup"},{"name":"sweet potato","quantity":"1 small"}]',
  ARRAY[
    'Steam sweet potato until very soft.',
    'Cook edamame, then blend both together until smooth.'
  ],
  'Serve warm.',
  NULL
),
(
  'a0000006-0000-0000-0000-000000000005',
  'Tofu Fingers',
  '9+ months',
  ARRAY['soy'],
  '[{"name":"firm tofu block","quantity":"100 g"},{"name":"olive oil","quantity":"1 tsp"}]',
  ARRAY[
    'Press tofu between paper towels for 10 minutes to remove excess moisture.',
    'Cut into finger-sized sticks.',
    'Pan-fry in olive oil over medium heat, 2–3 minutes per side, until golden.'
  ],
  'Serve at room temperature as finger food.',
  'Crispy outside, soft inside — great texture for self-feeding.'
),

-- ── WHEAT (5) ────────────────────────────────────────────────────────────────

(
  'a0000007-0000-0000-0000-000000000001',
  'Soft Bread Fingers',
  '6+ months',
  ARRAY['wheat'],
  '[{"name":"soft white bread (thick slice)","quantity":"1"},{"name":"unsalted butter","quantity":"a thin scrape"}]',
  ARRAY[
    'Remove crusts.',
    'Spread a very thin layer of butter.',
    'Cut into finger-width strips.'
  ],
  'Serve as a self-feeding finger food.',
  'Bread should be soft — toast is too hard for early self-feeding.'
),
(
  'a0000007-0000-0000-0000-000000000002',
  'Whole Wheat Banana Pancakes',
  '7+ months',
  ARRAY['wheat','egg'],
  '[{"name":"whole wheat flour","quantity":"¼ cup"},{"name":"egg","quantity":"1"},{"name":"mashed banana","quantity":"½"},{"name":"milk","quantity":"3 tbsp"}]',
  ARRAY[
    'Whisk all ingredients together.',
    'Drop tablespoon-sized dollops onto a lightly greased pan over medium heat.',
    'Cook 2 minutes per side until golden.'
  ],
  'Cut into small pieces. Serve warm or at room temperature.',
  NULL
),
(
  'a0000007-0000-0000-0000-000000000003',
  'Buttery Soft Pasta',
  '7+ months',
  ARRAY['wheat'],
  '[{"name":"small pasta (stelline or orzo)","quantity":"30 g"},{"name":"unsalted butter","quantity":"1 tsp"}]',
  ARRAY[
    'Cook pasta until very soft.',
    'Drain and toss with butter.'
  ],
  'Serve warm.',
  NULL
),
(
  'a0000007-0000-0000-0000-000000000004',
  'Mini Wheat Muffins',
  '9+ months',
  ARRAY['wheat','egg','dairy'],
  '[{"name":"whole wheat flour","quantity":"½ cup"},{"name":"egg","quantity":"1"},{"name":"whole milk","quantity":"¼ cup"},{"name":"unsalted butter","quantity":"2 tbsp, melted"},{"name":"mashed banana","quantity":"½"}]',
  ARRAY[
    'Preheat oven to 175 °C. Grease a mini-muffin tin.',
    'Mix all wet ingredients together.',
    'Fold in flour until just combined.',
    'Spoon into tin and bake 12 minutes.'
  ],
  'Cool before serving. Break into small pieces for younger babies.',
  NULL
),
(
  'a0000007-0000-0000-0000-000000000005',
  'Pasta with Tomato and Veggies',
  '9+ months',
  ARRAY['wheat'],
  '[{"name":"small pasta","quantity":"30 g"},{"name":"canned crushed tomatoes","quantity":"3 tbsp"},{"name":"finely diced zucchini","quantity":"2 tbsp"},{"name":"olive oil","quantity":"½ tsp"}]',
  ARRAY[
    'Sauté zucchini in oil 3 minutes.',
    'Add tomatoes and simmer 5 minutes.',
    'Cook pasta until very soft, drain, and toss with sauce.'
  ],
  'Serve warm.',
  NULL
),

-- ── FISH (5) ─────────────────────────────────────────────────────────────────

(
  'a0000008-0000-0000-0000-000000000001',
  'Salmon and Sweet Potato Puree',
  '6+ months',
  ARRAY['fish'],
  '[{"name":"salmon fillet (skinless)","quantity":"60 g"},{"name":"sweet potato","quantity":"1 small"}]',
  ARRAY[
    'Bake or steam salmon for 12 minutes until fully cooked.',
    'Steam sweet potato until very soft.',
    'Blend both together, adding water as needed, until smooth. Remove any bones.'
  ],
  'Serve warm on a spoon.',
  'Double-check for small bones before blending.'
),
(
  'a0000008-0000-0000-0000-000000000002',
  'Tuna Pasta',
  '9+ months',
  ARRAY['fish','wheat'],
  '[{"name":"small pasta","quantity":"30 g"},{"name":"canned tuna in water (no salt)","quantity":"30 g, drained"},{"name":"cream cheese","quantity":"1 tbsp"},{"name":"frozen peas","quantity":"2 tbsp"}]',
  ARRAY[
    'Cook pasta until very soft with peas in the last 2 minutes.',
    'Drain. Stir through cream cheese and flaked tuna.'
  ],
  'Serve warm.',
  'Use canned tuna in spring water, no added salt.'
),
(
  'a0000008-0000-0000-0000-000000000003',
  'Baked Cod with Carrot Mash',
  '7+ months',
  ARRAY['fish'],
  '[{"name":"cod fillet","quantity":"60 g"},{"name":"carrots","quantity":"2, diced"},{"name":"olive oil","quantity":"½ tsp"}]',
  ARRAY[
    'Rub cod with oil and bake at 180 °C for 15 minutes.',
    'Steam carrots until soft.',
    'Mash carrots and flake fish over top, checking for bones.',
    'Blend together or serve chunky for older babies.'
  ],
  'Serve warm.',
  NULL
),
(
  'a0000008-0000-0000-0000-000000000004',
  'Salmon Cakes',
  '10+ months',
  ARRAY['fish','egg'],
  '[{"name":"cooked flaked salmon","quantity":"80 g"},{"name":"egg","quantity":"1"},{"name":"mashed potato","quantity":"2 tbsp"},{"name":"fresh dill","quantity":"a pinch"}]',
  ARRAY[
    'Mix all ingredients together.',
    'Shape into small flat cakes.',
    'Pan-fry in a little olive oil, 3 minutes per side, until golden.'
  ],
  'Serve at room temperature as finger food.',
  'Check for bones carefully before mixing.'
),
(
  'a0000008-0000-0000-0000-000000000005',
  'Creamy Salmon Orzo',
  '10+ months',
  ARRAY['fish','wheat','dairy'],
  '[{"name":"orzo","quantity":"30 g"},{"name":"salmon fillet","quantity":"60 g"},{"name":"cream cheese","quantity":"1 tbsp"},{"name":"baby spinach","quantity":"handful"}]',
  ARRAY[
    'Cook orzo until very soft.',
    'Steam or poach salmon until cooked; flake and check for bones.',
    'Toss orzo with cream cheese, spinach, and salmon.'
  ],
  'Serve warm.',
  NULL
),

-- ── SHELLFISH (5) ────────────────────────────────────────────────────────────

(
  'a0000009-0000-0000-0000-000000000001',
  'Prawn and Avocado Puree',
  '7+ months',
  ARRAY['shellfish'],
  '[{"name":"cooked prawns (peeled, deveined)","quantity":"60 g"},{"name":"ripe avocado","quantity":"½"},{"name":"lemon juice","quantity":"a few drops"}]',
  ARRAY[
    'Blend prawns until smooth, adding a little water if needed.',
    'Mash avocado separately.',
    'Combine both with lemon juice to taste.'
  ],
  'Serve chilled or at room temperature on a spoon.',
  'Use fully cooked, fresh or frozen-then-thawed prawns. Never raw.'
),
(
  'a0000009-0000-0000-0000-000000000002',
  'Crab and Sweet Potato Mash',
  '8+ months',
  ARRAY['shellfish'],
  '[{"name":"crab meat (cooked)","quantity":"40 g"},{"name":"sweet potato","quantity":"1 small"}]',
  ARRAY[
    'Steam sweet potato until very soft, then mash.',
    'Stir in flaked crab meat.',
    'Blend further if a smoother texture is needed.'
  ],
  'Serve warm.',
  'Use real crab — avoid imitation crab which contains wheat and additives.'
),
(
  'a0000009-0000-0000-0000-000000000003',
  'Prawn Risotto',
  '10+ months',
  ARRAY['shellfish','dairy'],
  '[{"name":"arborio rice","quantity":"3 tbsp"},{"name":"cooked prawns","quantity":"40 g"},{"name":"low-sodium vegetable stock","quantity":"200 ml"},{"name":"Parmesan","quantity":"1 tsp"}]',
  ARRAY[
    'Simmer stock in a pot.',
    'Cook rice in a separate small pan, adding stock a ladleful at a time, stirring until absorbed, about 18 minutes.',
    'Stir in chopped prawns and Parmesan; cook 2 more minutes.'
  ],
  'Serve warm.',
  NULL
),
(
  'a0000009-0000-0000-0000-000000000004',
  'Soft Shrimp Noodles',
  '10+ months',
  ARRAY['shellfish','wheat'],
  '[{"name":"soft-cooked spaghetti","quantity":"30 g"},{"name":"cooked shrimp (chopped small)","quantity":"40 g"},{"name":"butter","quantity":"½ tsp"},{"name":"garlic powder","quantity":"a pinch"}]',
  ARRAY[
    'Cook spaghetti until very soft, then cut into short pieces.',
    'Melt butter in a small pan, add garlic powder and shrimp, heat 2 minutes.',
    'Toss noodles with shrimp.'
  ],
  'Serve warm.',
  NULL
),
(
  'a0000009-0000-0000-0000-000000000005',
  'Crab Cake Bites',
  '11+ months',
  ARRAY['shellfish','egg','wheat'],
  '[{"name":"crab meat (cooked)","quantity":"80 g"},{"name":"egg","quantity":"1"},{"name":"breadcrumbs","quantity":"2 tbsp"},{"name":"lemon zest","quantity":"a pinch"},{"name":"fresh parsley","quantity":"1 tsp, finely chopped"}]',
  ARRAY[
    'Combine all ingredients and mix well.',
    'Shape into small flat cakes.',
    'Bake at 200 °C for 15 minutes, flipping halfway.'
  ],
  'Cool and serve as finger food.',
  'Only serve when shellfish, egg, and wheat have each been cleared individually.'
)

ON CONFLICT (id) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE THUMBNAILS (picsum.photos seeded — deterministic, free, no auth)
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE recipes SET thumbnail_url = 'https://picsum.photos/seed/peanut-recipe/400/300'    WHERE id LIKE 'a0000001%';
UPDATE recipes SET thumbnail_url = 'https://picsum.photos/seed/egg-recipe/400/300'       WHERE id LIKE 'a0000002%';
UPDATE recipes SET thumbnail_url = 'https://picsum.photos/seed/dairy-recipe/400/300'     WHERE id LIKE 'a0000003%';
UPDATE recipes SET thumbnail_url = 'https://picsum.photos/seed/treenuts-recipe/400/300'  WHERE id LIKE 'a0000004%';
UPDATE recipes SET thumbnail_url = 'https://picsum.photos/seed/sesame-recipe/400/300'    WHERE id LIKE 'a0000005%';
UPDATE recipes SET thumbnail_url = 'https://picsum.photos/seed/soy-recipe/400/300'       WHERE id LIKE 'a0000006%';
UPDATE recipes SET thumbnail_url = 'https://picsum.photos/seed/wheat-recipe/400/300'     WHERE id LIKE 'a0000007%';
UPDATE recipes SET thumbnail_url = 'https://picsum.photos/seed/fish-recipe/400/300'      WHERE id LIKE 'a0000008%';
UPDATE recipes SET thumbnail_url = 'https://picsum.photos/seed/shellfish-recipe/400/300' WHERE id LIKE 'a0000009%';
