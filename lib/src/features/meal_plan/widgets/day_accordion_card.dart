import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/common/components/cards/recipe_plan_row.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Action emitted by the per-card overflow menu.
enum DayCardMenuAction {
  /// Add this day's recipes to the shopping list.
  addToShopList,

  /// Clear all meals for this single day.
  clearCurrentDate,
}

/// Collapsible day card (Figma 971:8619 / 971:8571).
///
/// A day WITH meals renders a solid card: date header + `⋯` menu + chevron,
/// and on expand a list of recipe rows + a ghost "Add" pill. A day with NO
/// meals renders a dashed card with a "No meal plan yet" hint + "Add" pill
/// (always visible — no chevron).
class DayAccordionCard extends StatelessWidget {
  const DayAccordionCard({
    required this.day,
    required this.entries,
    required this.recipes,
    required this.flaggedAllergenKeys,
    required this.isExpanded,
    required this.onToggle,
    required this.onAdd,
    required this.onRecipeTap,
    required this.onMenuSelected,
    super.key,
  });

  final DateTime day;
  final List<MealPlanEntry> entries;
  final Map<String, Recipe> recipes;
  final Set<String> flaggedAllergenKeys;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onAdd;
  final ValueChanged<String> onRecipeTap;
  final ValueChanged<DayCardMenuAction> onMenuSelected;

  static const _weekdayFull = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _monthShort = <String>[
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

  /// Spec format: `Tuesday, 14 Apr` (Figma 971:8619 verbatim).
  String _dateLabel() {
    final dow = _weekdayFull[day.weekday - 1];
    final mon = _monthShort[day.month - 1];
    return '$dow, ${day.day} $mon';
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = entries.isEmpty;
    const margin = EdgeInsets.symmetric(
      horizontal: AppSizes.pagePaddingH,
      vertical: AppSizes.xs,
    );

    if (isEmpty) {
      return Padding(
        padding: margin,
        child: AppCard(
          variant: AppCardVariant.dashed,
          padding: const EdgeInsets.all(AppSizes.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                dateLabel: _dateLabel(),
                isExpanded: isExpanded,
                onToggle: onToggle,
                onMenuSelected: onMenuSelected,
                showChevron: false,
              ),
              const SizedBox(height: AppSizes.sm),
              _EmptyHint(),
              const SizedBox(height: AppSizes.sm),
              AppPillButton(
                label: 'Add',
                variant: AppPillButtonVariant.ghost,
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            dateLabel: _dateLabel(),
            isExpanded: isExpanded,
            onToggle: onToggle,
            onMenuSelected: onMenuSelected,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSizes.sm),
                      _RecipeList(
                        entries: entries,
                        recipes: recipes,
                        flaggedAllergenKeys: flaggedAllergenKeys,
                        onRecipeTap: onRecipeTap,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      AppPillButton(
                        label: 'Add',
                        variant: AppPillButtonVariant.ghost,
                        onPressed: onAdd,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.dateLabel,
    required this.isExpanded,
    required this.onToggle,
    required this.onMenuSelected,
    this.showChevron = true,
  });

  final String dateLabel;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<DayCardMenuAction> onMenuSelected;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: showChevron ? onToggle : null,
      child: Row(
        children: [
          Expanded(
            child: Text(dateLabel, style: AppTypography.textTheme.titleSmall),
          ),
          // Green-filled rounded-square overflow button (Figma 971:8619).
          PopupMenuButton<DayCardMenuAction>(
            tooltip: 'More',
            position: PopupMenuPosition.under,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            padding: EdgeInsets.zero,
            onSelected: onMenuSelected,
            itemBuilder: (_) => const [
              PopupMenuItem<DayCardMenuAction>(
                value: DayCardMenuAction.addToShopList,
                child: _MenuRow(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Add to shop list',
                ),
              ),
              PopupMenuItem<DayCardMenuAction>(
                value: DayCardMenuAction.clearCurrentDate,
                child: _MenuRow(
                  icon: Icons.delete_outline,
                  label: 'Clear current date',
                ),
              ),
            ],
            child: const _DayCardChip(icon: Icons.more_horiz),
          ),
          if (showChevron) ...[
            const SizedBox(width: AppSizes.xs),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: _DayCardChip(
                icon: Icons.keyboard_arrow_down,
                onTap: onToggle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Green-deep rounded-square chip used in the day-card header for the
/// overflow (left) and chevron (right) buttons. Matches the screen-level
/// header's `MealPlanOverflowButton` visual.
class _DayCardChip extends StatelessWidget {
  const _DayCardChip({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = SizedBox(
      width: AppSizes.roundButtonMd,
      height: AppSizes.roundButtonMd,
      child: Icon(icon, color: AppColors.onGreen, size: AppSizes.iconMd),
    );
    return Material(
      color: AppColors.greenDeep,
      shape: const CircleBorder(),
      child: onTap == null
          ? box
          : InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: box,
            ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSm, color: AppColors.fgStrong),
        const SizedBox(width: AppSizes.sm),
        Text(label, style: AppTypography.textTheme.bodyMedium),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Center(
        child: Text(
          'No meal plan yet',
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: AppColors.fgMuted,
          ),
        ),
      ),
    );
  }
}

class _RecipeList extends StatelessWidget {
  const _RecipeList({
    required this.entries,
    required this.recipes,
    required this.flaggedAllergenKeys,
    required this.onRecipeTap,
  });

  final List<MealPlanEntry> entries;
  final Map<String, Recipe> recipes;
  final Set<String> flaggedAllergenKeys;
  final ValueChanged<String> onRecipeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i != 0) const SizedBox(height: AppSizes.xs),
          RecipePlanRow(
            recipe: recipes[entries[i].recipeId],
            onTap: () => onRecipeTap(entries[i].recipeId),
            flaggedAllergenNames:
                (recipes[entries[i].recipeId]?.allergenTags ?? const <String>[])
                    .where(flaggedAllergenKeys.contains)
                    .map(AllergenEmoji.displayName)
                    .toList(),
          ),
        ],
      ],
    );
  }
}
