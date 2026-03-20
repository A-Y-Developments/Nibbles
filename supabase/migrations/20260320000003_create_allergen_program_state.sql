CREATE TABLE allergen_program_state (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id uuid NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  current_allergen_key text NOT NULL REFERENCES allergens(key),
  current_sequence_order int NOT NULL,
  status text NOT NULL CHECK (status IN ('in_progress', 'completed')),
  started_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
