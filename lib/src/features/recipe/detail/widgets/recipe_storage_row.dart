import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Salmon storage + freezer cards, side by side. Each card only renders
/// when its note is present. Figma node 971:9648.
class RecipeStorageRow extends StatelessWidget {
  const RecipeStorageRow({
    required this.storageNote,
    required this.freezerNote,
    super.key,
  });

  final String? storageNote;
  final String? freezerNote;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      if (storageNote != null)
        Expanded(
          child: _StorageCard(
            icon: Assets.images.recipe.storageIcon,
            label: 'Storage',
            note: storageNote!,
          ),
        ),
      if (storageNote != null && freezerNote != null)
        const SizedBox(width: AppSizes.md),
      if (freezerNote != null)
        Expanded(
          child: _StorageCard(
            icon: Assets.images.recipe.freezerIcon,
            label: 'Freezer',
            note: freezerNote!,
          ),
        ),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards,
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({
    required this.icon,
    required this.label,
    required this.note,
  });

  final SvgGenImage icon;
  final String label;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.salmon,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon.svg(width: 37, height: 37),
          const SizedBox(height: AppSizes.sm),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: AppSizes.sp2),
          Text(
            note,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
