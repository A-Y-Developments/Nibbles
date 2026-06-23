/// Cancel-subscription survey reasons (NIB-82).
///
/// Verbatim UI labels are preserved exactly per the Figma audit
/// (`.figma-audit/subscription-cancel/overlay-delete-account/report.md`):
///   * U+2019 curly apostrophes
///   * trailing spaces on two reasons
///   * a double space in "I subscribed by  accident"
///
/// `analyticsKey` is the stable snake_case payload sent to Firebase Analytics
/// (`subscription_cancel_started` / `subscription_cancel_reason`). Keeping it
/// distinct from `label` keeps PII-free analytics PII-free and stops the
/// trailing-space / double-space ugliness from leaking into dashboards.
enum CancelReason {
  achievedGoal(
    label: 'I achieved my goal already',
    analyticsKey: 'achieved_goal',
  ),
  // Verbatim trailing space preserved per Figma 1216:12031.
  priceTooHigh(
    label: 'The plan is out of my price range ',
    analyticsKey: 'price_too_high',
  ),
  // Verbatim trailing space preserved per Figma 1216:12032.
  notValuable(
    label: 'I didn’t find subscription plan features valuable ',
    analyticsKey: 'not_valuable',
  ),
  noLongerNeeded(
    label: 'I no longer need meal recommendations',
    analyticsKey: 'no_longer_needed',
  ),
  // Verbatim double space preserved per Figma 1216:12034.
  accidental(label: 'I subscribed by  accident', analyticsKey: 'accidental'),
  other(label: 'Other', analyticsKey: 'other');

  const CancelReason({required this.label, required this.analyticsKey});

  /// User-facing copy. Verbatim from Figma — never paraphrase.
  final String label;

  /// Stable snake_case key shipped to analytics. PII-free.
  final String analyticsKey;
}
