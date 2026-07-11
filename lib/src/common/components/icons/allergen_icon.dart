import 'package:flutter/material.dart';

/// Allergen keys that have a branded icon asset under
/// `assets/icons/allergen/{key}.png` (the Big 11 — Figma allergen icon set).
const _allergenIconKeys = <String>{
  'milk',
  'walnut',
  'peanut',
  'egg',
  'cashew',
  'wheat',
  'prawn',
  'fish',
  'sesame',
  'soybean',
  'almond',
};

/// Renders the branded allergen icon for [allergenKey] (replaces the old emoji
/// glyph). Falls back to an empty, space-preserving box for an unknown key.
///
/// Assets are referenced by path rather than the flutter_gen accessor so the
/// key→asset lookup stays dynamic (and to avoid a full build_runner pass).
class AllergenIcon extends StatelessWidget {
  const AllergenIcon({required this.allergenKey, this.size = 16, super.key});

  final String allergenKey;
  final double size;

  static bool hasIcon(String key) => _allergenIconKeys.contains(key);

  @override
  Widget build(BuildContext context) {
    if (!_allergenIconKeys.contains(allergenKey)) {
      return SizedBox.square(dimension: size);
    }
    return Image.asset(
      'assets/icons/allergen/$allergenKey.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
