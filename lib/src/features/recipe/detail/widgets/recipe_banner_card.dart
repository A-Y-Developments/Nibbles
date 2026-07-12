import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';

/// White info card that overlaps the bottom of the hero image. Shows the
/// recipe title, a "Best for $ageRange" subtitle, and the nutrition chips.
/// Figma node 1129:13972.
class RecipeBannerCard extends StatelessWidget {
  const RecipeBannerCard({
    required this.title,
    required this.ageRange,
    required this.nutritionTags,
    this.makes,
    super.key,
  });

  final String title;
  final String ageRange;
  final List<String> nutritionTags;
  final String? makes;

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
    final hasChips = nutritionTags.isNotEmpty;
    final makesLabel = makes;

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          if (makesLabel != null && makesLabel.isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              'Makes $makesLabel',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.fgMuted,
              ),
            ),
          ],
          if (hasChips) ...[
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.xs,
              runSpacing: AppSizes.xs,
              children: [
                for (final tag in nutritionTags) AppChip(label: _humanize(tag)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
