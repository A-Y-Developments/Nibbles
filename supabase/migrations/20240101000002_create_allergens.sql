CREATE TABLE IF NOT EXISTS allergens (
  key TEXT PRIMARY KEY,
  display_name TEXT NOT NULL,
  sequence_order INT NOT NULL
);

-- No RLS needed — public read-only reference table

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
