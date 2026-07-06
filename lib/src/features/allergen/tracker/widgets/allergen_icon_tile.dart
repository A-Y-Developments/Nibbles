import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Quatrefoil allergen tile (Figma "Milk" instance, 62x62). A single burgundy
/// `allergenMilk` glyph stands in for every allergen for now.
///
/// [backing] paints a rounded-square behind the glyph so it stays legible on
/// dark surfaces (burgundy hero / detail header). [greyscale] desaturates the
/// glyph for the "Not Tried" grey cards.
class AllergenIconTile extends StatelessWidget {
  const AllergenIconTile({
    this.size = 56,
    this.backing,
    this.borderColor,
    this.greyscale = false,
    super.key,
  });

  final double size;
  final Color? backing;

  /// Optional hairline border around the backing tile (Figma outlines the
  /// rounded-square on the burgundy hero / detail header).
  final Color? borderColor;
  final bool greyscale;

  static const List<double> _greyMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    Widget glyph = Assets.images.allergen.allergenMilk.image(
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (greyscale) {
      glyph = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_greyMatrix),
        child: Opacity(opacity: 0.55, child: glyph),
      );
    }

    if (backing == null) return glyph;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backing,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      alignment: Alignment.center,
      child: Padding(padding: const EdgeInsets.all(AppSizes.xs), child: glyph),
    );
  }
}
