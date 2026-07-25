-- Allow the terms_and_privacy consent type.
--
-- The consent screen was reworked (Figma 1255:11883): the early-solids
-- responsibility checkbox was removed and replaced by a Terms of Use /
-- Medical & Safety Disclaimer / Privacy Policy acceptance that every user
-- ticks regardless of the baby's age.
--
-- under_6mo_responsibility stays permitted so historical rows remain valid;
-- the client no longer writes it.

ALTER TABLE consents DROP CONSTRAINT IF EXISTS consents_consent_type_check;

ALTER TABLE consents ADD CONSTRAINT consents_consent_type_check CHECK (
  consent_type IN (
    'solids_introduction',
    'under_6mo_responsibility',
    'terms_and_privacy'
  )
);
