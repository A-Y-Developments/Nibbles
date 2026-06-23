import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/features/starting_guide/widgets/baby_face_glyph.dart';

/// White card — leaf-style glyph, title, body, trailing label chips. Matches
/// the "Our Philosophy" card on Introduction (Figma 971:8744).
class GuidePhilosophyCard extends StatelessWidget {
  const GuidePhilosophyCard({
    required this.title,
    required this.body,
    required this.chips,
    super.key,
  });

  final String title;
  final String body;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppSizes.shadowCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BabyFaceGlyph(size: BabyFaceGlyph.smallSize),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.fgStrong,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  body,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
                const SizedBox(height: AppSizes.sp12),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [for (final label in chips) AppChip(label: label)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
