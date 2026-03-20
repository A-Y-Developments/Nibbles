CREATE TABLE shopping_list_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id uuid NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  name text NOT NULL,
  is_checked boolean NOT NULL DEFAULT false,
  source text NOT NULL CHECK (source IN ('recipe', 'meal_plan', 'manual')),
  created_at timestamptz DEFAULT now()
);
