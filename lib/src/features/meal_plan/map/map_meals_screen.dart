import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/meal_stage.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart'
    show MealPlanService;
import 'package:nibbles/src/features/meal_plan/map/map_meals_controller.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_state.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/day_chip_row.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/picked_recipe_row.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/selected_day_slot_list.dart';

/// Map Meals Plan full-screen (NIB-95).
///
/// Takes a list of picked recipes + a date range (handed in via
/// [MapMealsArgs] through `GoRouterState.extra`) and lets the user assign
/// picked recipes to days in the range by DRAGGING them onto the day
/// drop-zone or TAPPING them. The picked palette is reusable — a recipe can
/// be mapped onto many days. On Finish, creates/replaces the plan via
/// [MealPlanService.createPlan] then bulk-appends the mapped meals via
/// [MealPlanService.appendMealsToRange]. On success pops with `true`; on
/// failure shows a blocking P1 retry dialog.
class MapMealsScreen extends ConsumerWidget {
  const MapMealsScreen({required this.args, super.key});

  final MapMealsArgs args;

  static const _weekdayName = <int, String>{
    DateTime.monday: 'Monday',
    DateTime.tuesday: 'Tuesday',
    DateTime.wednesday: 'Wednesday',
    DateTime.thursday: 'Thursday',
    DateTime.friday: 'Friday',
    DateTime.saturday: 'Saturday',
    DateTime.sunday: 'Sunday',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapMealsControllerProvider(args));
    final notifier = ref.read(mapMealsControllerProvider(args).notifier);
    final mealsPerDay = _mealsPerDay(ref);

    return PopScope(
      canPop: state.assignments.isEmpty && !state.isCommitting,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await _confirmDiscard(context);
        if ((confirmed ?? false) && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: GradientScaffold(
        appBar: const _MapMealsAppBar(),
        body: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePaddingH,
                  0,
                  AppSizes.pagePaddingH,
                  AppSizes.md,
                ),
                child: Text(
                  '${state.filledCount} of ${state.totalSlots(mealsPerDay)} '
                  'slots filled',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.fgMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DayChipRow(
                startDate: state.startDate,
                endDate: state.endDate,
                selectedDay: state.selectedDay,
                fullDays: state.fullDays(mealsPerDay),
                onSelect: notifier.selectDay,
              ),
              const SizedBox(height: AppSizes.md),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePaddingH,
                  ),
                  children: [
                    _SelectedDayHeader(
                      state: state,
                      mealsPerDay: mealsPerDay,
                      weekdayNames: _weekdayName,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    _DayDropZone(
                      recipes: state.recipesForSelectedDay(),
                      onAccept: (recipe) =>
                          notifier.assignToSelectedDay(recipe.id),
                      onRemoveAt: notifier.unassignFromSelectedDayAt,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    _MealsPickedHeader(count: state.pickedRecipes.length),
                    const SizedBox(height: AppSizes.sm),
                    for (var i = 0; i < state.pickedRecipes.length; i++) ...[
                      if (i != 0) const SizedBox(height: AppSizes.sm),
                      PickedRecipeRow(
                        recipe: state.pickedRecipes[i],
                        onTap: () => notifier.assignToSelectedDay(
                          state.pickedRecipes[i].id,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
              _FinishBar(
                isCommitting: state.isCommitting,
                onFinish: () => _onFinish(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _mealsPerDay(WidgetRef ref) {
    final baby = ref.watch(currentBabyProvider).valueOrNull;
    if (baby == null) return 1;
    return mealsPerDayForDob(baby.dateOfBirth);
  }

  Future<bool?> _confirmDiscard(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: const Text(
          'Discard unsaved meal mappings?',
          style: AppTypography.sectionTitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep',
              style: AppTypography.button.copyWith(color: AppColors.fgMuted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.onGreen,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Discard', style: AppTypography.button),
          ),
        ],
      ),
    );
  }

  Future<void> _onFinish(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(mapMealsControllerProvider(args).notifier);
    final success = await notifier.commit();
    if (!context.mounted) return;
    if (success) {
      context.pop(true);
      return;
    }
    await _showRetryDialog(context, ref);
  }

  Future<void> _showRetryDialog(BuildContext context, WidgetRef ref) async {
    // Surface the controller's actual failure message (e.g. the P1
    // "No internet connection..." string on a connectivity failure) rather
    // than a generic hardcoded line.
    final message =
        ref.read(mapMealsControllerProvider(args)).errorMessage ??
        'Please try again';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: const Text(
            "Couldn't save your plan",
            style: AppTypography.sectionTitle,
          ),
          content: Text(message, style: AppTypography.textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.button.copyWith(color: AppColors.fgMuted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.greenDeep,
                foregroundColor: AppColors.onGreen,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _onFinish(context, ref);
              },
              child: Text('Retry', style: AppTypography.button),
            ),
          ],
        );
      },
    );
  }
}

/// `DragTarget<Recipe>` drop-zone wrapping the selected day's slot list.
///
/// Accepting a drop copies the recipe onto the selected day; while a drag
/// hovers the dashed border turns green (Figma 971:8511).
class _DayDropZone extends StatelessWidget {
  const _DayDropZone({
    required this.recipes,
    required this.onAccept,
    required this.onRemoveAt,
  });

  final List<Recipe> recipes;
  final ValueChanged<Recipe> onAccept;
  final ValueChanged<int> onRemoveAt;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Recipe>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        return SelectedDaySlotList(
          recipes: recipes,
          onRemoveAt: onRemoveAt,
          isHovering: candidate.isNotEmpty,
        );
      },
    );
  }
}

class _MapMealsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MapMealsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.fgDefault),
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text('Map Meals Plan', style: AppTypography.textTheme.titleLarge),
      centerTitle: false,
    );
  }
}

/// "Meals Picked" section header. Per Figma frames 03–07 the title sits
/// flush-left and the picked-count chip (`N selected`) sits flush-right
/// on the same row.
class _MealsPickedHeader extends StatelessWidget {
  const _MealsPickedHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text('Meals Picked', style: AppTypography.sectionTitle),
        ),
        Text(
          '$count selected',
          style: AppTypography.caption.copyWith(
            color: AppColors.fgMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SelectedDayHeader extends StatelessWidget {
  const _SelectedDayHeader({
    required this.state,
    required this.mealsPerDay,
    required this.weekdayNames,
  });

  final MapMealsState state;
  final int mealsPerDay;
  final Map<int, String> weekdayNames;

  @override
  Widget build(BuildContext context) {
    final dayName = weekdayNames[state.selectedDay.weekday] ?? '';
    final k = state.assignedCountForSelectedDay();
    return Text(
      'Meals for $dayName ($k/$mealsPerDay)',
      style: AppTypography.sectionTitle,
    );
  }
}

/// Floating bottom "Finish" pill for the Map Meals Plan screen.
///
/// Per the redesign the CTA is enabled at ANY time — partial (or empty)
/// mapping is allowed. Only disabled while a commit is in flight.
class _FinishBar extends StatelessWidget {
  const _FinishBar({required this.isCommitting, required this.onFinish});

  final bool isCommitting;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePaddingH,
          AppSizes.sm,
          AppSizes.pagePaddingH,
          AppSizes.sp12,
        ),
        child: isCommitting
            ? Semantics(
                button: true,
                enabled: false,
                label: 'Saving meal plan',
                excludeSemantics: true,
                child: const SizedBox(
                  height: AppSizes.buttonHeight,
                  child: Material(
                    color: AppColors.borderMuted,
                    shape: StadiumBorder(),
                    child: Center(
                      child: SizedBox(
                        width: AppSizes.iconSm,
                        height: AppSizes.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : AppPillButton(
                label: 'Finish',
                onPressed: onFinish,
                identifier: 'map-meals-finish',
              ),
      ),
    );
  }
}
