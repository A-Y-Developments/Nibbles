import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/guidance_tip.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/guidance_service.dart';
import 'package:nibbles/src/features/home/home_controller.dart';
import 'package:nibbles/src/utils/age_in_months.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_day_view.freezed.dart';
part 'home_day_view.g.dart';

/// Number of meals a full day targets — drives the meals ring (`/2`).
const int kDailyMealTarget = 2;

/// Pure client-side slice of `HomeState` for a single selected day. Recomputed
/// whenever the selected date or the controller data changes — no refetch.
@freezed
class HomeDayView with _$HomeDayView {
  const factory HomeDayView({
    @Default(<MealPlanEntry>[]) List<MealPlanEntry> meals,
    @Default(<String, Recipe>{}) Map<String, Recipe> recipes,
    @Default(0) int mealCount,
    @Default(kDailyMealTarget) int mealTarget,
    @Default(false) bool ironRich,
    @Default(false) bool isToday,
    @Default(<GuidanceTip>[]) List<GuidanceTip> guidance,
  }) = _HomeDayView;
}

/// The day the Home date strip has selected (date-only). Defaults to today.
/// A "Today" pill resets it via
/// `ref.read(selectedHomeDateProvider.notifier).state = homeDateOnly(...)`.
final selectedHomeDateProvider = StateProvider<DateTime>(
  (ref) => homeDateOnly(DateTime.now()),
);

/// Strips the time component so date comparisons are day-granular.
DateTime homeDateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Derived view for the selected day. Watches the controller (full dataset)
/// and the selected date, then slices client-side. Returns an empty view
/// (still flagging `isToday`) while the controller is loading or errored.
@riverpod
HomeDayView homeDayView(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  HomeDayViewRef ref,
  String babyId,
) {
  final selected = ref.watch(selectedHomeDateProvider);
  final state = ref.watch(homeControllerProvider(babyId)).valueOrNull;
  final isToday = _isSameDay(selected, DateTime.now());

  if (state == null) {
    return HomeDayView(isToday: isToday);
  }

  final meals = state.allMeals
      .where((e) => _isSameDay(e.planDate, selected))
      .toList(growable: false);

  final recipeIds = <String>{for (final e in meals) e.recipeId};
  final recipes = <String, Recipe>{
    for (final id in recipeIds)
      if (state.allRecipes[id] != null) id: state.allRecipes[id]!,
  };

  final dayRecipes = recipes.values.toList(growable: false);
  final ironRich = dayRecipes.any(
    (r) => r.nutritionTags.any((t) => t.toLowerCase().contains('iron')),
  );

  final ageMonths = state.baby == null
      ? 0
      : ageInMonths(state.baby!.dateOfBirth);

  return HomeDayView(
    meals: meals,
    recipes: recipes,
    mealCount: meals.length,
    ironRich: ironRich,
    isToday: isToday,
    guidance: GuidanceService.tipsFor(
      ageMonths: ageMonths,
      todaysRecipes: dayRecipes,
    ),
  );
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
