CREATE TABLE meal_plan_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id uuid NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  plan_date date NOT NULL,
  recipe_id text NOT NULL REFERENCES recipes(id),
  meal_time time,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT unique_baby_plan_date UNIQUE (baby_id, plan_date)
);
