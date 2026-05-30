import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Home — Today's meals card (NIB-77, Figma 1242:10630).
///
/// 'Today, {Month Day}' title rendered outside the white card. The card
/// contains a butter coverage banner, a 'TODAY'S MEALS' overline + n/2 meta
/// counter, then meal rows. Each row taps to `recipeDetail` with the entry's
/// `recipeId`. When `todaysMeals` is empty, an inline 'No meals today'
/// placeholder is rendered inside the card (the full-screen empty state lives
/// in NIB-96).
///
/// Note: `MealPlanEntry` only carries `recipeId` (no recipe title or allergen
/// tags). Until home_controller hydrates recipes, each row shows a generic
/// thumb + the meal-time label (when present, falling back to 'Meal'). Tag
/// chips are intentionally omitted.
class TodaysMealsCard extends StatelessWidget {
  const TodaysMealsCard({
    required this.todaysMeals,
    super.key,
  });

  final List<MealPlanEntry> todaysMeals;

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const int _dailyTarget = 2;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final headerTitle =
        'Today, ${_shortMonths[today.month - 1]} ${today.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headerTitle, style: AppTypography.sectionTitle),
        const SizedBox(height: AppSizes.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            boxShadow: AppSizes.shadowCard,
          ),
          padding: const EdgeInsets.all(AppSizes.sp12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MealsOverlineRow(count: todaysMeals.length),
              const SizedBox(height: AppSizes.sm),
              const _CoverageBanner(),
              const SizedBox(height: AppSizes.sm + 2),
              if (todaysMeals.isEmpty)
                const _NoMealsInline()
              else
                ...List<Widget>.generate(todaysMeals.length, (i) {
                  final entry = todaysMeals[i];
                  return Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : AppSizes.sm),
                    child: _MealRow(entry: entry),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

class _MealsOverlineRow extends StatelessWidget {
  const _MealsOverlineRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              "TODAY'S MEALS",
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.greenDeep,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Text(
            '$count/${TodaysMealsCard._dailyTarget}',
            style: AppTypography.caption.copyWith(
              color: AppColors.fgFaint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageBanner extends StatelessWidget {
  const _CoverageBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md - 2,
        vertical: AppSizes.sm + 2,
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.checkbox + 4,
            height: AppSizes.checkbox + 4,
            decoration: const BoxDecoration(
              color: AppColors.coralSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🌱', style: TextStyle(fontSize: 14, height: 1)),
          ),
          const SizedBox(width: AppSizes.sm + 2),
          Expanded(
            child: Text(
              "Today's meals balance allergens and nutrition.",
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.fgStrong,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.entry});

  final MealPlanEntry entry;

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final mealTime = entry.mealTime;
    final label = (mealTime == null || mealTime.isEmpty)
        ? 'Meal'
        : _capitalize(mealTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: () {
          unawaited(
            Analytics.instance.logRecipeViewed(recipeId: entry.recipeId),
          );
          context.pushNamed(
            AppRoute.recipeDetail.name,
            pathParameters: {'recipeId': entry.recipeId},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.tanBase, AppColors.coral],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '🍲',
                  style: TextStyle(fontSize: 26, height: 1),
                ),
              ),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.fgStrong,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: AppSizes.iconMd,
                color: AppColors.fgFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoMealsInline extends StatelessWidget {
  const _NoMealsInline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm + 2,
      ),
      child: Text(
        'No meals today',
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.fgFaint,
        ),
      ),
    );
  }
}
