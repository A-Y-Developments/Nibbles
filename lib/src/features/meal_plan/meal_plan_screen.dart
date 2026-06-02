import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_state.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_controller.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_state.dart';
import 'package:nibbles/src/features/meal_plan/sheets/browse_meal_sheet.dart';
import 'package:nibbles/src/features/meal_plan/sheets/select_period_date_sheet.dart';
import 'package:nibbles/src/features/meal_plan/widgets/add_date_pill.dart';
import 'package:nibbles/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart';
import 'package:nibbles/src/features/meal_plan/widgets/clear_confirm_dialog.dart';
import 'package:nibbles/src/features/meal_plan/widgets/day_accordion_card.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_empty_state.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_header.dart';
import 'package:nibbles/src/features/meal_plan/widgets/range_add_to_shoplist_sheet.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';
import 'package:nibbles/src/utils/age_in_months.dart';

/// `yyyy-MM-dd` for analytics. Locale-stable, no PII.
String _isoDate(DateTime dt) {
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '${dt.year}-$m-$d';
}

/// Screen-level overflow menu actions (Figma 971:7999).
enum _ScreenMenuAction { addToShopList, createMealPrep, clearCurrentWeek }

/// Rewritten Meal Plan screen (NIB-69).
///
/// Renders a butter-gradient [MealPlanHeader] + a vertical list of
/// [DayAccordionCard]s + an '+ Add Date' footer (or a [MealPlanEmptyState]
/// when there are no entries). Consumes NIB-87's [showBrowseMealSheet],
/// NIB-95's `AppRoute.mealPlanMap` + [MapMealsArgs], and NIB-103's
/// [showClearMealPlanConfirm].
class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        body: Center(
          child: Semantics(
            liveRegion: true,
            container: true,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.pagePaddingH),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load baby profile.'),
                  const SizedBox(height: AppSizes.sm),
                  FilledButton(
                    onPressed: () => ref.invalidate(currentBabyIdProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      data: (babyId) {
        if (babyId == null) {
          return Scaffold(
            body: Center(
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.pagePaddingH),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No baby profile found.'),
                      const SizedBox(height: AppSizes.sm),
                      FilledButton(
                        onPressed: () => context.pushNamed(
                          AppRoute.onboardingBabySetup.name,
                        ),
                        child: const Text('Set up baby profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return _MealPlanBody(babyId: babyId);
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _MealPlanBody extends ConsumerStatefulWidget {
  const _MealPlanBody({required this.babyId});

  final String babyId;

  @override
  ConsumerState<_MealPlanBody> createState() => _MealPlanBodyState();
}

class _MealPlanBodyState extends ConsumerState<_MealPlanBody> {
  /// Local override that extends the visible window beyond the controller's
  /// `windowEnd`. '+ Add Date' increments this by 1 day. Cleared when the
  /// controller state changes window (e.g. invalidate on the day rollover).
  DateTime? _extraEnd;

  /// Guard so `meal_plan_viewed` only fires once per mount, after the
  /// controller resolves with success.
  bool _viewedFired = false;

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(
      mealPlanControllerProvider(widget.babyId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: controllerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorView(
          onRetry: () =>
              ref.invalidate(mealPlanControllerProvider(widget.babyId)),
        ),
        data: _build,
      ),
    );
  }

  Widget _build(MealPlanState state) {
    final baby = state.baby;
    if (baby == null) {
      return const Center(child: Text('No baby profile found.'));
    }
    _fireViewedOnce(state);
    if (state.entries.isEmpty) {
      return MealPlanEmptyState(
        babyName: baby.name,
        ageMonths: ageInMonths(baby.dateOfBirth),
        onCreateMealPlan: _onCreateMealPlanFromEmpty,
        overflowButton: _NoFlashMenuTheme(
          child: Builder(
            builder: (btnContext) => MealPlanOverflowButton(
              onTap: () => _openEmptyStateMenu(btnContext),
            ),
          ),
        ),
      );
    }
    return _PopulatedView(
      babyId: widget.babyId,
      state: state,
      baby: baby,
      effectiveWindowEnd: _effectiveWindowEnd(state),
      onAddDate: _onAddDate,
      onScreenMenuSelected: _onScreenMenuSelected,
      onDayAdd: _onDayAdd,
      onDayMenuSelected: _onDayMenuSelected,
      onToggleExpanded: _onToggleExpanded,
      onRecipeTap: _onRecipeTap,
    );
  }

  void _fireViewedOnce(MealPlanState state) {
    if (_viewedFired) return;
    _viewedFired = true;
    final start = DateTime(
      state.windowStart.year,
      state.windowStart.month,
      state.windowStart.day,
    );
    final end = _effectiveWindowEnd(state);
    final dayCount = DateTime(end.year, end.month, end.day)
            .difference(start)
            .inDays +
        1;
    unawaited(
      ref.read(analyticsProvider).logMealPlanViewed(dayCount: dayCount),
    );
  }

  void _onToggleExpanded(DateTime day) {
    final notifier = ref.read(
      mealPlanControllerProvider(widget.babyId).notifier,
    );
    // Read current expanded state BEFORE toggling so we can fire the correct
    // expanded/collapsed event for the resulting state.
    final current = ref
        .read(mealPlanControllerProvider(widget.babyId))
        .valueOrNull;
    final key = DateTime.utc(day.year, day.month, day.day);
    final wasExpanded = current?.expanded[key] ?? false;
    notifier.toggleExpanded(day);
    final analytics = ref.read(analyticsProvider);
    final iso = _isoDate(day);
    if (wasExpanded) {
      unawaited(analytics.logMealPlanDayCollapsed(dayOffsetIso: iso));
    } else {
      unawaited(analytics.logMealPlanDayExpanded(dayOffsetIso: iso));
    }
  }

  DateTime _effectiveWindowEnd(MealPlanState state) {
    final extra = _extraEnd;
    if (extra == null) return state.windowEnd;
    return extra.isAfter(state.windowEnd) ? extra : state.windowEnd;
  }

  void _onAddDate() {
    final state = ref
        .read(mealPlanControllerProvider(widget.babyId))
        .valueOrNull;
    if (state == null) return;
    setState(() {
      final current = _effectiveWindowEnd(state);
      _extraEnd = current.add(const Duration(days: 1));
    });
    unawaited(ref.read(analyticsProvider).logMealPlanAddDateTapped());
  }

  Future<void> _onCreateMealPlanFromEmpty(DateTimeRange range) async {
    final days = range.end.difference(range.start).inDays + 1;
    unawaited(
      ref.read(analyticsProvider).logMealPrepRangeSelected(days: days),
    );
    final picked = await showBrowseMealSheet(
      context,
      babyId: widget.babyId,
      startDate: range.start,
      endDate: range.end,
    );
    if (picked == null || picked.isEmpty) return;
    if (!mounted) return;
    await _pushMapMeals(picked, range.start, range.end);
  }

  Future<void> _onDayAdd(DateTime day) async {
    final picked = await showBrowseMealSheet(
      context,
      babyId: widget.babyId,
      startDate: day,
      endDate: day,
    );
    if (picked == null || picked.isEmpty) return;
    if (!mounted) return;

    final assignments = [
      for (final r in picked)
        RecipeAssignment(recipeId: r.id, dayOffset: 0),
    ];
    final ok = await ref
        .read(mealPlanControllerProvider(widget.babyId).notifier)
        .appendBulkPrep(
          startDate: day,
          endDate: day,
          assignments: assignments,
        );
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't add to meal plan. Try again."),
          ),
        );
      }
      return;
    }
    final analytics = ref.read(analyticsProvider);
    final iso = _isoDate(day);
    for (final r in picked) {
      unawaited(
        analytics.logMealPlanRecipeAssigned(recipeId: r.id, dayOffsetIso: iso),
      );
    }
  }

  Future<void> _onScreenMenuSelected(_ScreenMenuAction action) async {
    final state = ref
        .read(mealPlanControllerProvider(widget.babyId))
        .valueOrNull;
    if (state == null) return;
    final analytics = ref.read(analyticsProvider);
    switch (action) {
      case _ScreenMenuAction.addToShopList:
        final start = DateTime(
          state.windowStart.year,
          state.windowStart.month,
          state.windowStart.day,
        );
        final end = _effectiveWindowEnd(state);
        final dayCount = DateTime(end.year, end.month, end.day)
                .difference(start)
                .inDays +
            1;
        unawaited(analytics.logMealPlanAddToShopList(dayCount: dayCount));
        await _openRangeAddToShoplist(start, end);
      case _ScreenMenuAction.createMealPrep:
        unawaited(analytics.logMealPrepCreateStarted());
        await _onCreateMealPrep(state);
      case _ScreenMenuAction.clearCurrentWeek:
        await _onClearWindow(state);
    }
  }

  Future<void> _onDayMenuSelected(
    DateTime day,
    DayCardMenuAction action,
  ) async {
    final state = ref
        .read(mealPlanControllerProvider(widget.babyId))
        .valueOrNull;
    if (state == null) return;
    switch (action) {
      case DayCardMenuAction.addToShopList:
        // Per NIB-109 spec, `meal_plan_add_to_shop_list` only fires from the
        // SCREEN-LEVEL overflow menu (see [_onScreenMenuSelected]). The
        // day-card menu intentionally does not fire it.
        await _openAddToShoppingList(day);
      case DayCardMenuAction.clearCurrentWeek:
        await _onClearWindow(state);
    }
  }

  Future<void> _onCreateMealPrep(MealPlanState state) async {
    // First let the user pick the date range via the Select Period Date
    // bottom-sheet (Figma 971:8000). Pre-fill with the current window so the
    // sheet opens on the same range the planner is showing.
    final range = await showSelectPeriodDateSheet(
      context,
      initialStart: state.windowStart,
      initialEnd: _effectiveWindowEnd(state),
    );
    if (range == null) return;
    if (!mounted) return;

    final days = range.end.difference(range.start).inDays + 1;
    unawaited(
      ref.read(analyticsProvider).logMealPrepRangeSelected(days: days),
    );
    final picked = await showBrowseMealSheet(
      context,
      babyId: widget.babyId,
      startDate: range.start,
      endDate: range.end,
    );
    if (picked == null || picked.isEmpty) return;
    if (!mounted) return;
    await _pushMapMeals(picked, range.start, range.end);
  }

  Future<void> _onClearWindow(MealPlanState state) async {
    final confirmed = await showClearMealPlanConfirm(context);
    if (confirmed != true) return;
    if (!mounted) return;
    final endDate = _effectiveWindowEnd(state);
    final ok = await ref
        .read(mealPlanControllerProvider(widget.babyId).notifier)
        .clearRange(state.windowStart, endDate);
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't clear meals. Try again.")),
        );
      }
      return;
    }
    final dayCount = endDate.difference(state.windowStart).inDays + 1;
    unawaited(
      ref
          .read(analyticsProvider)
          .logMealPlanClearWeekConfirmed(dayCount: dayCount),
    );
  }

  Future<void> _openAddToShoppingList(DateTime date) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (_) => AddToShoppingListModal(babyId: widget.babyId, date: date),
    );
  }

  /// NIB-136: range-scoped sheet from the screen-level overflow menu.
  Future<void> _openRangeAddToShoplist(DateTime start, DateTime end) async {
    await showRangeAddToShoplistSheet(
      context,
      babyId: widget.babyId,
      startDate: start,
      endDate: end,
    );
  }

  Future<void> _pushMapMeals(
    List<Recipe> picked,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await context.pushNamed<bool>(
      AppRoute.mealPlanMap.name,
      extra: MapMealsArgs(
        pickedRecipes: picked,
        startDate: startDate,
        endDate: endDate,
      ),
    );
    if ((result ?? false) && mounted) {
      ref.invalidate(mealPlanControllerProvider(widget.babyId));
    }
  }

  void _onRecipeTap(String recipeId) {
    context.pushNamed(
      AppRoute.recipeDetail.name,
      pathParameters: {'recipeId': recipeId},
    );
  }

  /// Opens the screen-level overflow menu while the empty state is showing.
  /// Empty state has no entries, so 'Add to shop list' and 'Clear current
  /// week' are not actionable — only the 'Create new meal prep' route is
  /// surfaced, which funnels through the same Select Period Date sheet.
  Future<void> _openEmptyStateMenu(BuildContext btnContext) async {
    final state = ref
        .read(mealPlanControllerProvider(widget.babyId))
        .valueOrNull;
    if (state == null) return;

    final renderBox = btnContext.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(btnContext).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final topRight = renderBox.localToGlobal(
      Offset(renderBox.size.width, 0),
      ancestor: overlay,
    );
    final position = RelativeRect.fromLTRB(
      topRight.dx - AppSizes.pagePaddingH * 2,
      topRight.dy + AppSizes.xxl,
      AppSizes.pagePaddingH,
      0,
    );

    final action = await showMenu<_ScreenMenuAction>(
      context: btnContext,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      items: const [
        PopupMenuItem<_ScreenMenuAction>(
          value: _ScreenMenuAction.createMealPrep,
          padding: EdgeInsets.zero,
          child: _ScreenMenuRow(
            icon: Icons.add,
            label: 'Create new meal prep',
            highlight: true,
          ),
        ),
      ],
    );
    if (action == _ScreenMenuAction.createMealPrep) {
      unawaited(ref.read(analyticsProvider).logMealPrepCreateStarted());
      await _onCreateMealPrep(state);
    }
  }
}

// ---------------------------------------------------------------------------
// Populated view
// ---------------------------------------------------------------------------

class _PopulatedView extends StatelessWidget {
  const _PopulatedView({
    required this.babyId,
    required this.state,
    required this.baby,
    required this.effectiveWindowEnd,
    required this.onAddDate,
    required this.onScreenMenuSelected,
    required this.onDayAdd,
    required this.onDayMenuSelected,
    required this.onToggleExpanded,
    required this.onRecipeTap,
  });

  final String babyId;
  final MealPlanState state;
  final Baby baby;
  final DateTime effectiveWindowEnd;
  final VoidCallback onAddDate;
  final ValueChanged<_ScreenMenuAction> onScreenMenuSelected;
  final ValueChanged<DateTime> onDayAdd;
  final void Function(DateTime, DayCardMenuAction) onDayMenuSelected;
  final ValueChanged<DateTime> onToggleExpanded;
  final ValueChanged<String> onRecipeTap;

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Match the controller's UTC date-only normalization (see
  /// `MealPlanController._expandedKey`) so accordion expand state survives
  /// across rebuilds.
  static DateTime _expandedKey(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day);

  List<DateTime> _days() {
    final start = _dateOnly(state.windowStart);
    final end = _dateOnly(effectiveWindowEnd);
    final count = end.difference(start).inDays + 1;
    return [for (var i = 0; i < count; i++) start.add(Duration(days: i))];
  }

  List<MealPlanEntry> _entriesForDay(DateTime day) {
    final key = _dateOnly(day);
    return state.entries.where((e) {
      final p = _dateOnly(e.planDate);
      return p == key;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final days = _days();

    return Column(
      children: [
        MealPlanHeader(
          babyName: baby.name,
          ageMonths: ageInMonths(baby.dateOfBirth),
          dayCount: days.length,
          overflowButton: _NoFlashMenuTheme(
            child: Builder(
              builder: (btnContext) => MealPlanOverflowButton(
                onTap: () => _openScreenMenu(btnContext),
              ),
            ),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final day = days[i];
                    return DayAccordionCard(
                      day: day,
                      entries: _entriesForDay(day),
                      recipes: state.recipes,
                      flaggedAllergenKeys: state.flaggedAllergenKeys,
                      isExpanded: state.expanded[_expandedKey(day)] ?? false,
                      onToggle: () => onToggleExpanded(day),
                      onAdd: () => onDayAdd(day),
                      onRecipeTap: onRecipeTap,
                      onMenuSelected: (action) =>
                          onDayMenuSelected(day, action),
                    );
                  },
                  childCount: days.length,
                ),
              ),
              SliverToBoxAdapter(child: AddDatePill(onPressed: onAddDate)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openScreenMenu(BuildContext context) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final topRight = renderBox.localToGlobal(
      Offset(renderBox.size.width, 0),
      ancestor: overlay,
    );
    final position = RelativeRect.fromLTRB(
      topRight.dx - AppSizes.pagePaddingH * 2,
      topRight.dy + AppSizes.xxl,
      AppSizes.pagePaddingH,
      0,
    );

    final action = await showMenu<_ScreenMenuAction>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      items: const [
        // First row carries the lime default-highlight (Figma 971:7826).
        PopupMenuItem<_ScreenMenuAction>(
          value: _ScreenMenuAction.addToShopList,
          padding: EdgeInsets.zero,
          child: _ScreenMenuRow(
            icon: Icons.shopping_cart_outlined,
            label: 'Add to shop list',
            highlight: true,
          ),
        ),
        PopupMenuItem<_ScreenMenuAction>(
          value: _ScreenMenuAction.createMealPrep,
          child: _ScreenMenuRow(
            icon: Icons.add,
            label: 'Create new meal prep',
          ),
        ),
        PopupMenuItem<_ScreenMenuAction>(
          value: _ScreenMenuAction.clearCurrentWeek,
          child: _ScreenMenuRow(
            icon: Icons.delete_outline,
            label: 'Clear current week',
          ),
        ),
      ],
    );
    if (action != null) onScreenMenuSelected(action);
  }
}

/// Strips the grey/tinted [InkWell] splash + highlight from the overflow
/// menu rows. `showMenu` captures the ambient [Theme] from the trigger
/// context, so wrapping the overflow button here makes the popup rows
/// stay white on press — only a resting `highlight` row paints lime.
class _NoFlashMenuTheme extends StatelessWidget {
  const _NoFlashMenuTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: child,
    );
  }
}

/// Row used inside the screen-level overflow popup. When [highlight] is
/// true the entire row paints in lime (butter) with forest-deep text +
/// icon — matches the default-active row in Figma 971:7826.
class _ScreenMenuRow extends StatelessWidget {
  const _ScreenMenuRow({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final fg = highlight ? AppColors.greenDeep : AppColors.fgStrong;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSm, color: fg),
        const SizedBox(width: AppSizes.sm),
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(color: fg),
        ),
      ],
    );
    if (!highlight) return row;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      color: AppColors.butter,
      child: row,
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
              style: AppTypography.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.sm),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
