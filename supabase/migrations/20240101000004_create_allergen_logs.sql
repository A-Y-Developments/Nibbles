CREATE TABLE IF NOT EXISTS allergen_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id UUID NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  allergen_key TEXT NOT NULL REFERENCES allergens(key),
  emoji_taste TEXT NOT NULL,    -- 'love' | 'neutral' | 'dislike'
  had_reaction BOOLEAN NOT NULL,
  log_date DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(baby_id, allergen_key, log_date)
);

ALTER TABLE allergen_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage logs for their own babies"
  ON allergen_logs FOR ALL
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
