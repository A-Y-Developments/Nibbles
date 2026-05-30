import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Round butter-tinted glyph showing a baby face emoji — used as the hero
/// mark on the Starting Guide hub and as a stand-in for hardcoded article
/// hero imagery while real illustration is pending.
class BabyFaceGlyph extends StatelessWidget {
  const BabyFaceGlyph({this.size = 56, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.butter,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '\u{1F476}',
        style: TextStyle(fontSize: size * 0.55, height: 1),
      ),
    );
  }

  /// Convenience small-glyph constant matched to the tip-card spec
  /// (`AppSizes.tipGlyph` — used on hub article cards).
  static const double smallSize = AppSizes.tipGlyph;
}
