import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Round green-deep glyph used as the hero mark on the Starting Guide hub
/// and as a stand-in for hardcoded article hero imagery while real
/// illustration is pending.
///
/// Aligns with the only kit precedent for this circular badge shape —
/// `.tip__ico` (kit.css line 108-114): `--color-green-deep` background,
/// `--color-butter` foreground content.
class BabyFaceGlyph extends StatelessWidget {
  const BabyFaceGlyph({this.size = 56, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.greenDeep,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.child_care_rounded,
        color: AppColors.butter,
        size: size * 0.6,
      ),
    );
  }

  /// Convenience small-glyph constant matched to the tip-card spec
  /// (`AppSizes.tipGlyph` — used on hub article cards).
  static const double smallSize = AppSizes.tipGlyph;
}
