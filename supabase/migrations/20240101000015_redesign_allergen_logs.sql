-- NIB-124: Align allergen_logs with the redesigned log capture (NIB-120).
--
-- Reaction capture collapses to a single hadReaction toggle; taste, severity
-- and structured symptoms are dropped from the new flow. The schema keeps
-- emoji_taste so historical rows render, but it is no longer required.
-- New columns capture log-level notes, an attachment title/description, and
-- preserve the existing log_date for editable dates.
--
-- Old M3 capture screens (AL-04/AL-05/AL-06) still compile against the
-- pre-redesign Dart APIs; emoji_taste being nullable is the only schema
-- change those screens depend on. NIB-125 / NIB-126 will replace them.

ALTER TABLE allergen_logs
  ALTER COLUMN emoji_taste DROP NOT NULL;

ALTER TABLE allergen_logs
  ADD COLUMN IF NOT EXISTS notes TEXT;

ALTER TABLE allergen_logs
  ADD COLUMN IF NOT EXISTS attachment_title TEXT;

ALTER TABLE allergen_logs
  ADD COLUMN IF NOT EXISTS attachment_description TEXT;
