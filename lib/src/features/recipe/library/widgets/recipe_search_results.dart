import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_grid_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Search-results view for the Recipe Library (Figma 971:8803).
///
/// Renders matching recipes as a 2-column grid of [RecipeGridCard]s pinned to
/// the design-system 158x220 box — mirrors the Figma typing-results layout
/// where a single match sits in the first grid cell with the title wrapping
/// onto two lines. The category-rows layout (NIB-53) is suppressed by the
/// parent screen whenever `RecipeLibraryState.searchQuery` is non-empty; this
/// widget owns only the grid rendering.
class RecipeSearchResults extends StatelessWidget {
  const RecipeSearchResults({
    required this.recipes,
    this.flaggedAllergenKeys = const {},
    super.key,
  });

  final List<Recipe> recipes;
  final Set<String> flaggedAllergenKeys;

  static const double _cardWidth = 158;
  static const double _cardHeight = 220;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        AppSizes.xl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.sp12,
        mainAxisSpacing: AppSizes.sp12,
        mainAxisExtent: _cardHeight,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        // Pin each cell to the 158x220 card box per Figma 971:8803 —
        // align top-left so wider grid cells (tablets) don't stretch the
        // card.
        return Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: _cardWidth,
            height: _cardHeight,
            child: RecipeGridCard(
              recipe: recipe,
              flaggedAllergenKeys: flaggedAllergenKeys,
              onTap: () => context.pushNamed(
                AppRoute.recipeDetail.name,
                pathParameters: {'recipeId': recipe.id},
              ),
            ),
          ),
        );
      },
    );
  }
}
