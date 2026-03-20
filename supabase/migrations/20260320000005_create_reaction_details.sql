CREATE TABLE reaction_details (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  log_id uuid NOT NULL REFERENCES allergen_logs(id) ON DELETE CASCADE,
  symptoms text[] NOT NULL,
  severity text NOT NULL CHECK (severity IN ('mild', 'moderate', 'severe')),
  other_symptoms_notes text,
  created_at timestamptz DEFAULT now()
);
