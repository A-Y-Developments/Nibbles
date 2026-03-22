-- Migration: create core tables
-- babies, allergen_logs, reactions, meal_plans, shopping_list
-- Depends on: 20250319_create_allergens.sql
-- Note: allergens table already exists — do not modify it.

-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE babies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  date_of_birth DATE NOT NULL,
  gender TEXT CHECK (gender IN ('male', 'female', 'prefer_not_to_say')),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE allergen_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id UUID NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  allergen_key TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('not_started', 'in_progress', 'safe', 'flagged')),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  allergen_log_id UUID NOT NULL REFERENCES allergen_logs(id) ON DELETE CASCADE,
  severity TEXT NOT NULL CHECK (severity IN ('mild', 'moderate', 'severe')),
  symptoms TEXT[] NOT NULL DEFAULT '{}',
  notes TEXT,
  occurred_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE meal_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id UUID NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  recipe_id TEXT NOT NULL,
  scheduled_date DATE NOT NULL,
  meal_slot TEXT NOT NULL CHECK (meal_slot IN ('breakfast', 'lunch', 'dinner', 'snack')),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE shopping_list (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id UUID NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  ingredient_name TEXT NOT NULL,
  quantity TEXT,
  unit TEXT,
  is_checked BOOLEAN NOT NULL DEFAULT false,
  source TEXT NOT NULL CHECK (source IN ('recipe', 'meal_plan', 'manual')),
  recipe_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_babies_user_id ON babies(user_id);
CREATE INDEX idx_allergen_logs_baby_id ON allergen_logs(baby_id);
CREATE INDEX idx_reactions_allergen_log_id ON reactions(allergen_log_id);
CREATE INDEX idx_meal_plans_baby_id ON meal_plans(baby_id);
CREATE INDEX idx_meal_plans_scheduled_date ON meal_plans(scheduled_date);
CREATE INDEX idx_shopping_list_baby_id ON shopping_list(baby_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE babies ENABLE ROW LEVEL SECURITY;
ALTER TABLE allergen_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list ENABLE ROW LEVEL SECURITY;

-- babies: direct user_id check
CREATE POLICY "users_manage_own_babies"
  ON babies
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- allergen_logs: user owns the parent baby
CREATE POLICY "users_manage_own_allergen_logs"
  ON allergen_logs
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM babies
      WHERE babies.id = allergen_logs.baby_id
        AND babies.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM babies
      WHERE babies.id = allergen_logs.baby_id
        AND babies.user_id = auth.uid()
    )
  );

-- reactions: user owns the allergen_log's parent baby
CREATE POLICY "users_manage_own_reactions"
  ON reactions
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM allergen_logs
      JOIN babies ON allergen_logs.baby_id = babies.id
      WHERE allergen_logs.id = reactions.allergen_log_id
        AND babies.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM allergen_logs
      JOIN babies ON allergen_logs.baby_id = babies.id
      WHERE allergen_logs.id = reactions.allergen_log_id
        AND babies.user_id = auth.uid()
    )
  );

-- meal_plans: user owns the parent baby
CREATE POLICY "users_manage_own_meal_plans"
  ON meal_plans
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM babies
      WHERE babies.id = meal_plans.baby_id
        AND babies.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM babies
      WHERE babies.id = meal_plans.baby_id
        AND babies.user_id = auth.uid()
    )
  );

-- shopping_list: user owns the parent baby
CREATE POLICY "users_manage_own_shopping_list"
  ON shopping_list
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM babies
      WHERE babies.id = shopping_list.baby_id
        AND babies.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM babies
      WHERE babies.id = shopping_list.baby_id
        AND babies.user_id = auth.uid()
    )
  );
