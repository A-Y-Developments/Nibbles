CREATE TABLE allergen_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id uuid NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  allergen_key text NOT NULL REFERENCES allergens(key),
  log_date date NOT NULL,
  emoji_taste text NOT NULL CHECK (emoji_taste IN ('love', 'neutral', 'dislike')),
  had_reaction boolean NOT NULL,
  created_at timestamptz DEFAULT now()
);
