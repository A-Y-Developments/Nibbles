/// Static map of allergen key → emoji string.
/// Sequence: peanut(1) → egg(2) → dairy(3) → tree_nuts(4) → sesame(5) →
///           soy(6) → wheat(7) → fish(8) → shellfish(9)
///
/// Note: sesame and soy share the 🫘 emoji — visual distinction
/// should be handled at the design layer if needed.
abstract final class AllergenEmoji {
  static const Map<String, String> map = {
    'peanut': '🥜',
    'egg': '🥚',
    'dairy': '🥛',
    'tree_nuts': '🌰',
    'sesame': '🫘',
    'soy': '🫘',
    'wheat': '🌾',
    'fish': '🐟',
    'shellfish': '🦐',
  };

  /// Returns the emoji for [allergenKey], or an empty string if not found.
  static String get(String allergenKey) => map[allergenKey] ?? '';
}
