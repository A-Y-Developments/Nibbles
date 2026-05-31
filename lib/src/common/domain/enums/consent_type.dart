/// Consent acknowledgement types persisted on onboarding submit (NIB-145).
///
/// The string value is the canonical DB encoding — matches the
/// `consents.consent_type` CHECK constraint
/// (`'solids_introduction' | 'under_6mo_responsibility'`).
enum ConsentType {
  /// Top-of-screen acknowledgement: educational info, not medical advice,
  /// and the user has medical clearance. Always recorded on submit.
  solidsIntroduction('solids_introduction'),

  /// Early-solids responsibility clause — only recorded when the baby is
  /// younger than 6 months at consent time.
  under6MoResponsibility('under_6mo_responsibility');

  const ConsentType(this.dbValue);

  /// String value persisted in `consents.consent_type`.
  final String dbValue;
}
