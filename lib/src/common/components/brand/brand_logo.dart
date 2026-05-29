import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';

/// Horizontal lockup of the [Quatrefoil] mark + `nibbles` Parkinsans wordmark.
///
/// Mirrors `design/preview/brand-logo.html`: 96 mark + 44/1 800 Parkinsans
/// wordmark in greenDeep, separated by ~33% of the mark width. `size` scales
/// the entire lockup proportionally (mark + wordmark + gap) so the visual
/// rhythm of the kit is preserved at any size.
class BrandLogo extends StatelessWidget {
  const BrandLogo({this.size = 120, super.key});

  /// Width/height of the quatrefoil mark in logical pixels. Wordmark and gap
  /// scale proportionally relative to the kit's 96 reference.
  final double size;

  // Kit reference dimensions (design/preview/brand-logo.html).
  static const double _refMark = 96;
  static const double _refWordFontSize = 44;
  static const double _refGap = 32;

  @override
  Widget build(BuildContext context) {
    final scale = size / _refMark;
    final wordSize = _refWordFontSize * scale;
    final gap = _refGap * scale;

    final wordmark = AppTypography.brandWordmark.copyWith(
      fontSize: wordSize,
      // brandWordmark letterSpacing is logical px tuned to 42; rescale to the
      // -0.02em ratio used in the kit at the new font size.
      letterSpacing: wordSize * -0.02,
      color: AppColors.greenDeep,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Quatrefoil(size: size),
        SizedBox(width: gap),
        Text('nibbles', style: wordmark),
      ],
    );
  }
}
