import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';

/// Lime hero backdrop behind the Home dashboard's header + greeting + stats.
///
/// Mirrors Figma node 1189:10761 — a full-bleed lime (#EAEC98) panel whose
/// bottom edge dips into a shallow centre curve. Rendered via a [ClipPath] so
/// it needs no bundled asset. Meant to be the back layer of a [Stack] sized to
/// the chrome it sits behind.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeroClipper(),
      child: const ColoredBox(color: AppColors.lime),
    );
  }
}

class _HeroClipper extends CustomClipper<Path> {
  // Native Figma path box is 402×346; the straight sides drop to y=311.536
  // before the bottom curve, so the curve occupies the lowest ~10%.
  static const double _nativeW = 402;
  static const double _nativeStraightY = 311.536;
  static const double _nativeH = 346;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final straightY = h * _nativeStraightY / _nativeH;
    double sx(double x) => w * x / _nativeW;
    return Path()
      ..lineTo(w, 0)
      ..lineTo(w, straightY)
      ..cubicTo(w, straightY, sx(354.5), h, sx(201), h)
      ..cubicTo(sx(47.5), h, 0, straightY, 0, straightY)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
