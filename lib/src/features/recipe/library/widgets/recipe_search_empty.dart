import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';

/// Generic 'no results' empty state for the Recipe Library search
/// (Figma 971:8813 / 971:8828).
///
/// Centered butter-flower-glyph ([Quatrefoil]) + 16/700 title + caption
/// subtitle. Copy is intentionally generic — the search query is NOT
/// interpolated into the message.
class RecipeSearchEmpty extends StatelessWidget {
  const RecipeSearchEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Quatrefoil(),
            const SizedBox(height: AppSizes.sm + 2),
            const Text(
              "We couldn't find any recipes",
              textAlign: TextAlign.center,
              style: AppTypography.emptyStateTitle,
            ),
            const SizedBox(height: AppSizes.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                'Try a different keyword or clear the search to browse '
                'every category.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.fgFaint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
