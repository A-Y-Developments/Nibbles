import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_grid_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Search-results view for the Recipe Library (Figma 971:8803).
///
/// Renders a flat vertical list of [RecipeGridCard]s — one card per result.
/// The category-rows layout (NIB-53) is suppressed by the parent screen
/// whenever `RecipeLibraryState.searchQuery` is non-empty; this widget owns
/// only the list rendering.
class RecipeSearchResults extends StatelessWidget {
  const RecipeSearchResults({
    required this.recipes,
    this.flaggedAllergenKeys = const {},
    super.key,
  });

  final List<Recipe> recipes;
  final Set<String> flaggedAllergenKeys;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        AppSizes.xl,
      ),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sp12),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeGridCard(
          recipe: recipe,
          flaggedAllergenKeys: flaggedAllergenKeys,
          onTap: () => context.pushNamed(
            AppRoute.recipeDetail.name,
            pathParameters: {'recipeId': recipe.id},
          ),
        );
      },
    );
  }
}
