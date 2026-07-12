import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/meal_plan/add_meals_for_day.dart';
import 'package:nibbles/src/features/meal_plan/ai/ai_loading_screen.dart';
import 'package:nibbles/src/features/meal_plan/ai/meal_preferences_sheet.dart';
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

/// `yyyy-MM-dd` for analytics. Locale-stable, no PII.
String _isoDate(DateTime dt) {
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '${dt.year}-$m-$d';
}

/// Screen-level overflow menu actions (Figma 971:7826).
enum _ScreenMenuAction { addToShopList, createMealPrep, clearCurrentPlan }

/// Meal Plan screen. Renders a butter-gradient [MealPlanHeader] + a vertical
/// list of [DayAccordionCard]s + a "+ Add Date" footer when a plan is active,
/// or a [MealPlanEmptyState] when there is no active plan. Drives the manual
/// (browse → map) and AI (preferences → loading → generate) meal-prep flows.
class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const GradientScaffold(
        body: Center(child: BrandFlowerLoader.small()),
      ),
      error: (_, __) => GradientScaffold(
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
          return GradientScaffold(
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
  /// Guard so `meal_plan_viewed` only fires once per mount, after the
  /// controller resolves with an active plan.
  bool _viewedFired = false;

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(
      mealPlanControllerProvider(widget.babyId),
    );

    return GradientScaffold(
      body: controllerAsync.when(
        loading: () => const Center(child: BrandFlowerLoader.small()),
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
    if (state.plan == null) {
      return MealPlanEmptyState(
        babyName: baby.name,
        onSetMealPrep: (range) => _startAiFlow(range, baby),
        onFillInMyself: _startManualFlow,
      );
    }
    _fireViewedOnce(state);
    return _PopulatedView(
      babyId: widget.babyId,
      state: state,
      baby: baby,
      effectiveWindowEnd: state.windowEnd,
      onRefresh: _refresh,
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
    final end = state.windowEnd;
    final dayCount =
        DateTime(end.year, end.month, end.day).difference(start).inDays + 1;
    unawaited(
      ref.read(analyticsProvider).logMealPlanViewed(dayCount: dayCount),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(mealPlanControllerProvider(widget.babyId));
    await ref.read(mealPlanControllerProvider(widget.babyId).future);
  }

  void _onToggleExpanded(DateTime day) {
    final notifier = ref.read(
      mealPlanControllerProvider(widget.babyId).notifier,
    );
    final current = ref
        .read(mealPlanControllerProvider(widget.babyId))
        .valueOrNull;
    final key = DateTime.utc(day.year, day.month, day.day);
    final wasExpanded = current?.expanded[key] ?? true;
    notifier.toggleExpanded(day);
    final analytics = ref.read(analyticsProvider);
    final iso = _isoDate(day);
    if (wasExpanded) {
      unawaited(analytics.logMealPlanDayCollapsed(dayOffsetIso: iso));
    } else {
      unawaited(analytics.logMealPlanDayExpanded(dayOffsetIso: iso));
    }
  }

  Future<void> _onAddDate() async {
    unawaited(ref.read(analyticsProvider).logMealPlanAddDateTapped());
    final ok = await ref
        .read(mealPlanControllerProvider(widget.babyId).notifier)
        .addDate();
    if (!ok && mounted) {
      AppToast.error(context, "Couldn't add date. Try again.");
    }
  }

  // --- Meal-prep entry flows ------------------------------------------------

  /// Manual path: browse recipes for the range, then map them onto days. The
  /// Map screen self-persists the plan (createPlan + append) on Finish.
  Future<void> _startManualFlow(DateTimeRange range) async {
    final days = range.end.difference(range.start).inDays + 1;
    unawaited(ref.read(analyticsProvider).logMealPrepRangeSelected(days: days));
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

  /// AI path: collect preferences + notes, run generation behind a full-screen
  /// non-dismissable loading route, then land on the populated planner.
  Future<void> _startAiFlow(DateTimeRange range, Baby baby) async {
    final analytics = ref.read(analyticsProvider);
    unawaited(analytics.logMealPrepAiStarted());

    final input = await showAiPreferencesFlow(context, babyName: baby.name);
    if (input == null || !mounted) return;
    unawaited(
      analytics.logMealPrepAiPreferencesSelected(
        count: input.preferences.length,
      ),
    );

    final result = await context.pushNamed<AiLoadingResult>(
      AppRoute.mealPlanAiLoading.name,
      extra: AiLoadingArgs(
        babyId: widget.babyId,
        babyName: baby.name,
        startDate: range.start,
        endDate: range.end,
        preferences: input.preferences,
        notes: input.notes,
      ),
    );
    if (!mounted || result == null) return;

    if (!result.success) {
      unawaited(analytics.logMealPrepAiFailed());
      await _showGenerateErrorDialog(result.errorMessage);
      return;
    }

    ref.invalidate(mealPlanControllerProvider(widget.babyId));
    final refreshed = await ref.read(
      mealPlanControllerProvider(widget.babyId).future,
    );
    final days = range.end.difference(range.start).inDays + 1;
    unawaited(analytics.logMealPlanCreated(days: days));
    unawaited(
      analytics.logMealPrepAiGenerated(
        recipeCount: refreshed.entries.length,
        dayCount: days,
      ),
    );
  }

  Future<void> _showGenerateErrorDialog(String? message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: const Text(
          "Couldn't build your plan",
          style: AppTypography.sectionTitle,
        ),
        content: Text(
          message ?? 'Please try again.',
          style: AppTypography.textTheme.bodyMedium,
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.greenDeep,
              foregroundColor: AppColors.onGreen,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('OK', style: AppTypography.button),
          ),
        ],
      ),
    );
  }

  Future<void> _onDayAdd(DateTime day) =>
      addMealsForDay(context, ref, babyId: widget.babyId, day: day);

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
        final end = state.windowEnd;
        final dayCount =
            DateTime(end.year, end.month, end.day).difference(start).inDays + 1;
        unawaited(analytics.logMealPlanAddToShopList(dayCount: dayCount));
        await _openRangeAddToShoplist(start, end);
      case _ScreenMenuAction.createMealPrep:
        unawaited(analytics.logMealPrepCreateStarted());
        await _onCreateMealPrep(state);
      case _ScreenMenuAction.clearCurrentPlan:
        await _onDeletePlan();
    }
  }

  Future<void> _onDayMenuSelected(
    DateTime day,
    DayCardMenuAction action,
  ) async {
    switch (action) {
      case DayCardMenuAction.addToShopList:
        await _openAddToShoppingList(day);
      case DayCardMenuAction.clearCurrentDate:
        await _onClearDay(day);
    }
  }

  Future<void> _onCreateMealPrep(MealPlanState state) async {
    final baby = state.baby;
    if (baby == null) return;
    // Pick range + mode via the Select Period Date sheet (Figma 971:8053).
    final result = await showSelectPeriodDateSheet(
      context,
      initialStart: state.windowStart,
      initialEnd: state.windowEnd,
    );
    if (result == null || !mounted) return;

    switch (result.mode) {
      case MealPrepMode.ai:
        await _startAiFlow(result.range, baby);
      case MealPrepMode.manual:
        await _startManualFlow(result.range);
    }
  }

  Future<void> _onDeletePlan() async {
    final confirmed = await showClearMealPlanConfirm(context);
    if (confirmed != true || !mounted) return;
    final ok = await ref
        .read(mealPlanControllerProvider(widget.babyId).notifier)
        .deleteActivePlan();
    if (!ok) {
      if (mounted) {
        AppToast.error(context, "Couldn't delete plan. Try again.");
      }
      return;
    }
    unawaited(ref.read(analyticsProvider).logMealPlanDeleted());
  }

  Future<void> _onClearDay(DateTime day) async {
    final confirmed = await showClearMealPlanConfirm(
      context,
      title: 'Clear all meals for this day?',
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref
        .read(mealPlanControllerProvider(widget.babyId).notifier)
        .clearDay(day);
    if (!ok) {
      if (mounted) {
        AppToast.error(context, "Couldn't clear meals. Try again.");
      }
      return;
    }
    unawaited(
      ref.read(analyticsProvider).logMealPlanClearWeekConfirmed(dayCount: 1),
    );
  }

  Future<void> _openAddToShoppingList(DateTime date) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
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
      final days = endDate.difference(startDate).inDays + 1;
      unawaited(ref.read(analyticsProvider).logMealPlanCreated(days: days));
    }
  }

  void _onRecipeTap(String recipeId) {
    context.pushNamed(
      AppRoute.recipeDetail.name,
      pathParameters: {'recipeId': recipeId},
    );
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
    required this.onRefresh,
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
  final Future<void> Function() onRefresh;
  final VoidCallback onAddDate;
  final ValueChanged<_ScreenMenuAction> onScreenMenuSelected;
  final ValueChanged<DateTime> onDayAdd;
  final void Function(DateTime, DayCardMenuAction) onDayMenuSelected;
  final ValueChanged<DateTime> onToggleExpanded;
  final ValueChanged<String> onRecipeTap;

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Match the controller's UTC date-only normalization so accordion expand
  /// state survives across rebuilds.
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
          overflowButton: _NoFlashMenuTheme(
            child: Builder(
              builder: (btnContext) => MealPlanOverflowButton(
                onTap: () => _openScreenMenu(btnContext),
              ),
            ),
          ),
        ),
        Expanded(
          child: BrandRefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final day = days[i];
                    return DayAccordionCard(
                      day: day,
                      entries: _entriesForDay(day),
                      recipes: state.recipes,
                      flaggedAllergenKeys: state.flaggedAllergenKeys,
                      isExpanded: state.expanded[_expandedKey(day)] ?? true,
                      onToggle: () => onToggleExpanded(day),
                      onAdd: () => onDayAdd(day),
                      onRecipeTap: onRecipeTap,
                      onMenuSelected: (action) =>
                          onDayMenuSelected(day, action),
                    );
                  }, childCount: days.length),
                ),
                SliverToBoxAdapter(child: AddDatePill(onPressed: onAddDate)),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
              ],
            ),
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
        PopupMenuItem<_ScreenMenuAction>(
          value: _ScreenMenuAction.addToShopList,
          child: _ScreenMenuRow(
            icon: Icons.shopping_cart_outlined,
            label: 'Add to shop list',
          ),
        ),
        PopupMenuItem<_ScreenMenuAction>(
          value: _ScreenMenuAction.createMealPrep,
          child: _ScreenMenuRow(icon: Icons.add, label: 'Create new meal prep'),
        ),
        PopupMenuItem<_ScreenMenuAction>(
          value: _ScreenMenuAction.clearCurrentPlan,
          child: _ScreenMenuRow(
            icon: Icons.delete_outline,
            label: 'Clear current plan',
          ),
        ),
      ],
    );
    if (action != null) onScreenMenuSelected(action);
  }
}

/// Strips the grey/tinted [InkWell] splash + highlight from the overflow
/// menu rows so the popup rows stay white on press — only a resting
/// `highlight` row paints lime.
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

/// Row used inside the screen-level overflow popup.
class _ScreenMenuRow extends StatelessWidget {
  const _ScreenMenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSm, color: AppColors.fgStrong),
        const SizedBox(width: AppSizes.sm),
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.fgStrong,
          ),
        ),
      ],
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
