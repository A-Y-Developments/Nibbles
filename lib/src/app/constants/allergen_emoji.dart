/// Static map of allergen key → emoji string.
/// The Big 11 sequence (display order):
/// milk(1) → walnut(2) → peanut(3) → egg(4) → cashew(5) → wheat(6) →
/// prawn(7) → fish(8) → sesame(9) → soybean(10) → almond(11)
///
/// Note: several tree nuts share 🌰 — visual distinction is handled at the
/// design layer via per-allergen icon assets.
abstract final class AllergenEmoji {
  static const Map<String, String> map = {
    'milk': '🥛',
    'walnut': '🌰',
    'peanut': '🥜',
    'egg': '🥚',
    'cashew': '🌰',
    'wheat': '🌾',
    'prawn': '🦐',
    'fish': '🐟',
    'sesame': '🫘',
    'soybean': '🫘',
    'almond': '🌰',
  };

  /// Returns the emoji for [allergenKey], or an empty string if not found.
  static String get(String allergenKey) => map[allergenKey] ?? '';

  /// Proper-cased display name per allergen key. Single source of truth so
  /// casing stays consistent app-wide — use instead of ad-hoc
  /// `key.replaceAll('_', ' ')`.
  static const Map<String, String> nameMap = {
    'milk': 'Milk',
    'walnut': 'Walnut',
    'peanut': 'Peanut',
    'egg': 'Egg',
    'cashew': 'Cashew',
    'wheat': 'Wheat',
    'prawn': 'Prawn',
    'fish': 'Fish',
    'sesame': 'Sesame',
    'soybean': 'Soybean',
    'almond': 'Almond',
  };

  /// Display name for [allergenKey]; falls back to a humanized key
  /// (underscores → spaces) for any unmapped key.
  static String displayName(String allergenKey) =>
      nameMap[allergenKey] ?? allergenKey.replaceAll('_', ' ');
}
