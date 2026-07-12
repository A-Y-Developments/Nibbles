import 'package:flutter/material.dart';

/// Visual variant of a branded allergen icon. Each maps to a folder under
/// `assets/icons/allergen/` (except [maroon]'s milk, which reuses the existing
/// burgundy milk glyph — the maroon set ships without milk).
enum AllergenIconVariant {
  /// Coral tile + white glyph. Default; used on light "introducing/tried" cards
  /// and meal-plan chips. Assets: `assets/icons/allergen/{key}.png`.
  filled,

  /// Coral outline glyph on a transparent tile. Light surfaces.
  outline,

  /// Grey tile + white glyph. The "Not Tried" inactive state.
  grey,

  /// White glyph on a transparent quatrefoil — sits on burgundy surfaces
  /// (allergen detail header, home ongoing/exposure cards). Ships without milk.
  maroon,
}

/// Allergen keys that have a branded icon asset (the Big 11 — Figma allergen
/// icon set). The [AllergenIconVariant.maroon] set intentionally omits `milk`.
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

/// Burgundy milk glyph reused for [AllergenIconVariant.maroon] + `milk` (the
/// maroon set has no milk asset).
const _maroonMilkFallback = 'assets/images/allergen/allergen_milk.png';

/// Renders the branded allergen icon for [allergenKey] in [variant] (replaces
/// the old emoji glyph). Falls back to an empty, space-preserving box for an
/// unknown key.
///
/// Assets are referenced by path rather than the flutter_gen accessor so the
/// key→asset lookup stays dynamic (and to avoid a full build_runner pass).
class AllergenIcon extends StatelessWidget {
  const AllergenIcon({
    required this.allergenKey,
    this.variant = AllergenIconVariant.filled,
    this.size = 16,
    super.key,
  });

  final String allergenKey;
  final AllergenIconVariant variant;
  final double size;

  static bool hasIcon(String key) => _allergenIconKeys.contains(key);

  String get _assetPath {
    if (variant == AllergenIconVariant.maroon && allergenKey == 'milk') {
      return _maroonMilkFallback;
    }
    return switch (variant) {
      AllergenIconVariant.filled => 'assets/icons/allergen/$allergenKey.png',
      AllergenIconVariant.outline =>
        'assets/icons/allergen/outline/$allergenKey.png',
      AllergenIconVariant.grey => 'assets/icons/allergen/grey/$allergenKey.png',
      AllergenIconVariant.maroon =>
        'assets/icons/allergen/maroon/$allergenKey.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_allergenIconKeys.contains(allergenKey)) {
      return SizedBox.square(dimension: size);
    }
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
