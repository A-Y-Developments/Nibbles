import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_controller.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_state.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_meal_plan_sheet.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_shopping_list_sheet.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/contains_allergens_card.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_hero_banner.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_steps_card.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_storage_row.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_tip_card.dart';
import 'package:nibbles/src/logging/analytics.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(Analytics.instance.logRecipeViewed(recipeId: widget.recipeId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const GradientScaffold(
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading recipe'),
        ),
      ),
      error: (_, __) => GradientScaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Semantics(
          liveRegion: true,
          container: true,
          child: const Center(child: Text('Could not load baby profile.')),
        ),
      ),
      data: (babyId) {
        if (babyId == null) {
          return GradientScaffold(
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: Semantics(
              liveRegion: true,
              container: true,
              child: const Center(child: Text('No baby profile found.')),
            ),
          );
        }
        return _RecipeDetailBody(babyId: babyId, recipeId: widget.recipeId);
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

    return GradientScaffold(
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading recipe'),
        ),
        error: (error, _) => _ErrorView(
          onRetry: () =>
              ref.invalidate(recipeDetailControllerProvider(babyId, recipeId)),
        ),
        data: (state) =>
            _RecipeContent(babyId: babyId, recipeId: recipeId, state: state),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _RecipeContent extends ConsumerStatefulWidget {
  const _RecipeContent({
    required this.babyId,
    required this.recipeId,
    required this.state,
  });

  final String babyId;
  final String recipeId;
  final RecipeDetailState state;

  @override
  ConsumerState<_RecipeContent> createState() => _RecipeContentState();
}

class _RecipeContentState extends ConsumerState<_RecipeContent> {
  Future<void> _handleAddToMealPlan() async {
    final saved = await showAddToMealPlanSheet(
      context,
      babyId: widget.babyId,
      recipe: widget.state.recipe,
    );
    if (saved != true) return;
    if (!mounted) return;

    AppToast.success(context, 'Successfully added to meal plan');
  }

  Future<void> _handleAddToShoppingList() async {
    final recipe = widget.state.recipe;
    final selected = await showAddToShoppingListSheet(
      context,
      recipe.ingredients,
    );
    if (selected == null || selected.isEmpty) return;
    if (!mounted) return;

    final controller = ref.read(
      recipeDetailControllerProvider(widget.babyId, widget.recipeId).notifier,
    );
    final result = await controller.addToShoppingList(selected);

    if (!mounted) return;

    if (result.isSuccess) {
      AppToast.success(context, 'Added to shopping list.');
    } else {
      AppToast.error(context, "Couldn't add items. Try again.");
    }
  }

  Future<void> _handleOverflow() async {
    final choice = await showModalBottomSheet<_OverflowAction>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.sm),
            Container(
              width: AppSizes.sp40,
              height: AppSizes.xs,
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            ListTile(
              leading: const Icon(
                Icons.restaurant_outlined,
                color: AppColors.greenDeep,
              ),
              title: const Text('Add to Meal Plan'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_OverflowAction.addToMealPlan),
            ),
            ListTile(
              leading: const Icon(
                Icons.shopping_basket_outlined,
                color: AppColors.greenDeep,
              ),
              title: const Text('Add to Shopping List'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(_OverflowAction.addToShoppingList),
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );

    if (!mounted || choice == null) return;

    switch (choice) {
      case _OverflowAction.addToMealPlan:
        await _handleAddToMealPlan();
      case _OverflowAction.addToShoppingList:
        await _handleAddToShoppingList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final recipe = state.recipe;
    final hasStorage = state.storageNote != null || state.freezerNote != null;

    return SafeArea(
      child: Column(
        children: [
          _TopBar(
            onBack: () => Navigator.of(context).maybePop(),
            onOverflow: _handleOverflow,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSizes.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RecipeHeroBanner(
                    imageUrl: recipe.thumbnailUrl,
                    title: recipe.title,
                    ageRange: recipe.ageRange,
                    nutritionTags: recipe.nutritionTags,
                    makes: recipe.makes,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      AppSizes.md,
                      AppSizes.md,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (recipe.allergenTags.isNotEmpty) ...[
                          ContainsAllergensCard(
                            allergenTags: recipe.allergenTags,
                          ),
                          const SizedBox(height: AppSizes.md),
                        ],
                        RecipeStepsCard(
                          ingredients: recipe.ingredients,
                          steps: recipe.steps,
                          utensils: state.utensils ?? const [],
                        ),
                        if (hasStorage) ...[
                          const SizedBox(height: AppSizes.md),
                          RecipeStorageRow(
                            storageNote: state.storageNote,
                            freezerNote: state.freezerNote,
                          ),
                        ],
                        if (state.textureTip != null) ...[
                          const SizedBox(height: AppSizes.md),
                          RecipeTipCard(
                            kind: RecipeTipKind.textureTip,
                            body: state.textureTip,
                          ),
                        ],
                        if (state.whyThisMeal != null) ...[
                          const SizedBox(height: AppSizes.md),
                          RecipeTipCard(
                            kind: RecipeTipKind.whyThisMeal,
                            body: state.whyThisMeal,
                          ),
                        ],
                        const SizedBox(height: AppSizes.md),
                        Row(
                          children: [
                            Expanded(
                              child: AppPillButton(
                                label: 'Add to Meal Plan',
                                onPressed: _handleAddToMealPlan,
                                identifier: 'recipe_detail_add_to_meal_plan',
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: AppPillButton(
                                label: 'Add to Shopping List',
                                variant: AppPillButtonVariant.secondary,
                                onPressed: _handleAddToShoppingList,
                                identifier:
                                    'recipe_detail_add_to_shopping_list',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _OverflowAction { addToMealPlan, addToShoppingList }

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onOverflow});

  final VoidCallback onBack;
  final VoidCallback onOverflow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.fgStrong),
            tooltip: 'Back',
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            'Recipe Detail',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.fgStrong),
          ),
          const Spacer(),
          IconButton(
            onPressed: onOverflow,
            icon: const Icon(Icons.more_horiz, color: AppColors.fgStrong),
            tooltip: 'More options',
          ),
        ],
      ),
    );
  }
}
