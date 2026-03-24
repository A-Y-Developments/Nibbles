CREATE TABLE IF NOT EXISTS allergen_program_state (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id UUID NOT NULL UNIQUE REFERENCES babies(id) ON DELETE CASCADE,
  current_allergen_key TEXT NOT NULL REFERENCES allergens(key),
  current_sequence_order INT NOT NULL,
  status TEXT NOT NULL DEFAULT 'in_progress',  -- 'in_progress' | 'completed' | 'flagged'
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE allergen_program_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own baby program state"
  ON allergen_program_state FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM babies
      WHERE babies.id = allergen_program_state.baby_id
        AND babies.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM babies
      WHERE babies.id = allergen_program_state.baby_id
        AND babies.user_id = auth.uid()
    )
  );
