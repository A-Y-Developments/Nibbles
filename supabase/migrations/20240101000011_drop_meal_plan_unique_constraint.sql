-- Drop any unique constraint on (baby_id, plan_date) in meal_plan_entries.
-- Multiple meals per day must be allowed.
DO $$ DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT c.conname
    FROM   pg_constraint c
    JOIN   pg_class      t ON t.oid = c.conrelid
    JOIN   pg_namespace  n ON n.oid = t.relnamespace
    WHERE  n.nspname   = 'public'
      AND  t.relname   = 'meal_plan_entries'
      AND  c.contype   = 'u'
      AND  c.conkey  && ARRAY(
             SELECT a.attnum
             FROM   pg_attribute a
             WHERE  a.attrelid = t.oid
               AND  a.attname IN ('baby_id', 'plan_date')
           )
  LOOP
    EXECUTE format('ALTER TABLE public.meal_plan_entries DROP CONSTRAINT %I', r.conname);
  END LOOP;
END $$;
