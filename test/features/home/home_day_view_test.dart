import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/home/home_controller.dart';
import 'package:nibbles/src/features/home/home_day_view.dart';

class _MockAllergenService extends Mock implements AllergenService {}

class _MockMealPlanService extends Mock implements MealPlanService {}

class _MockRecipeService extends Mock implements RecipeService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

const _babyId = 'baby-1';

Baby _babyAgedDays(int days) => Baby(
  id: _babyId,
  userId: 'user-1',
  name: 'Test Baby',
  dateOfBirth: DateTime.now().subtract(Duration(days: days)),
  gender: Gender.female,
  onboardingCompleted: true,
);

/// Boots the homeDayView provider for a baby (or none) and returns the derived
/// view. No meals are planned, so the recipe service is never hit.
Future<HomeDayView> _dayViewFor(Baby? baby) async {
  final babyProfile = _MockBabyProfileService();
  final allergen = _MockAllergenService();
  final mealPlan = _MockMealPlanService();
  final recipe = _MockRecipeService();

  when(babyProfile.getBaby).thenAnswer((_) async => baby);
  when(
    () => allergen.getLogs(_babyId),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => allergen.getProgramState(any()),
  ).thenAnswer((_) async => const Result.failure(UnknownException()));
  when(
    () => allergen.getCurrentAllergen(any()),
  ).thenAnswer((_) async => const Result.failure(UnknownException()));
  when(
    () => mealPlan.getAllEntries(_babyId),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => mealPlan.getActivePlan(any()),
  ).thenAnswer((_) async => const Result<MealPlan?>.success(null));

  final container = ProviderContainer(
    overrides: [
      babyProfileServiceProvider.overrideWithValue(babyProfile),
      allergenServiceProvider.overrideWithValue(allergen),
      mealPlanServiceProvider.overrideWithValue(mealPlan),
      recipeServiceProvider.overrideWithValue(recipe),
    ],
  );
  addTearDown(container.dispose);

  // Day view watches the controller; await it so the baby is loaded before the
  // slice is read.
  await container.read(homeControllerProvider(_babyId).future);
  return container.read(homeDayViewProvider(_babyId));
}

void main() {
  test('meals ring target tracks the age ladder', () async {
    // ~3mo → milk-only (Stage 0) → 1 meal/day.
    expect((await _dayViewFor(_babyAgedDays(90))).mealTarget, 1);
    // ~7mo → Stage 3 → 2 meals/day.
    expect((await _dayViewFor(_babyAgedDays(210))).mealTarget, 2);
    // ~10mo → Stage 4 → 3 meals/day.
    expect((await _dayViewFor(_babyAgedDays(300))).mealTarget, 3);
  });

  test('falls back to the default target when there is no baby', () async {
    expect((await _dayViewFor(null)).mealTarget, kDailyMealTarget);
  });
}
