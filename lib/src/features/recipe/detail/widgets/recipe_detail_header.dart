import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';

/// Recipe detail header. Mirrors Figma node 971:9720 — back chip + centered
/// "Recipe Detail" title + optional more_horiz overflow chip. Sits above
/// the hero on the cream background — no transparency, no collapsing.
class RecipeDetailHeader extends StatelessWidget {
  const RecipeDetailHeader({
    required this.onBack,
    this.onOverflow,
    super.key,
  });

  final VoidCallback onBack;

  /// Nullable so the overflow chip can be hidden when there are no actions.
  final VoidCallback? onOverflow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
          AppSizes.sm,
        ),
        child: Row(
          children: [
            AppRoundButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
              semanticLabel: 'Back',
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Recipe Detail',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.fgStrong,
                  ),
                ),
              ),
            ),
            if (onOverflow != null)
              AppRoundButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: onOverflow,
                semanticLabel: 'More options',
              )
            else
              const SizedBox(width: AppSizes.roundButton),
          ],
        ),
      ),
    );
  }
}
