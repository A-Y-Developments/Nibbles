CREATE TABLE babies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  date_of_birth date NOT NULL,
  gender text NOT NULL CHECK (gender IN ('male', 'female', 'prefer_not_to_say')),
  onboarding_completed boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now()
);
