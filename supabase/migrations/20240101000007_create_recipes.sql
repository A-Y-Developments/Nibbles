CREATE TABLE IF NOT EXISTS recipes (
  id               TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  title            TEXT NOT NULL,
  age_range        TEXT NOT NULL,
  allergen_tags    TEXT[] NOT NULL DEFAULT '{}',
  ingredients      JSONB NOT NULL DEFAULT '[]',
  steps            TEXT[] NOT NULL DEFAULT '{}',
  serving_guidance TEXT NOT NULL,
  notes            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Public read-only — no auth required to browse recipes
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "recipes_public_read"
  ON recipes FOR SELECT
  USING (true);
