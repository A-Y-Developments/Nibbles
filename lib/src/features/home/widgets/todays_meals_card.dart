import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/common/components/cards/recipe_plan_row.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Home — Today's meals card for the selected day.
///
/// Card body:
///   - "TODAY'S MEALS" overline + `mealCount/mealTarget` counter.
///   - A butter card wrapping a dashed lime inner card, one [RecipePlanRow]
///     per entry, plus a full-width "Add" pill.
///
/// Rows tap through to `recipeDetail`; the "Add" pill invokes [onAdd].
class TodaysMealsCard extends StatelessWidget {
  const TodaysMealsCard({
    required this.meals,
    required this.recipes,
    required this.mealCount,
    required this.mealTarget,
    required this.onAdd,
    super.key,
  });

  final List<MealPlanEntry> meals;
  final Map<String, Recipe> recipes;
  final int mealCount;
  final int mealTarget;
  final VoidCallback onAdd;

  void _openRecipe(BuildContext context, String recipeId) {
    unawaited(Analytics.instance.logRecipeViewed(recipeId: recipeId));
    context.pushNamed(
      AppRoute.recipeDetail.name,
      pathParameters: {'recipeId': recipeId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MealsOverlineRow(count: mealCount, target: mealTarget),
        const SizedBox(height: AppSizes.sm + 2),
        AppCard(
          padding: const EdgeInsets.all(AppSizes.md),
          child: AppCard(
            variant: AppCardVariant.dashed,
            borderColor: AppColors.lime,
            borderWidth: 2,
            cornerRadius: AppSizes.radiusMd,
            padding: const EdgeInsets.all(AppSizes.sp12),
            child: AnimatedSize(
              duration: AppDurations.slide,
              curve: AppCurves.emphasized,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...List<Widget>.generate(meals.length, (i) {
                    final entry = meals[i];
                    return Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : AppSizes.sp12),
                      child:
                          RecipePlanRow(
                                recipe: recipes[entry.recipeId],
                                onTap: () =>
                                    _openRecipe(context, entry.recipeId),
                              )
                              .animate(delay: AppDurations.fast * i)
                              .fadeIn(duration: AppDurations.fade)
                              .slideY(
                                begin: 0.08,
                                end: 0,
                                duration: AppDurations.slide,
                                curve: AppCurves.emphasized,
                              ),
                    );
                  }),
                  AnimatedSwitcher(
                    duration: AppDurations.base,
                    switchInCurve: AppCurves.standard,
                    switchOutCurve: AppCurves.standard,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1,
                        child: child,
                      ),
                    ),
                    child: mealCount < mealTarget
                        ? Column(
                            key: const ValueKey('home_add_meal_slot'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: AppSizes.sp12),
                              AppPillButton(
                                label: 'Add',
                                variant: AppPillButtonVariant.ghost,
                                onPressed: onAdd,
                                identifier: 'home_add_meal_button',
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MealsOverlineRow extends StatelessWidget {
  const _MealsOverlineRow({required this.count, required this.target});

  final int count;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Expanded(
            child: Text("Today's Meals", style: AppTypography.sectionTitle),
          ),
          Text('$count/$target', style: AppTypography.sectionTitle),
        ],
      ),
    );
  }
}
