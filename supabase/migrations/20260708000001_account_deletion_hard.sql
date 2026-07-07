-- Hard account deletion — supports the `delete-account` Edge Function.
--
-- The Edge Function deletes the auth.users row with the service role, which
-- cascades all user + baby-scoped data (babies → allergen_logs, reaction_
-- details, allergen_program_state, meal_plans, meal_plan_entries, shopping_
-- list_items; plus consents). This migration only adjusts the churn-reason
-- audit table so its row SURVIVES that deletion (user_id → NULL) instead of
-- cascading away — mirroring the `feedback` table.
--
-- Supersedes the soft-delete path (request_account_deletion RPC +
-- babies.deleted_at), which is left in place but no longer called by the app.

ALTER TABLE account_deletion_requests
  ALTER COLUMN user_id DROP NOT NULL;

ALTER TABLE account_deletion_requests
  DROP CONSTRAINT IF EXISTS account_deletion_requests_user_id_fkey;

ALTER TABLE account_deletion_requests
  ADD CONSTRAINT account_deletion_requests_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;
