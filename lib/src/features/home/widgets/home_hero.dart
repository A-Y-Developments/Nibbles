import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';

/// Lime hero backdrop behind the Home dashboard's header + greeting + stats.
///
/// Mirrors Figma node 1242:10153 (`Rectangle 100`) — a full-bleed lime
/// (#EAEC98) panel whose bottom edge dips into a shallow centre curve, with
/// two soft white "cloud" blobs (`clouddd`) drifting across the top. Both are
/// the designer's exported SVGs so the curve + blob geometry match exactly.
/// Meant to be the back layer of a [Stack] sized to the chrome it sits behind.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Assets.images.home.heroBackdrop.svg(fit: BoxFit.fill),
          ),
          // Large cloud bleeding off the top-left, behind the greeting.
          Positioned(
            top: -8,
            left: -52,
            child: Assets.images.home.heroCloud.svg(width: 208, height: 208),
          ),
          // Smaller cloud tucked into the top-right corner.
          Positioned(
            top: 28,
            right: -40,
            child: Assets.images.home.heroCloud.svg(width: 156, height: 156),
          ),
        ],
      ),
    );
  }
}
