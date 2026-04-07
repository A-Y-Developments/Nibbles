-- Allow multiple logs per day for the same allergen.
-- Users may feed the allergen multiple times in a day and want to log each occurrence.
ALTER TABLE allergen_logs DROP CONSTRAINT IF EXISTS allergen_logs_baby_id_allergen_key_log_date_key;
