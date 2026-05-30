import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

/// NIB-86: Redesigned Home dashboard controller.
///
/// Parallel-fetches:
///  1. The current baby profile (NIB-65 header + greeting).
///  2. Per-allergen derived statuses (NIB-126).
///  3. Rolling-7 meal plan entries (NIB-59), filtered to today.
///
/// A missing baby is NOT an error — the screen renders the full empty-state
/// placeholder. Allergen or meal-plan fetch failures throw via the existing
/// pattern and surface as `AsyncValue.error`.
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeState> build(String babyId) async {
    final babyFut = ref.read(babyProfileServiceProvider).getBaby();
    final statusesFut = ref
        .read(allergenServiceProvider)
        .getAllergenStatuses(babyId);
    final mealsFut = ref.read(mealPlanServiceProvider).getRolling7(babyId);

    final baby = await babyFut;
    final statusesResult = await statusesFut;
    final mealsResult = await mealsFut;

    if (baby == null) {
      // Empty-state path: no baby yet — surface a successful, empty state so
      // the screen can render the empty-state placeholder rather than an error.
      return const HomeState();
    }

    if (statusesResult.isFailure) throw statusesResult.errorOrNull!;
    if (mealsResult.isFailure) throw mealsResult.errorOrNull!;

    final statuses =
        statusesResult.dataOrNull ?? const <String, AllergenStatus>{};
    final rolling = mealsResult.dataOrNull ?? const <MealPlanEntry>[];

    final today = DateTime.now();
    final todaysMeals = rolling
        .where((e) => _isSameDay(e.planDate, today))
        .toList(growable: false);

    return HomeState(
      baby: baby,
      allergenStatuses: statuses,
      todaysMeals: todaysMeals,
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
