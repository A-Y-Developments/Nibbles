-- Atomic baby creation (fixes the onboarding orphan/duplicate-baby bug).
--
-- Previously the app created the baby row and its allergen_program_state row in
-- TWO separate writes from the service layer. If the second write failed, the
-- baby row was already committed (and never rolled back), and the user's retry
-- created a SECOND baby row. This RPC performs both inserts inside a single
-- plpgsql function body — which runs in one transaction — so either both rows
-- commit or neither does.
--
-- One baby per user is the real invariant. The UNIQUE(user_id) constraint
-- enforces it and makes a retry idempotent.
-- NOTE: this ALTER fails if duplicate user_id rows already exist. The app is
-- pre-launch, so none are expected; if any exist in an environment, de-duplicate
-- the babies table before applying this migration.
ALTER TABLE babies
  ADD CONSTRAINT babies_user_id_key UNIQUE (user_id);

-- SECURITY INVOKER (default): the inserts run as the calling user, so RLS still
-- applies (WITH CHECK auth.uid() = user_id passes; the just-inserted baby is
-- visible to the allergen_program_state RLS EXISTS check within the same txn).
-- search_path is pinned to avoid resolution hijacking.
CREATE OR REPLACE FUNCTION create_baby_with_program(
  p_name TEXT,
  p_date_of_birth DATE,
  p_gender TEXT
)
RETURNS babies
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_baby babies;
BEGIN
  INSERT INTO babies (user_id, name, date_of_birth, gender, onboarding_completed)
  VALUES (auth.uid(), p_name, p_date_of_birth, p_gender, true)
  RETURNING * INTO v_baby;

  INSERT INTO allergen_program_state (
    baby_id, current_allergen_key, current_sequence_order, status
  )
  VALUES (v_baby.id, 'peanut', 1, 'in_progress');

  RETURN v_baby;
END;
$$;

GRANT EXECUTE ON FUNCTION create_baby_with_program(TEXT, DATE, TEXT) TO authenticated;
