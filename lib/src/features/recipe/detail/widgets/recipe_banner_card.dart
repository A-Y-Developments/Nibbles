import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';

/// Recipe banner card — sits just under the hero image. Shows the title,
/// a "Best for $ageRange" subtitle line, and the diet (nutrition) chips.
///
/// Mirrors Figma node 1129:13972 (recipe-library-detail-1 / -2). Figma has
/// no separate category pill on this card — `category` is intentionally
/// ignored at the visual layer for the redesign.
class RecipeBannerCard extends StatelessWidget {
  const RecipeBannerCard({
    required this.title,
    required this.ageRange,
    required this.nutritionTags,
    this.category,
    super.key,
  });

  final String title;
  final String ageRange;
  final List<String> nutritionTags;

  /// Retained on the constructor for compatibility with the existing
  /// controller wiring. Not rendered in the redesign — Figma omits a
  /// category pill on this card.
  final String? category;

  String _humanize(String raw) {
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDietChips = nutritionTags.isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'Best for $ageRange',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hasDietChips) ...[
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.xs,
              runSpacing: AppSizes.xs,
              children: [
                for (final tag in nutritionTags)
                  AppChip(label: _humanize(tag)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
