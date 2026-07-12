import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Cream tip card with a bowl illustration on the right. Used for "Texture
/// Tip" and "Why This Meal?". Figma nodes 1474:53335 / 1474:53348.
enum RecipeTipKind { textureTip, whyThisMeal }

class RecipeTipCard extends StatelessWidget {
  const RecipeTipCard({required this.kind, required this.body, super.key});

  final RecipeTipKind kind;
  final String? body;

  String get _title => switch (kind) {
    RecipeTipKind.textureTip => 'Texture Tip',
    RecipeTipKind.whyThisMeal => 'Why This Meal?',
  };

  AssetGenImage get _illustration => switch (kind) {
    RecipeTipKind.textureTip => Assets.images.recipe.textureIllustration,
    RecipeTipKind.whyThisMeal => Assets.images.recipe.whyMealIllustration,
  };

  @override
  Widget build(BuildContext context) {
    final text = body;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(left: AppSizes.md, right: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.fgStrong,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgDefault,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          _illustration.image(width: 160, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
