import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
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
            // Full-width lime "Add" pill (Figma 971:8619, 971:7804).
            AppPillButton(
              label: 'Add',
              variant: AppPillButtonVariant.ghost,
              onPressed: onAdd,
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
            child: Text(dateLabel, style: AppTypography.textTheme.titleMedium),
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
                value: DayCardMenuAction.clearCurrentWeek,
                child: _MenuRow(
                  icon: Icons.delete_outline,
                  label: 'Clear current week',
                ),
              ),
            ],
            child: const _DayCardChip(icon: Icons.more_horiz),
          ),
          const SizedBox(width: AppSizes.xs),
          // Green-filled rounded-square chevron button (Figma 971:8619).
          _DayCardChip(
            icon: isExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            onTap: onToggle,
          ),
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
      width: AppSizes.roundButtonSm,
      height: AppSizes.roundButtonSm,
      child: Icon(icon, color: AppColors.onGreen, size: AppSizes.iconMd),
    );
    return Material(
      color: AppColors.greenDeep,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: onTap == null
          ? box
          : InkWell(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
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
          'No meal plan yet.',
          style: AppTypography.textTheme.titleSmall,
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

    final flaggedNames = tags
        .where(flaggedAllergenKeys.contains)
        .map(AllergenEmoji.displayName)
        .toList();
    final semanticsLabel = flaggedNames.isEmpty
        ? title
        : '$title, flagged: ${flaggedNames.join(', ')}';

    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
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
                      style: AppTypography.textTheme.labelMedium,
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
    final name = AllergenEmoji.displayName(tag);
    return AppChip(
      label: name,
      emoji: emoji,
      tone: flagged ? AppChipTone.flag : AppChipTone.neutral,
    );
  }
}

class _OverflowChip extends StatelessWidget {
  const _OverflowChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppChip(label: '+$count');
  }
}
