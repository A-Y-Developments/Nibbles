/// Minimum age in months a recipe suits, parsed from its free-form
/// `Recipe.ageRange` label (e.g. '6m+', '8m+', '6+ months', '10+ months').
///
/// Returns the first integer in the label, or null when none is present —
/// callers treat null as "no age constraint" (recipe always eligible).
int? minAgeMonths(String ageRange) {
  final match = RegExp(r'\d+').firstMatch(ageRange);
  if (match == null) return null;
  return int.tryParse(match.group(0)!);
}
