import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

class MealDayCell extends StatelessWidget {
  const MealDayCell({
    required this.date,
    required this.isToday,
    required this.onTap,
    required this.onEdit,
    required this.onRemove,
    super.key,
    this.entry,
    this.recipe,
  });

  final DateTime date;
  final bool isToday;

  /// Non-null when a meal is assigned for this day.
  final MealPlanEntry? entry;

  /// Non-null when [entry] is non-null and the recipe was successfully fetched.
  final Recipe? recipe;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dayLabel = _dayLabels[date.weekday - 1];
    final hasEntry = entry != null;

    return GestureDetector(
      onTap: hasEntry ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.xs,
        ),
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isToday ? AppColors.primary : AppColors.divider,
            width: isToday ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Day label + date
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(
                    dayLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: isToday ? AppColors.primary : AppColors.subtext,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: textTheme.titleMedium?.copyWith(
                      color: isToday ? AppColors.primary : AppColors.text,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.md),
            // Content
            Expanded(
              child: hasEntry
                  ? _FilledContent(recipe: recipe)
                  : _EmptyContent(textTheme: textTheme),
            ),
            // Overflow menu for filled cells
            if (hasEntry) _OverflowMenu(onEdit: onEdit, onRemove: onRemove),
          ],
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      'No meal planned. Tap to add.',
      style: textTheme.bodySmall?.copyWith(color: AppColors.hint),
    );
  }
}

class _FilledContent extends StatelessWidget {
  const _FilledContent({required this.recipe});

  final Recipe? recipe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = recipe?.title ?? '…';
    final allergenTags = recipe?.allergenTags ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (allergenTags.isNotEmpty) ...[
          const SizedBox(height: AppSizes.xs),
          Wrap(
            spacing: AppSizes.xs,
            runSpacing: AppSizes.xs,
            children: allergenTags
                .take(3)
                .map((tag) => _AllergenChip(tag: tag))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _AllergenChip extends StatelessWidget {
  const _AllergenChip({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Text(
        tag,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primaryDark,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu({required this.onEdit, required this.onRemove});

  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      icon: const Icon(
        Icons.more_horiz,
        color: AppColors.subtext,
        size: AppSizes.iconMd,
      ),
      onSelected: (action) {
        switch (action) {
          case _MenuAction.edit:
            onEdit();
          case _MenuAction.remove:
            onRemove();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: _MenuAction.edit, child: Text('Edit meal')),
        PopupMenuItem(value: _MenuAction.remove, child: Text('Remove')),
      ],
    );
  }
}

enum _MenuAction { edit, remove }
