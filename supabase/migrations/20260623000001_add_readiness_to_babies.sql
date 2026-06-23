-- Persist the onboarding readiness result on the baby row.
--
-- The readiness answers were previously captured in-memory by the onboarding
-- controller and discarded on completion. The 5 Sign Readiness guide page now
-- reflects the real result, so the answers must be durable.
--
-- `readiness_signs` is the full ordered result: index 0 is the Q1 pediatrician
-- gate, indices 1-5 are the Q2-Q6 developmental signs. Order matches the
-- onboarding questionnaire / kReadinessSignLabels. Existing rows default to an
-- empty array (no captured answers).
ALTER TABLE babies
  ADD COLUMN readiness_signs BOOLEAN[] NOT NULL DEFAULT '{}';

-- The RPC's argument list changes, so DROP + CREATE rather than CREATE OR
-- REPLACE (the latter would register a second overload alongside the old one).
DROP FUNCTION IF EXISTS create_baby_with_program(TEXT, DATE, TEXT);

CREATE OR REPLACE FUNCTION create_baby_with_program(
  p_name TEXT,
  p_date_of_birth DATE,
  p_gender TEXT,
  p_readiness_signs BOOLEAN[]
)
RETURNS babies
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_baby babies;
BEGIN
  INSERT INTO babies (
    user_id, name, date_of_birth, gender, onboarding_completed, readiness_signs
  )
  VALUES (
    auth.uid(), p_name, p_date_of_birth, p_gender, true,
    COALESCE(p_readiness_signs, '{}')
  )
  RETURNING * INTO v_baby;

  INSERT INTO allergen_program_state (
    baby_id, current_allergen_key, current_sequence_order, status
  )
  VALUES (v_baby.id, 'peanut', 1, 'in_progress');

  RETURN v_baby;
END;
$$;

GRANT EXECUTE ON FUNCTION
  create_baby_with_program(TEXT, DATE, TEXT, BOOLEAN[])
  TO authenticated;
