-- Create meal_plan_entries table without the unique(baby_id, plan_date)
-- constraint so that multiple meals can be assigned to the same day.
CREATE TABLE IF NOT EXISTS public.meal_plan_entries (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id    uuid        NOT NULL REFERENCES public.babies(id) ON DELETE CASCADE,
  recipe_id  text        NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
  plan_date  date        NOT NULL,
  meal_time  time,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Drop the unique constraint if it was created manually before this migration.
DO $$ BEGIN
  IF EXISTS (
    SELECT 1
    FROM   pg_constraint
    WHERE  conname    = 'meal_plan_entries_baby_id_plan_date_key'
      AND  conrelid   = 'public.meal_plan_entries'::regclass
  ) THEN
    ALTER TABLE public.meal_plan_entries
      DROP CONSTRAINT meal_plan_entries_baby_id_plan_date_key;
  END IF;
END $$;

ALTER TABLE public.meal_plan_entries ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS meal_plan_entries_baby_date_idx
  ON public.meal_plan_entries (baby_id, plan_date);

CREATE POLICY "Users can manage meal plans for their own babies"
  ON public.meal_plan_entries FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.id = meal_plan_entries.baby_id
        AND babies.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.id = meal_plan_entries.baby_id
        AND babies.user_id = auth.uid()
    )
  );
