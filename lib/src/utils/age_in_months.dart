/// Returns the whole-month difference between [dob] and [now] (defaults to
/// `DateTime.now()`), clamped to 0 for future / equal dates.
///
/// Semantics: the day-of-month of [dob] must have been reached in the [now]
/// month for that month to count. e.g. dob = Jan 31, now = Feb 15 → 0 (the
/// 31st has not yet happened in Feb); dob = Jan 15, now = Feb 15 → 1.
///
/// Pure helper — used by the DOB onboarding screen (NIB-74) to drive the
/// live coral age label and downstream by any feature that needs to surface
/// the baby's age in months.
int ageInMonths(DateTime dob, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  if (!ref.isAfter(dob)) return 0;

  var months = (ref.year - dob.year) * 12 + (ref.month - dob.month);
  if (ref.day < dob.day) months -= 1;
  return months < 0 ? 0 : months;
}
