import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';

/// Brand quatrefoil mark — butter petals (#EAEC8C) + sage center (#5C7852).
/// Mirrors the Primitives.jsx `Quatrefoil` SVG, sizeable.
class Quatrefoil extends StatelessWidget {
  const Quatrefoil({
    this.size = 96,
    this.petalColor = AppColors.butter,
    this.coreColor = AppColors.green,
    super.key,
  });

  final double size;
  final Color petalColor;
  final Color coreColor;

  @override
  Widget build(BuildContext context) {
    final petal = _hex(petalColor);
    final core = _hex(coreColor);

    final svg = '''
<svg width="$size" height="$size" viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg">
  <path fill="$petal" d="M60 8c14 0 22 8 22 22 0 4-1 8-3 11 9 3 17 12 17 23 0 14-9 22-22 22-4 0-8-1-11-3-3 9-12 17-23 17-14 0-22-9-22-22 0-4 1-8 3-11-9-3-17-12-17-23 0-14 9-22 22-22 4 0 8 1 11 3 3-9 12-17 23-17z" transform="translate(2 2)"/>
  <circle cx="60" cy="60" r="22" fill="$core"/>
</svg>''';

    return SvgPicture.string(svg, width: size, height: size);
  }

  String _hex(Color c) {
    final argb = c.toARGB32();
    final rgb = (argb & 0x00FFFFFF).toRadixString(16).padLeft(6, '0');
    return '#$rgb';
  }
}
