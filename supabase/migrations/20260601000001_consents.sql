-- NIB-145 — Persist onboarding consent acknowledgements to DB with timestamp.
--
-- The consent UX gate stays in-app (the user can't reach baby creation without
-- ticking every box on the consent screen). This table is the supplementary
-- DB receipt — proves WHEN and WHICH consents the user gave, against which
-- baby. The receipt insert is P2 from the client (best-effort, logged to
-- Crashlytics on failure); the in-app gate is the authoritative blocker.
--
-- Two consent types today (NIB-120):
--   - solids_introduction         — always recorded on onboarding submit
--   - under_6mo_responsibility    — only recorded when the baby is < 6 months
--                                   at consent time (early-solids clause)
--
-- baby_id is nullable + ON DELETE CASCADE so a row can survive while we wait
-- for createBaby() to land (defensive — current wiring records consent AFTER
-- the baby exists) and is automatically purged when the baby is hard-deleted.

CREATE TABLE IF NOT EXISTS consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  baby_id UUID REFERENCES babies(id) ON DELETE CASCADE,
  consent_type TEXT NOT NULL CHECK (
    consent_type IN ('solids_introduction', 'under_6mo_responsibility')
  ),
  given_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE consents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users insert own consents" ON consents;
CREATE POLICY "users insert own consents" ON consents
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "users read own consents" ON consents;
CREATE POLICY "users read own consents" ON consents
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE INDEX IF NOT EXISTS consents_user_id_idx ON consents (user_id);
