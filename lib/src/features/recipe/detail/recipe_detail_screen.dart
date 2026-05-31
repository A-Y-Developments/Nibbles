import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_controller.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_state.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_meal_plan_cta.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_meal_plan_sheet.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_shopping_list_sheet.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/contains_allergens_card.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/icon_section.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_banner_card.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_detail_header.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_hero.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_tip_card.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/storage_card_row.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// How long the success-toast stays on screen before auto-dismissing.
@visibleForTesting
const Duration kAddedToMealPlanToastDuration = Duration(seconds: 3);

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
      unawaited(
        Analytics.instance.logRecipeViewed(recipeId: widget.recipeId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          onRetry: () => ref.invalidate(
            recipeDetailControllerProvider(babyId, recipeId),
          ),
        ),
        data: (state) => _RecipeContent(
          babyId: babyId,
          recipeId: recipeId,
          state: state,
        ),
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
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
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
  bool _showSuccessBanner = false;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _showToast() {
    _toastTimer?.cancel();
    setState(() => _showSuccessBanner = true);
    _toastTimer = Timer(kAddedToMealPlanToastDuration, () {
      if (!mounted) return;
      setState(() => _showSuccessBanner = false);
    });
  }

  Future<void> _handleAddToMealPlan() async {
    final dates = await showAddToMealPlanSheet(
      context,
      babyId: widget.babyId,
    );
    if (dates == null || dates.isEmpty) return;
    if (!mounted) return;

    final controller = ref.read(
      recipeDetailControllerProvider(widget.babyId, widget.recipeId).notifier,
    );
    final addResult = await controller.assignToMealPlan(dates);

    if (!mounted) return;

    if (addResult.isSuccess) {
      _showToast();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't add to meal plan. Try again."),
        ),
      );
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to shopping list.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't add items. Try again.")),
      );
    }
  }

  Future<void> _handleOverflow() async {
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showModalBottomSheet<_OverflowAction>(
      context: context,
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
                Icons.shopping_basket_outlined,
                color: AppColors.greenDeep,
              ),
              title: const Text('Add to Shopping List'),
              onTap: () => Navigator.of(sheetContext)
                  .pop(_OverflowAction.addToShoppingList),
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );

    if (!mounted || choice == null) return;
    messenger.hideCurrentSnackBar();

    switch (choice) {
      case _OverflowAction.addToShoppingList:
        await _handleAddToShoppingList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final recipe = state.recipe;

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              RecipeDetailHeader(
                onBack: () => Navigator.of(context).maybePop(),
                onOverflow: _handleOverflow,
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: RecipeHero(imageUrl: recipe.thumbnailUrl),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePaddingH,
                        AppSizes.md,
                        AppSizes.pagePaddingH,
                        AppSizes.buttonHeight + AppSizes.xxl,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate.fixed([
                          RecipeBannerCard(
                            title: recipe.title,
                            ageRange: recipe.ageRange,
                            nutritionTags: recipe.nutritionTags,
                            category: recipe.category,
                          ),
                          if (recipe.allergenTags.isNotEmpty) ...[
                            const SizedBox(height: AppSizes.md),
                            ContainsAllergensCard(
                              allergenTags: recipe.allergenTags,
                              statuses: state.allergenStatuses,
                            ),
                          ],
                          const SizedBox(height: AppSizes.md),
                          IconSection(
                            icon: Icons.shopping_basket_outlined,
                            title: 'Ingredients',
                            child: _IngredientsList(
                              ingredients: recipe.ingredients,
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          IconSection(
                            icon: Icons.format_list_numbered,
                            title: 'Method',
                            child: _StepsList(steps: recipe.steps),
                          ),
                          if (state.utensils != null &&
                              state.utensils!.isNotEmpty) ...[
                            const SizedBox(height: AppSizes.lg),
                            IconSection(
                              icon: Icons.kitchen_outlined,
                              title: 'Utensils / appliances',
                              child: _UtensilsList(utensils: state.utensils!),
                            ),
                          ],
                          if (state.storageNote != null ||
                              state.freezerNote != null) ...[
                            const SizedBox(height: AppSizes.lg),
                            StorageCardRow(
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
                          if (recipe.notes != null &&
                              recipe.notes!.isNotEmpty) ...[
                            const SizedBox(height: AppSizes.lg),
                            IconSection(
                              icon: Icons.sticky_note_2_outlined,
                              title: 'Notes',
                              child: Text(
                                recipe.notes!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.fgDefault,
                                ),
                              ),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AddToMealPlanCta(
            isAdding: state.isAddingToMealPlan,
            onPressed: _handleAddToMealPlan,
          ),
        ),
        if (_showSuccessBanner)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSizes.xxl,
            left: 0,
            right: 0,
            child: const AddToMealPlanSuccessBanner(
              message: 'Succesfully added to meal plan',
            ),
          ),
      ],
    );
  }
}

enum _OverflowAction { addToShoppingList }

class _IngredientsList extends StatelessWidget {
  const _IngredientsList({required this.ingredients});

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < ingredients.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NumberDot(label: '${i + 1}'),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSizes.xs),
                    child: Text(
                      '${ingredients[i].quantity}  ${ingredients[i].name}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.fgDefault,
                      ),
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

class _StepsList extends StatelessWidget {
  const _StepsList({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NumberDot(label: '${i + 1}'),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSizes.xs),
                    child: Text(
                      steps[i],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.fgDefault,
                      ),
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

class _UtensilsList extends StatelessWidget {
  const _UtensilsList({required this.utensils});

  final List<String> utensils;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < utensils.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NumberDot(label: '${i + 1}'),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSizes.xs),
                    child: Text(
                      utensils[i],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.fgDefault,
                      ),
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

class _NumberDot extends StatelessWidget {
  const _NumberDot({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: AppSizes.tipGlyph,
      height: AppSizes.tipGlyph,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.greenDeep,
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: AppColors.cream,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
