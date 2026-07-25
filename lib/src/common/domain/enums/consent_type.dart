/// Consent acknowledgement types persisted on onboarding submit (NIB-145).
///
/// The string value is the canonical DB encoding — matches the
/// `consents.consent_type` CHECK constraint.
enum ConsentType {
  /// Nibbles is a general guide, the parent remains responsible, and the child
  /// will be supervised while eating. Covers the first two consent checkboxes.
  solidsIntroduction('solids_introduction'),

  /// Terms of Use, Medical & Safety Disclaimer and Privacy Policy acceptance —
  /// the third consent checkbox.
  termsAndPrivacy('terms_and_privacy'),

  /// Early-solids responsibility clause. RETIRED — the checkbox was removed
  /// from the design and is no longer written. Kept so historical rows still
  /// decode.
  under6MoResponsibility('under_6mo_responsibility');

  const ConsentType(this.dbValue);

  /// String value persisted in `consents.consent_type`.
  final String dbValue;
}
