import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_controller.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_state.dart';
import 'package:nibbles/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart';
import 'package:nibbles/src/features/meal_plan/widgets/recipe_select_modal.dart';
import 'package:nibbles/src/routing/route_enums.dart';
import 'package:table_calendar/table_calendar.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _MealPlanBody(babyId: babyId);
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _MealPlanBody extends ConsumerWidget {
  const _MealPlanBody({required this.babyId});

  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerAsync = ref.watch(mealPlanControllerProvider(babyId));
    final notifier = ref.read(mealPlanControllerProvider(babyId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: controllerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(mealPlanControllerProvider(babyId)),
        ),
        data: (state) => _MealPlanContent(
          babyId: babyId,
          state: state,
          notifier: notifier,
          onAddMeal: (date) => _openRecipeSelect(context, ref, date),
          onRemoveEntry: (entry) => _removeEntry(context, ref, entry),
          onClearDay: (date) => _confirmClearDay(context, ref, date),
          onOpenShoppingList: () => _openShoppingListModal(context, ref, state),
        ),
      ),
    );
  }

  Future<void> _openRecipeSelect(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) async {
    final recipe = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (_) => RecipeSelectModal(babyId: babyId),
    );

    if (recipe == null) return;
    if (!context.mounted) return;

    final ok = await ref
        .read(mealPlanControllerProvider(babyId).notifier)
        .assignRecipe(date, recipe.id);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't add to meal plan. Try again.")),
      );
    }
  }

  Future<void> _removeEntry(
    BuildContext context,
    WidgetRef ref,
    MealPlanEntry entry,
  ) async {
    final ok = await ref
        .read(mealPlanControllerProvider(babyId).notifier)
        .removeEntry(entry.id);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't remove meal. Try again.")),
      );
    }
  }

  Future<void> _confirmClearDay(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear meals'),
        content: const Text(
          'This will remove all meals for this day. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final ok = await ref
        .read(mealPlanControllerProvider(babyId).notifier)
        .clearDay(date);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't clear meals. Try again.")),
      );
    }
  }

  Future<void> _openShoppingListModal(
    BuildContext context,
    WidgetRef ref,
    MealPlanState state,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (_) =>
          AddToShoppingListModal(babyId: babyId, date: state.selectedDate),
    );
  }
}

// ---------------------------------------------------------------------------
// Main content
// ---------------------------------------------------------------------------

class _MealPlanContent extends StatelessWidget {
  const _MealPlanContent({
    required this.babyId,
    required this.state,
    required this.notifier,
    required this.onAddMeal,
    required this.onRemoveEntry,
    required this.onClearDay,
    required this.onOpenShoppingList,
  });

  final String babyId;
  final MealPlanState state;
  final MealPlanController notifier;
  final Future<void> Function(DateTime) onAddMeal;
  final Future<void> Function(MealPlanEntry) onRemoveEntry;
  final Future<void> Function(DateTime) onClearDay;
  final VoidCallback onOpenShoppingList;

  static const _months = [
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

  String _weekLabel() {
    final weekEnd = state.weekStart.add(const Duration(days: 6));
    final sm = _months[state.weekStart.month - 1];
    final em = _months[weekEnd.month - 1];
    if (state.weekStart.month == weekEnd.month) {
      return '${state.weekStart.day} - ${weekEnd.day} $em';
    }
    return '${state.weekStart.day} $sm - ${weekEnd.day} $em';
  }

  List<MealPlanEntry> get _selectedMeals => state.meals.where((e) {
    final ep = DateTime(e.planDate.year, e.planDate.month, e.planDate.day);
    return ep == state.selectedDate;
  }).toList();

  String _dayMealLabel() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (state.selectedDate == todayOnly) return "Today's Meals";
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayLabel = days[state.selectedDate.weekday - 1];
    return '$dayLabel ${state.selectedDate.day} Meals';
  }

  @override
  Widget build(BuildContext context) {
    final selectedMeals = _selectedMeals;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Page title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.pagePaddingV,
                AppSizes.pagePaddingH,
                0,
              ),
              child: Text(
                'Meal Plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          // ── Week nav + calendar toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.xs,
                AppSizes.xs,
                AppSizes.xs,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.text,
                    onPressed: notifier.previousWeek,
                  ),
                  Text(
                    _weekLabel(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: AppColors.text,
                    onPressed: notifier.nextWeek,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      state.calendarExpanded
                          ? Icons.view_week_outlined
                          : Icons.calendar_month_outlined,
                      color: AppColors.subtext,
                    ),
                    tooltip: state.calendarExpanded
                        ? 'Switch to week strip'
                        : 'Switch to month view',
                    onPressed: notifier.toggleCalendar,
                  ),
                ],
              ),
            ),
          ),

          // ── Calendar strip or month calendar
          SliverToBoxAdapter(
            child: state.calendarExpanded
                ? _MonthCalendar(
                    selectedDate: state.selectedDate,
                    meals: state.meals,
                    onDaySelected: notifier.selectDate,
                  )
                : _DayStrip(
                    weekStart: state.weekStart,
                    selectedDate: state.selectedDate,
                    meals: state.meals,
                    onDaySelected: notifier.selectDate,
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),

          // ── Current Allergen section
          if (state.currentAllergenBoardItem != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                child: Text(
                  'Current Allergen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                child: _CurrentAllergenCard(
                  boardItem: state.currentAllergenBoardItem!,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),
          ],

          // ── Day meal section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
              ),
              child: Row(
                children: [
                  Text(
                    _dayMealLabel(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // Add meal button
                  IconButton(
                    onPressed: () => onAddMeal(state.selectedDate),
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.subtext,
                      size: AppSizes.iconMd,
                    ),
                    tooltip: 'Add meal',
                  ),
                  // Shopping list shortcut
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.subtext,
                      size: AppSizes.iconMd,
                    ),
                    tooltip: 'Add to shopping list',
                    onPressed: onOpenShoppingList,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),

          // ── Meal cards or empty state
          if (selectedMeals.isEmpty)
            const SliverToBoxAdapter(child: _EmptyDayState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final entry = selectedMeals[i];
                final recipe = state.recipes[entry.recipeId];
                return _MealCard(
                  entry: entry,
                  recipe: recipe,
                  flaggedAllergenKeys: state.flaggedAllergenKeys,
                  onRemove: () => onRemoveEntry(entry),
                  onTap: () => context.pushNamed(
                    AppRoute.recipeDetail.name,
                    pathParameters: {'recipeId': entry.recipeId},
                  ),
                );
              }, childCount: selectedMeals.length),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day strip
// ---------------------------------------------------------------------------

class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.weekStart,
    required this.selectedDate,
    required this.meals,
    required this.onDaySelected,
  });

  final DateTime weekStart;
  final DateTime selectedDate;
  final List<MealPlanEntry> meals;
  final ValueChanged<DateTime> onDaySelected;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool _hasMeal(DateTime dateOnly) => meals.any((e) {
    final ep = DateTime(e.planDate.year, e.planDate.month, e.planDate.day);
    return ep == dateOnly;
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.xs,
        ),
        itemCount: 7,
        itemBuilder: (context, i) {
          final date = weekStart.add(Duration(days: i));
          final dateOnly = DateTime(date.year, date.month, date.day);
          final isSelected = dateOnly == selectedDate;
          final hasMeal = _hasMeal(dateOnly);

          return GestureDetector(
            onTap: () => onDaySelected(date),
            child: Container(
              width: 52,
              margin: const EdgeInsets.only(right: AppSizes.xs),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.text : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.text : AppColors.divider,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayLabels[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.subtext,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.onPrimary : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: hasMeal
                          ? (isSelected
                                ? AppColors.onPrimary
                                : AppColors.primary)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month calendar
// ---------------------------------------------------------------------------

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.selectedDate,
    required this.meals,
    required this.onDaySelected,
  });

  final DateTime selectedDate;
  final List<MealPlanEntry> meals;
  final ValueChanged<DateTime> onDaySelected;

  bool _hasMeal(DateTime day) => meals.any((e) {
    final ep = DateTime(e.planDate.year, e.planDate.month, e.planDate.day);
    final d = DateTime(day.year, day.month, day.day);
    return ep == d;
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030, 12),
        focusedDay: selectedDate,
        selectedDayPredicate: (day) => isSameDay(day, selectedDate),
        onDaySelected: (selected, _) => onDaySelected(selected),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (!_hasMeal(day)) return null;
            return Positioned(
              bottom: 4,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: AppColors.text,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          weekendTextStyle: const TextStyle(color: AppColors.subtext),
          outsideDaysVisible: false,
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.subtext,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: AppColors.hint,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Current allergen card
// ---------------------------------------------------------------------------

class _CurrentAllergenCard extends StatelessWidget {
  const _CurrentAllergenCard({required this.boardItem});

  final AllergenBoardItem boardItem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final logs = boardItem.logs;
    final allergen = boardItem.allergen;
    final dayCount = min(logs.length, 3);
    final lastLog = logs.isEmpty
        ? null
        : (List<AllergenLog>.from(
            logs,
          )..sort((a, b) => b.logDate.compareTo(a.logDate))).first;

    final emoji = AllergenEmoji.get(allergen.key);

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoute.allergenTracker.name),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day $dayCount/3',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.subtext,
                    ),
                  ),
                  Text(allergen.name, style: textTheme.titleSmall),
                  if (lastLog != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Last logged ${_formatDate(lastLog.logDate)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => context.pushNamed(AppRoute.allergenTracker.name),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: Theme.of(context).textTheme.labelMedium,
              ),
              child: const Text('Check Allergen'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]}';
  }
}

// ---------------------------------------------------------------------------
// Meal card
// ---------------------------------------------------------------------------

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.entry,
    required this.recipe,
    required this.onRemove,
    required this.onTap,
    this.flaggedAllergenKeys = const {},
  });

  final MealPlanEntry entry;
  final Recipe? recipe;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final Set<String> flaggedAllergenKeys;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = recipe?.title ?? '…';
    final allergenCount = recipe?.allergenTags.length ?? 0;
    final flaggedTags =
        recipe?.allergenTags.where(flaggedAllergenKeys.contains).toList() ?? [];
    final isUnsafe = flaggedTags.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.xs,
        ),
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: isUnsafe
              ? Border.all(
                  color: AppColors.allergenFlagged.withValues(alpha: 0.4),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  child: recipe?.thumbnailUrl != null
                      ? Image.network(
                          recipe!.thumbnailUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ThumbnailPlaceholder(),
                        )
                      : _ThumbnailPlaceholder(),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (allergenCount > 0) ...[
                        const SizedBox(height: AppSizes.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: Text(
                            '$allergenCount Allergen'
                            '${allergenCount > 1 ? 's' : ''}',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.subtext,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<_CardMenuAction>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.subtext,
                    size: AppSizes.iconMd,
                  ),
                  onSelected: (action) {
                    if (action == _CardMenuAction.remove) onRemove();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _CardMenuAction.remove,
                      child: Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
            if (isUnsafe) ...[
              const SizedBox(height: AppSizes.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.allergenFlagged.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: AppColors.allergenFlagged,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Expanded(
                      child: Text(
                        'Contains flagged allergen: '
                        '${flaggedTags.map((t) => '${AllergenEmoji.get(t)} '
                            '${t.replaceAll('_', ' ')}').join(', ')}',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.allergenFlagged,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Thumbnail placeholder
// ---------------------------------------------------------------------------

class _ThumbnailPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 56, height: 56, color: AppColors.surfaceVariant);
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.lg,
      ),
      child: Center(
        child: Text(
          'No meals planned. Tap + Add to get started.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.hint),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load meal plan.',
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

enum _CardMenuAction { remove }
