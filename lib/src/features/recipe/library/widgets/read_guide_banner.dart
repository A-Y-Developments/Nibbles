import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// First-launch 'New to Starting Solids?' banner for the Recipe Library
/// (Figma 971:8644 → 1015:6820). The forest-green card, blobs, title, body
/// copy and lime 'Read Guide' button are all baked into
/// `banner_starting_solids.svg` as vector outlines (shadow included), so the
/// whole banner is rendered as one crisp asset.
///
/// Always visible on the Recipe Library screen. The banner is a pure
/// presentation widget — the entire surface is tappable (mirroring the baked
/// 'Read Guide' CTA); tapping fires [onTap] and the caller routes to the
/// Starting Guide.
class ReadGuideBanner extends StatelessWidget {
  const ReadGuideBanner({required this.onTap, super.key});

  final VoidCallback onTap;

  // SVG viewBox cropped tight to the green panel (370x175).
  static const double _bannerAspectRatio = 370 / 175;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        0,
        AppSizes.pagePaddingH,
        0,
      ),
      child: Semantics(
        button: true,
        label: 'Read Guide',
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: _bannerAspectRatio,
            child: Assets.images.recipe.bannerStartingSolids.svg(
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
