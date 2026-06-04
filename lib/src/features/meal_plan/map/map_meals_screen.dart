import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
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
/// [MapMealsArgs] through `GoRouterState.extra` from NIB-87's Browse Meal
/// sheet) and lets the user assign each picked recipe to a day in the
/// range. On commit, calls [MealPlanService.appendMealsToRange] (APPEND
/// only — no replace per NIB-120). On success pops with `true`. On
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

  static const _weekdayShort = <int, String>{
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapMealsControllerProvider(args));
    final notifier = ref.read(mapMealsControllerProvider(args).notifier);

    return PopScope(
      canPop: state.assignments.isEmpty && !state.isCommitting,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await showDialog<bool>(
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
                  style: AppTypography.button.copyWith(
                    color: AppColors.fgMuted,
                  ),
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
        if ((confirmed ?? false) && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: _MapMealsAppBar(state: state),
        body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.md),
            DayChipRow(
              startDate: state.startDate,
              endDate: state.endDate,
              selectedDay: state.selectedDay,
              filledDays: state.filledDays(),
              onSelect: notifier.selectDay,
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                children: [
                  _SelectedDayHeader(state: state, weekdayNames: _weekdayName),
                  if (state.recipesForSelectedDay().isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Drag & drop or click meals below to add them',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.fgMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.sm),
                  SelectedDaySlotList(
                    recipes: state.recipesForSelectedDay(),
                    onRemove: notifier.unassign,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _MealsPickedHeader(totalCount: state.totalCount),
                  const SizedBox(height: AppSizes.sm),
                  for (var i = 0; i < state.pickedRecipes.length; i++) ...[
                    if (i != 0) const SizedBox(height: AppSizes.sm),
                    PickedRecipeRow(
                      recipe: state.pickedRecipes[i],
                      onTap: () => notifier.assignToSelectedDay(
                        state.pickedRecipes[i].id,
                      ),
                      assignedLabel: _assignedLabelFor(
                        state.pickedRecipes[i],
                        state,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
            _CommitBar(state: state, onCommit: () => _onCommit(context, ref)),
          ],
        ),
      ),
      ),
    );
  }

  String? _assignedLabelFor(Recipe recipe, MapMealsState state) {
    final assignedDay = state.assignments[recipe.id];
    if (assignedDay == null) return null;
    final abbrev = _weekdayShort[assignedDay.weekday] ?? '';
    return '$abbrev ${assignedDay.day}';
  }

  Future<void> _onCommit(BuildContext context, WidgetRef ref) async {
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
          content: Text(
            message,
            style: AppTypography.textTheme.bodyMedium,
          ),
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
                _onCommit(context, ref);
              },
              child: Text('Retry', style: AppTypography.button),
            ),
          ],
        );
      },
    );
  }
}

class _MapMealsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MapMealsAppBar({required this.state});

  final MapMealsState state;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cream,
      surfaceTintColor: AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.fgDefault),
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text('Map Meals Plan', style: AppTypography.textTheme.titleLarge),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSizes.pagePaddingH),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sp12,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.greenTint,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                '${state.filledCount} of ${state.totalCount} slots filled',
                style: AppTypography.caption.copyWith(
                  color: AppColors.greenDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Meals Picked" section header. Per Figma frames 03–07 the title sits
/// flush-left and the picked-count chip (`N selected`) sits flush-right
/// on the same row.
class _MealsPickedHeader extends StatelessWidget {
  const _MealsPickedHeader({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text('Meals Picked', style: AppTypography.sectionTitle),
        ),
        Text(
          '$totalCount selected',
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
  const _SelectedDayHeader({required this.state, required this.weekdayNames});

  final MapMealsState state;
  final Map<int, String> weekdayNames;

  @override
  Widget build(BuildContext context) {
    final dayName = weekdayNames[state.selectedDay.weekday] ?? '';
    final n = state.recipesForSelectedDay().length;
    final m = state.totalCount;
    return Text(
      'Meals for $dayName ($n/$m)',
      style: AppTypography.sectionTitle,
    );
  }
}

/// Floating commit bar for the Map Meals Plan screen.
///
/// Per the Figma spec (frames 971:8375 → 971:8511) the CTA progresses
/// through three states based on how many picked recipes are assigned:
///
/// * 0 assignments      → bar is hidden (frames 03/04 show no CTA at all)
/// * 1..N-1 assignments → `Add (<remaining>)`
/// * N == totalCount    → `Complete Mapping`
class _CommitBar extends StatelessWidget {
  const _CommitBar({required this.state, required this.onCommit});

  final MapMealsState state;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final filled = state.filledCount;
    final total = state.totalCount;
    if (filled == 0) return const SizedBox.shrink();

    final isComplete = filled >= total;
    final label = isComplete ? 'Complete Mapping' : 'Add (${total - filled})';
    final disabled = state.isCommitting;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePaddingH,
          AppSizes.sm,
          AppSizes.pagePaddingH,
          AppSizes.sp12,
        ),
        child: Semantics(
          button: true,
          enabled: !disabled,
          label: state.isCommitting ? 'Saving meal plan' : label,
          child: SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.greenDeep,
                foregroundColor: AppColors.onGreen,
                disabledBackgroundColor: AppColors.borderMuted,
                disabledForegroundColor: AppColors.fgFaint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              ),
              onPressed: disabled ? null : onCommit,
              child: state.isCommitting
                  ? const ExcludeSemantics(
                      child: SizedBox(
                        width: AppSizes.iconSm,
                        height: AppSizes.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onGreen,
                        ),
                      ),
                    )
                  : Text(label, style: AppTypography.button),
            ),
          ),
        ),
      ),
    );
  }
}
