import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nibbles/gen/assets.gen.dart';

/// Peach baby-face avatar circle (Figma node 1189:12419).
///
/// Renders the bundled `baby_circle_peach` SVG, used on the Profile and
/// Edit Profile identity blocks. Decorative — excluded from semantics.
class BabyAvatar extends StatelessWidget {
  const BabyAvatar({this.size = 143, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        Assets.images.profile.babyCirclePeach.path,
        width: size,
        height: size,
      ),
    );
  }
}
