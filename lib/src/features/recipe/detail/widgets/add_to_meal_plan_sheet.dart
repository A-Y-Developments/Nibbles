import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/cards/recipe_plan_row.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_controller.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_date_range_form.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// Shows the plan-aware Add-to-Meal-Plan bottom sheet (Figma 971:8053
/// "Select Period Date" + 971:9467 "Meal Plan").
///
/// Renders as a single modal instance with two internal steps, keyed off
/// `mealPlanControllerProvider(babyId)`:
///  * Step 1 ("Select Period Date") only shows when the baby has no active
///    meal-plan period yet. Submitting it creates the plan, and the SAME
///    sheet instance swaps to Step 2 once the plan resolves.
///  * Step 2 ("Meal Plan") renders one accordion section per date in the
///    plan's window. Tapping "Add" for a date stacks a new pending pick of
///    [recipe] for that date (duplicates allowed); the bottom CTA saves every
///    pending pick as a single bulk append.
///
/// Returns `true` once something has been saved, or `null`/`false` when the
/// sheet is dismissed without saving.
Future<bool?> showAddToMealPlanSheet(
  BuildContext context, {
  required String babyId,
  required Recipe recipe,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => _AddToMealPlanSheet(babyId: babyId, recipe: recipe),
  );
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

List<DateTime> _daysBetween(DateTime start, DateTime end) {
  final days = <DateTime>[];
  var cursor = _dateOnly(start);
  final last = _dateOnly(end);
  while (!cursor.isAfter(last)) {
    days.add(cursor);
    cursor = cursor.add(const Duration(days: 1));
  }
  return days;
}

const List<String> _kWeekdayFull = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _kMonthShort = <String>[
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

/// Verbatim format: `Tuesday, 14 Apr`.
String _formatDate(DateTime d) =>
    '${_kWeekdayFull[d.weekday - 1]}, ${d.day} ${_kMonthShort[d.month - 1]}';

class _AddToMealPlanSheet extends ConsumerStatefulWidget {
  const _AddToMealPlanSheet({required this.babyId, required this.recipe});

  final String babyId;
  final Recipe recipe;

  @override
  ConsumerState<_AddToMealPlanSheet> createState() =>
      _AddToMealPlanSheetState();
}

class _AddToMealPlanSheetState extends ConsumerState<_AddToMealPlanSheet> {
  final Set<DateTime> _collapsedDays = <DateTime>{};
  final List<MealPlanEntry> _pendingEntries = <MealPlanEntry>[];
  bool _isSaving = false;

  int get _distinctPendingDayCount =>
      _pendingEntries.map((e) => _dateOnly(e.planDate)).toSet().length;

  void _addPending(DateTime day) {
    final index = _pendingEntries.length;
    setState(() {
      _pendingEntries.add(
        MealPlanEntry(
          id: 'pending-${widget.babyId}-$index',
          babyId: widget.babyId,
          recipeId: widget.recipe.id,
          planDate: day,
        ),
      );
    });
  }

  void _toggleCollapsed(DateTime day) {
    setState(() {
      if (!_collapsedDays.remove(day)) _collapsedDays.add(day);
    });
  }

  Future<void> _handleCreatePlan(DateTimeRange range) async {
    final ok = await ref
        .read(mealPlanControllerProvider(widget.babyId).notifier)
        .createPlan(range.start, range.end);
    if (!mounted) return;
    if (!ok) {
      AppToast.error(context, "Couldn't create your meal plan. Try again.");
    }
  }

  Future<void> _handleSave(DateTime windowStart, DateTime windowEnd) async {
    if (_pendingEntries.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);

    final assignments = _pendingEntries
        .map(
          (entry) => RecipeAssignment(
            recipeId: entry.recipeId,
            dayOffset: _dateOnly(entry.planDate).difference(windowStart).inDays,
          ),
        )
        .toList();
    final dayCount = _distinctPendingDayCount;

    final ok = await ref
        .read(mealPlanControllerProvider(widget.babyId).notifier)
        .appendBulkPrep(
          startDate: windowStart,
          endDate: windowEnd,
          assignments: assignments,
        );

    if (!mounted) return;

    if (ok) {
      unawaited(
        Analytics.instance.logRecipeAddedToMealPlan(
          recipeId: widget.recipe.id,
          dayCount: dayCount,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() => _isSaving = false);
      AppToast.error(context, "Couldn't add to meal plan. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(mealPlanControllerProvider(widget.babyId));

    return asyncState.when(
      loading: () => _SheetShell(
        title: 'Meal Plan',
        onClose: () => Navigator.of(context).pop(),
        child: const SizedBox(
          height: 200,
          child: Center(child: BrandFlowerLoader.small()),
        ),
      ),
      error: (error, _) => _SheetShell(
        title: 'Meal Plan',
        onClose: () => Navigator.of(context).pop(),
        child: const SizedBox(
          height: 200,
          child: Center(child: Text("Couldn't load your meal plan.")),
        ),
      ),
      data: (state) {
        if (state.plan == null) {
          return _SheetShell(
            title: 'Select Period Date',
            onClose: () => Navigator.of(context).pop(),
            child: SingleChildScrollView(
              child: MealPlanDateRangeForm(
                ctaLabel: 'Continue',
                onSubmit: _handleCreatePlan,
              ),
            ),
          );
        }

        final windowStart = state.windowStart;
        final windowEnd = state.windowEnd;
        final days = _daysBetween(windowStart, windowEnd);
        final recipes = <String, Recipe>{
          ...state.recipes,
          widget.recipe.id: widget.recipe,
        };
        final count = _distinctPendingDayCount;
        final ctaLabel = count == 0
            ? 'Add to Meal Plan'
            : '$count ${count == 1 ? 'Day' : 'Days'} Selected';

        return _SheetShell(
          title: 'Meal Plan',
          onClose: () => Navigator.of(context).pop(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: days.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSizes.sp12),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final dayEntries = state.entries
                        .where((e) => _dateOnly(e.planDate) == day)
                        .toList();
                    final dayPending = _pendingEntries
                        .where((e) => _dateOnly(e.planDate) == day)
                        .toList();
                    return _DaySection(
                      key: ValueKey(day),
                      day: day,
                      isExpanded: !_collapsedDays.contains(day),
                      rows: [...dayEntries, ...dayPending],
                      recipes: recipes,
                      onToggle: () => _toggleCollapsed(day),
                      onAdd: () => _addPending(day),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.sp12),
              AppPillButton(
                label: ctaLabel,
                onPressed: count == 0 || _isSaving
                    ? null
                    : () => _handleSave(windowStart, windowEnd),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({
    required this.title,
    required this.onClose,
    required this.child,
  });

  final String title;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(top: media.padding.top + AppSizes.xxl),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radius2xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sp12,
              vertical: AppSizes.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SheetHeader(title: title, onClose: onClose),
                const SizedBox(height: AppSizes.sp12),
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.fgStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppRoundButton(
          icon: const Icon(Icons.close),
          tone: AppRoundButtonTone.ghost,
          onPressed: onClose,
          semanticLabel: 'Close',
        ),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.isExpanded,
    required this.rows,
    required this.recipes,
    required this.onToggle,
    required this.onAdd,
    super.key,
  });

  final DateTime day;
  final bool isExpanded;
  final List<MealPlanEntry> rows;
  final Map<String, Recipe> recipes;
  final VoidCallback onToggle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.green.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DayHeader(day: day, isExpanded: isExpanded, onTap: onToggle),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.sp12,
                      0,
                      AppSizes.sp12,
                      AppSizes.sp12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final row in rows) ...[
                          RecipePlanRow(recipe: recipes[row.recipeId]),
                          const SizedBox(height: AppSizes.xs),
                        ],
                        AppPillButton(
                          label: 'Add',
                          size: AppPillButtonSize.small,
                          variant: AppPillButtonVariant.ghost,
                          onPressed: onAdd,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.isExpanded,
    required this.onTap,
  });

  final DateTime day;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _formatDate(day),
      hint: isExpanded ? 'Collapse day' : 'Expand day to add to meal plan',
      expanded: isExpanded,
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.sp12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(day),
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.fgStrong,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _DayChip(
                  icon: isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Forest-dark rounded-square chip — visual match to Figma 898:15849 (chevron
/// button in each day-section header). Decorative; pointer events fall
/// through to the wrapping header InkWell.
class _DayChip extends StatelessWidget {
  const _DayChip({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.roundButtonSm,
      height: AppSizes.roundButtonSm,
      decoration: BoxDecoration(
        color: AppColors.greenDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Icon(icon, color: AppColors.onGreen, size: AppSizes.iconSm),
    );
  }
}
