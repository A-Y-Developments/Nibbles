-- NIB-85 / NIB-120 — Soft account deletion.
--
-- Adds a soft-delete column on babies and a new account_deletion_requests
-- table that stores the user's deletion reason + timestamp. The
-- request_account_deletion(p_reason) RPC is SECURITY DEFINER so it can mark
-- the row + soft-delete the user's babies atomically while still being safe
-- under RLS (it captures auth.uid() internally).
--
-- The Supabase auth user row is NOT deleted here — that is handled by an
-- ops-side cron purge in a future ticket. The client treats the account as
-- deleted purely via the deletion-request row + signed-out state.

-- ---------------------------------------------------------------------------
-- 1) babies.deleted_at
-- ---------------------------------------------------------------------------

ALTER TABLE babies
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- ---------------------------------------------------------------------------
-- 2) account_deletion_requests
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS account_deletion_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE account_deletion_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users can insert their own deletion request"
  ON account_deletion_requests;
CREATE POLICY "users can insert their own deletion request"
  ON account_deletion_requests
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "users can read their own deletion request"
  ON account_deletion_requests;
CREATE POLICY "users can read their own deletion request"
  ON account_deletion_requests
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- 3) request_account_deletion RPC
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION request_account_deletion(p_reason TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not authenticated' USING ERRCODE = '28000';
  END IF;

  INSERT INTO account_deletion_requests (user_id, reason)
  VALUES (v_user_id, p_reason);

  UPDATE babies
     SET deleted_at = now()
   WHERE user_id = v_user_id
     AND deleted_at IS NULL;
END;
$$;

REVOKE ALL ON FUNCTION request_account_deletion(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION request_account_deletion(TEXT) TO authenticated;
