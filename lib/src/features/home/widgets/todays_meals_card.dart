import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Home — Today's meals card for the selected day.
///
/// Card body:
///   - "TODAY'S MEALS" overline + `mealCount/mealTarget` counter.
///   - Butter "Great job!" banner when coverage is met (>= target).
///   - A dashed lime inner card, one [_MealRow] per entry, plus an inline
///     "Add" pill when the day is under target.
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

  @override
  Widget build(BuildContext context) {
    final isComplete = mealCount >= mealTarget;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppSizes.shadowCard,
      ),
      padding: const EdgeInsets.all(AppSizes.sp12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MealsOverlineRow(count: mealCount, target: mealTarget),
          if (isComplete) ...[
            const SizedBox(height: AppSizes.sm),
            const _GreatJobBanner(),
          ],
          const SizedBox(height: AppSizes.sm + 2),
          AppCard(
            variant: AppCardVariant.dashed,
            borderColor: AppColors.lime,
            borderWidth: 2,
            cornerRadius: AppSizes.radiusMd,
            padding: const EdgeInsets.all(AppSizes.sp12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...List<Widget>.generate(meals.length, (i) {
                  final entry = meals[i];
                  return Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : AppSizes.sp12),
                    child: _MealRow(
                      entry: entry,
                      recipe: recipes[entry.recipeId],
                    ),
                  );
                }),
                if (!isComplete) ...[
                  const SizedBox(height: AppSizes.sp12),
                  AppPillButton(
                    label: 'Add',
                    onPressed: onAdd,
                    leading: const Icon(Icons.add),
                    identifier: 'home_add_meal_button',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
            '$count/$target',
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

/// Butter coverage banner — only rendered when the daily target is met.
class _GreatJobBanner extends StatelessWidget {
  const _GreatJobBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.lime),
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
            child: const Text('🎉', style: TextStyle(fontSize: 14, height: 1)),
          ),
          const SizedBox(width: AppSizes.sm + 2),
          Expanded(
            child: Text(
              'Great job! Everything important is covered',
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
  const _MealRow({required this.entry, this.recipe});

  final MealPlanEntry entry;
  final Recipe? recipe;

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final title =
        recipe?.title ??
        ((entry.mealTime?.isNotEmpty ?? false)
            ? _capitalize(entry.mealTime!)
            : 'Meal');

    final tags = <_TagChipData>[
      if ((recipe?.category ?? '').isNotEmpty)
        _TagChipData(
          label: _capitalize(recipe!.category!),
          icon: Icons.local_florist,
        ),
      for (final tag in (recipe?.nutritionTags ?? const <String>[]))
        _TagChipData(label: tag, icon: Icons.bolt),
    ];

    void handleTap() {
      unawaited(Analytics.instance.logRecipeViewed(recipeId: entry.recipeId));
      context.pushNamed(
        AppRoute.recipeDetail.name,
        pathParameters: {'recipeId': entry.recipeId},
      );
    }

    return Semantics(
      button: true,
      label: 'Meal, $title',
      excludeSemantics: true,
      onTap: handleTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          onTap: handleTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MealThumbnail(url: recipe?.thumbnailUrl),
                const SizedBox(width: AppSizes.sp12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.fgStrong,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.xs),
                        _TagChipsRow(tags: tags),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Meal-row thumbnail — real recipe photo (90x76) with an emoji fallback.
class _MealThumbnail extends StatelessWidget {
  const _MealThumbnail({this.url});

  final String? url;

  static const double _w = 90;
  static const double _h = 76;

  Widget _fallback() => Container(
    width: _w,
    height: _h,
    color: AppColors.surfaceVariant,
    alignment: Alignment.center,
    child: const Text('🍲', style: TextStyle(fontSize: 26, height: 1)),
  );

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusMd);
    if (url == null || url!.isEmpty) {
      return ClipRRect(borderRadius: radius, child: _fallback());
    }
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: _w,
        height: _h,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            Container(width: _w, height: _h, color: AppColors.surfaceVariant),
        errorWidget: (_, __, ___) => _fallback(),
      ),
    );
  }
}

class _TagChipData {
  const _TagChipData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _TagChipsRow extends StatelessWidget {
  const _TagChipsRow({required this.tags});

  final List<_TagChipData> tags;

  static const int _visible = 2;

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(_visible).toList(growable: false);
    final overflow = tags.length - visible.length;

    final chips = <Widget>[
      for (final tag in visible)
        AppChip(label: tag.label, icon: Icon(tag.icon, size: 12)),
      if (overflow > 0)
        AppChip(label: '+$overflow', icon: const Icon(Icons.add, size: 12)),
    ];

    return Wrap(
      spacing: AppSizes.xs + 2,
      runSpacing: AppSizes.xs,
      children: chips,
    );
  }
}
