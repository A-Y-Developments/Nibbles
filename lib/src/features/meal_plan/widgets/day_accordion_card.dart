import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Action emitted by the per-card overflow menu.
enum DayCardMenuAction {
  /// Add this day's recipes to the shopping list.
  addToShopList,

  /// Clear meals for the entire current window.
  clearCurrentWeek,
}

/// Collapsible day card (Figma 971:8570). Renders the date header,
/// per-card overflow menu, a chevron, and on expand either a list of
/// recipe rows + a butter "Add" pill OR an empty hint + the same pill.
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

  static const _weekdayShort = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
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

  String _dateLabel() {
    final dow = _weekdayShort[day.weekday - 1];
    final mon = _monthShort[day.month - 1];
    return '$dow ${day.day} $mon';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.xs,
      ),
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
          if (isExpanded) ...[
            const SizedBox(height: AppSizes.sm),
            if (entries.isEmpty)
              _EmptyHint()
            else
              _RecipeList(
                entries: entries,
                recipes: recipes,
                flaggedAllergenKeys: flaggedAllergenKeys,
                onRecipeTap: onRecipeTap,
              ),
            const SizedBox(height: AppSizes.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: AppPillButton(
                label: '+ Add',
                size: AppPillButtonSize.small,
                variant: AppPillButtonVariant.ghost,
                expand: false,
                onPressed: onAdd,
              ),
            ),
          ],
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
  });

  final String dateLabel;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<DayCardMenuAction> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateLabel,
              style: AppTypography.textTheme.titleMedium,
            ),
          ),
          PopupMenuButton<DayCardMenuAction>(
            tooltip: 'More',
            icon: const Icon(
              Icons.more_horiz,
              color: AppColors.fgMuted,
              size: AppSizes.iconMd,
            ),
            onSelected: onMenuSelected,
            itemBuilder: (_) => const [
              PopupMenuItem<DayCardMenuAction>(
                value: DayCardMenuAction.addToShopList,
                child: Text('Add to shop list'),
              ),
              PopupMenuItem<DayCardMenuAction>(
                value: DayCardMenuAction.clearCurrentWeek,
                child: Text('Clear current week'),
              ),
            ],
          ),
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.fgMuted,
            size: AppSizes.iconMd,
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Text(
        'No meal plan yet.',
        style: AppTypography.caption.copyWith(color: AppColors.fgFaint),
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
          _RecipeRow(
            entry: entries[i],
            recipe: recipes[entries[i].recipeId],
            flaggedAllergenKeys: flaggedAllergenKeys,
            onTap: () => onRecipeTap(entries[i].recipeId),
          ),
        ],
      ],
    );
  }
}

class _RecipeRow extends StatelessWidget {
  const _RecipeRow({
    required this.entry,
    required this.recipe,
    required this.flaggedAllergenKeys,
    required this.onTap,
  });

  final MealPlanEntry entry;
  final Recipe? recipe;
  final Set<String> flaggedAllergenKeys;
  final VoidCallback onTap;

  static const _maxVisibleTags = 2;

  @override
  Widget build(BuildContext context) {
    final title = recipe?.title ?? '…';
    final tags = recipe?.allergenTags ?? const <String>[];
    final visible = tags.take(_maxVisibleTags).toList();
    final overflow = tags.length - visible.length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sp12,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.butterSoft,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            _Thumbnail(url: recipe?.thumbnailUrl),
            const SizedBox(width: AppSizes.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xs),
                    Wrap(
                      spacing: AppSizes.xs,
                      runSpacing: AppSizes.xs,
                      children: [
                        for (final tag in visible)
                          _AllergenTagChip(
                            tag: tag,
                            flagged: flaggedAllergenKeys.contains(tag),
                          ),
                        if (overflow > 0) _OverflowChip(count: overflow),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: url != null
          ? Image.network(
              url!,
              width: AppSizes.avatarSm,
              height: AppSizes.avatarSm,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _ThumbnailPlaceholder(),
            )
          : const _ThumbnailPlaceholder(),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.avatarSm,
      height: AppSizes.avatarSm,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: const Icon(
        Icons.restaurant,
        size: AppSizes.iconSm,
        color: AppColors.fgFaint,
      ),
    );
  }
}

class _AllergenTagChip extends StatelessWidget {
  const _AllergenTagChip({required this.tag, required this.flagged});

  final String tag;
  final bool flagged;

  @override
  Widget build(BuildContext context) {
    final emoji = AllergenEmoji.get(tag);
    final name = tag.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sp2,
      ),
      decoration: BoxDecoration(
        color: flagged ? AppColors.destructiveSoft : AppColors.coralSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        '$emoji $name',
        style: AppTypography.caption.copyWith(
          color: flagged ? AppColors.flagFg : AppColors.coralDeep,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OverflowChip extends StatelessWidget {
  const _OverflowChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sp2,
      ),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        '+$count',
        style: AppTypography.caption.copyWith(
          color: AppColors.coralDeep,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
