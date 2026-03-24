CREATE TABLE IF NOT EXISTS reaction_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  log_id UUID NOT NULL UNIQUE REFERENCES allergen_logs(id) ON DELETE CASCADE,
  severity TEXT NOT NULL,    -- 'mild' | 'moderate' | 'severe'
  symptoms TEXT[] NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE reaction_details ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage reaction details for their own babies"
  ON reaction_details FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM allergen_logs
      JOIN babies ON babies.id = allergen_logs.baby_id
      WHERE allergen_logs.id = reaction_details.log_id
        AND babies.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM allergen_logs
      JOIN babies ON babies.id = allergen_logs.baby_id
      WHERE allergen_logs.id = reaction_details.log_id
        AND babies.user_id = auth.uid()
    )
  );
