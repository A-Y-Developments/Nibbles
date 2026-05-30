import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_grid_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// A horizontally-scrolling row of [RecipeGridCard]s under a section title.
///
/// Each card is pinned to the design-system 158x220 box per Figma 971:8760.
/// The row leaves the page padding intact (cards begin at
/// [AppSizes.pagePaddingH] from the left edge); horizontal padding is applied
/// to the inner list so that the section title and the first card both align
/// to the same gutter.
class RecipeCategoryRow extends StatelessWidget {
  const RecipeCategoryRow({
    required this.title,
    required this.recipes,
    this.flaggedAllergenKeys = const {},
    super.key,
  });

  final String title;
  final List<Recipe> recipes;
  final Set<String> flaggedAllergenKeys;

  static const double _cardWidth = 158;
  static const double _cardHeight = 220;

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
            AppSizes.sm + 2,
          ),
          child: Text(
            title,
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
        ),
        SizedBox(
          height: _cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
            ),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sp12),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return SizedBox(
                width: _cardWidth,
                child: RecipeGridCard(
                  recipe: recipe,
                  flaggedAllergenKeys: flaggedAllergenKeys,
                  onTap: () => context.pushNamed(
                    AppRoute.recipeDetail.name,
                    pathParameters: {'recipeId': recipe.id},
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
