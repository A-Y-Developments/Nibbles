import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/starting_guide/widgets/baby_face_glyph.dart';

/// Wrap of small icon tiles — green-deep baby-face glyph above a label.
/// Used for "Essential Nutrients" (Iron / Minerals / Vitamins / Zinc) on
/// Introduction (Figma 971:8744) and the iron-rich foods grid on Feeding
/// Principles (Figma 1474:50514).
class GuideIconTileGrid extends StatelessWidget {
  const GuideIconTileGrid({required this.labels, super.key});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sp12,
      runSpacing: AppSizes.sp12,
      children: [for (final label in labels) _Tile(label: label)],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          const BabyFaceGlyph(size: BabyFaceGlyph.smallSize),
          const SizedBox(height: AppSizes.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.fgStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
