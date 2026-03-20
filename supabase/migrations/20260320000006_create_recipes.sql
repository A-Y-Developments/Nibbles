CREATE TABLE recipes (
  id text PRIMARY KEY,
  title text NOT NULL,
  age_range text NOT NULL,
  allergen_tags text[] NOT NULL DEFAULT '{}',
  ingredients jsonb NOT NULL,
  steps text[] NOT NULL,
  serving_guidance text NOT NULL,
  notes text,
  created_at timestamptz DEFAULT now()
);
