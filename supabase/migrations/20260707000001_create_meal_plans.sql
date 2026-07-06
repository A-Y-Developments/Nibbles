-- Persisted meal-prep plan period. One active plan per baby is enforced
-- app-side (create-new replaces). Existing meal_plan_entries without a
-- meal_plan_id stay valid for the legacy rolling-7 path.
CREATE TABLE IF NOT EXISTS public.meal_plans (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id    uuid        NOT NULL REFERENCES public.babies(id) ON DELETE CASCADE,
  start_date date        NOT NULL,
  end_date   date        NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS meal_plans_baby_id_idx
  ON public.meal_plans (baby_id);

ALTER TABLE public.meal_plan_entries
  ADD COLUMN IF NOT EXISTS meal_plan_id uuid
    REFERENCES public.meal_plans(id) ON DELETE CASCADE;

ALTER TABLE public.meal_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage meal plans for their own babies"
  ON public.meal_plans FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.id = meal_plans.baby_id
        AND babies.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.id = meal_plans.baby_id
        AND babies.user_id = auth.uid()
    )
  );
