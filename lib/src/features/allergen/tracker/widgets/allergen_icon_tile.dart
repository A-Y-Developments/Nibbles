import 'package:flutter/material.dart';
import 'package:nibbles/src/common/components/icons/allergen_icon.dart';

/// Quatrefoil allergen tile (Figma "Allergen Icon" component set). Renders the
/// branded per-allergen glyph for [allergenKey] in [variant] — each variant PNG
/// is a self-contained quatrefoil, so this is a thin, intent-carrying wrapper
/// over [AllergenIcon]:
///  - [AllergenIconVariant.maroon] on burgundy surfaces (detail header, home
///    ongoing/exposure cards),
///  - [AllergenIconVariant.filled] for introducing/tried light cards,
///  - [AllergenIconVariant.grey] for the "Not Tried" state.
class AllergenIconTile extends StatelessWidget {
  const AllergenIconTile({
    required this.allergenKey,
    this.variant = AllergenIconVariant.filled,
    this.size = 56,
    this.heroTag,
    super.key,
  });

  final String allergenKey;
  final AllergenIconVariant variant;
  final double size;

  /// When set, the glyph flies between screens under this tag. Left null on
  /// list tiles that share a route to avoid duplicate-tag conflicts.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final icon = AllergenIcon(
      allergenKey: allergenKey,
      variant: variant,
      size: size,
    );
    if (heroTag == null) return icon;
    return Hero(tag: heroTag!, child: icon);
  }
}
