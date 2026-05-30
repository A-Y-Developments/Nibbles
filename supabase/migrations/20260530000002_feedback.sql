-- NIB-70 — Give Feedback.
--
-- A simple write-only feedback table. Users append rows via the in-app Give
-- Feedback form (Profile -> Settings). Reads are admin-only (no SELECT
-- policy) — there is no per-user history in MVP.
--
-- user_id ON DELETE SET NULL so that a feedback row survives an account
-- deletion / soft-delete and remains useful for product triage even after
-- the author is gone.

CREATE TABLE IF NOT EXISTS feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  message TEXT NOT NULL CHECK (length(message) BETWEEN 1 AND 2000),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users can insert their own feedback" ON feedback;
CREATE POLICY "users can insert their own feedback"
  ON feedback
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());
