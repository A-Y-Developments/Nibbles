import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_grid_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// A horizontally-scrolling row of [RecipeGridCard]s under a section title.
///
/// Each card is pinned to the design-system 158x220 box per Figma 971:8760.
/// The section title is rendered with the Headline/SemiBold token
/// (Parkinsans SemiBold 15/22) per the audit spec; cards are spaced by
/// the Figma 24px row gap.
class RecipeCategoryRow extends StatelessWidget {
  const RecipeCategoryRow({
    required this.title,
    required this.recipes,
    this.flaggedAllergenKeys = const {},
    this.heroEligibleIds = const {},
    super.key,
  });

  final String title;
  final List<Recipe> recipes;
  final Set<String> flaggedAllergenKeys;
  final Set<String> heroEligibleIds;

  static const double _cardWidth = 158;
  static const double _cardHeight = 220;
  // Figma row gap (971:8660 etc.) — 24px between cards.
  static const double _cardGap = AppSizes.lg;
  static const Duration _staggerStep = Duration(milliseconds: 40);
  static const int _maxStaggered = 6;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePaddingH,
            AppSizes.md,
            AppSizes.pagePaddingH,
            AppSizes.sp12,
          ),
          child: Text(title, style: AppTypography.headline),
        ),
        SizedBox(
          height: _cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
            ),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: _cardGap),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final delay = _staggerStep * (index.clamp(0, _maxStaggered));
              return SizedBox(
                width: _cardWidth,
                child:
                    RecipeGridCard(
                          recipe: recipe,
                          flaggedAllergenKeys: flaggedAllergenKeys,
                          heroTag: heroEligibleIds.contains(recipe.id)
                              ? 'recipe-image-${recipe.id}'
                              : null,
                          onTap: () => context.pushNamed(
                            AppRoute.recipeDetail.name,
                            pathParameters: {'recipeId': recipe.id},
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: delay,
                          duration: AppDurations.fade,
                          curve: AppCurves.emphasized,
                        )
                        .slideX(
                          begin: 0.08,
                          end: 0,
                          delay: delay,
                          duration: AppDurations.slide,
                          curve: AppCurves.emphasized,
                        ),
              );
            },
          ),
        ),
      ],
    );
  }
}
