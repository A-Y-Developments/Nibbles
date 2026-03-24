import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_controller.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_state.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_meal_plan_sheet.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_shopping_list_sheet.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _RecipeDetailBody(babyId: babyId, recipeId: recipeId);
      },
    );
  }
}

class _RecipeDetailBody extends ConsumerWidget {
  const _RecipeDetailBody({required this.babyId, required this.recipeId});

  final String babyId;
  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      recipeDetailControllerProvider(babyId, recipeId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Couldn't load recipe.",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    recipeDetailControllerProvider(babyId, recipeId),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (state) =>
            _RecipeContent(babyId: babyId, recipeId: recipeId, state: state),
      ),
    );
  }
}

class _RecipeContent extends ConsumerWidget {
  const _RecipeContent({
    required this.babyId,
    required this.recipeId,
    required this.state,
  });

  final String babyId;
  final String recipeId;
  final RecipeDetailState state;

  Future<void> _handleAddToMealPlan(BuildContext context, WidgetRef ref) async {
    final result = await showAddToMealPlanFlow(context);
    if (result == null) return;
    if (!context.mounted) return;

    final controller = ref.read(
      recipeDetailControllerProvider(babyId, recipeId).notifier,
    );
    final addResult = await controller.assignToMealPlan(
      result.date,
      time: result.time,
    );

    if (!context.mounted) return;

    if (addResult.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to meal plan')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't add to meal plan. Try again.")),
      );
    }
  }

  Future<void> _handleAddToShoppingList(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final selectedNames = await showAddToShoppingListSheet(
      context,
      state.recipe.ingredients,
    );
    if (selectedNames == null || selectedNames.isEmpty) return;
    if (!context.mounted) return;

    final controller = ref.read(
      recipeDetailControllerProvider(babyId, recipeId).notifier,
    );
    final addResult = await controller.addToShoppingList(selectedNames);

    if (!context.mounted) return;

    if (addResult.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to shopping list')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't add items. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = state.recipe;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),

                // Age range chip
                _AgeRangeChip(ageRange: recipe.ageRange),
                const SizedBox(height: AppSizes.sm),

                // Allergen chips
                if (recipe.allergenTags.isNotEmpty) ...[
                  _AllergenChipsRow(
                    tags: recipe.allergenTags,
                    currentKey: state.currentAllergenKey,
                    statuses: state.allergenStatuses,
                  ),
                  const SizedBox(height: AppSizes.md),
                ],

                // Ingredients
                const _SectionHeader(title: 'Ingredients'),
                const SizedBox(height: AppSizes.sm),
                _IngredientsList(ingredients: recipe.ingredients),
                const SizedBox(height: AppSizes.lg),

                // Steps
                const _SectionHeader(title: 'Steps'),
                const SizedBox(height: AppSizes.sm),
                _StepsList(steps: recipe.steps),
                const SizedBox(height: AppSizes.lg),

                // How to Serve
                const _SectionHeader(title: 'How to Serve'),
                const SizedBox(height: AppSizes.sm),
                Text(
                  recipe.howToServe,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.text),
                ),

                // Notes (optional)
                if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.lg),
                  const _SectionHeader(title: 'Notes'),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    recipe.notes!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
                  ),
                ],

                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),

        // Sticky CTA bar
        _CtaBar(
          isAddingToMealPlan: state.isAddingToMealPlan,
          isAddingToShoppingList: state.isAddingToShoppingList,
          onAddToMealPlan: () => _handleAddToMealPlan(context, ref),
          onAddToShoppingList: () => _handleAddToShoppingList(context, ref),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

class _AgeRangeChip extends StatelessWidget {
  const _AgeRangeChip({required this.ageRange});

  final String ageRange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + AppSizes.xs,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        'Fit for $ageRange',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AllergenChipsRow extends StatelessWidget {
  const _AllergenChipsRow({
    required this.tags,
    required this.currentKey,
    required this.statuses,
  });

  final List<String> tags;
  final String currentKey;
  final Map<String, AllergenStatus> statuses;

  Color _chipColor(String tag) {
    if (tag == currentKey) return const Color(0xFF2196F3);
    return switch (statuses[tag] ?? AllergenStatus.notStarted) {
      AllergenStatus.safe => AppColors.allergenSafe,
      AllergenStatus.flagged => AppColors.allergenFlagged,
      AllergenStatus.inProgress => AppColors.allergenInProgress,
      AllergenStatus.notStarted => AppColors.allergenNotStarted,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.xs,
      runSpacing: AppSizes.xs,
      children: tags.map((tag) {
        final emoji = AllergenEmoji.get(tag);
        final name = tag
            .split('_')
            .map(
              (w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}',
            )
            .join(' ');
        final color = _chipColor(tag);

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            '$emoji $name',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IngredientsList extends StatelessWidget {
  const _IngredientsList({required this.ingredients});

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final ingredient in ingredients)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.primary)),
                Expanded(
                  child: Text(
                    '${ingredient.quantity}  ${ingredient.name}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.text),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepsList extends StatelessWidget {
  const _StepsList({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      steps[i],
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.text),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CtaBar extends StatelessWidget {
  const _CtaBar({
    required this.isAddingToMealPlan,
    required this.isAddingToShoppingList,
    required this.onAddToMealPlan,
    required this.onAddToShoppingList,
  });

  final bool isAddingToMealPlan;
  final bool isAddingToShoppingList;
  final VoidCallback onAddToMealPlan;
  final VoidCallback onAddToShoppingList;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.sm,
        AppSizes.pagePaddingH,
        AppSizes.sm + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isAddingToShoppingList ? null : onAddToShoppingList,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppSizes.buttonHeight),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: isAddingToShoppingList
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add to Shopping List'),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: FilledButton(
              onPressed: isAddingToMealPlan ? null : onAddToMealPlan,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppSizes.buttonHeight),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: isAddingToMealPlan
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Add to Meal Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
