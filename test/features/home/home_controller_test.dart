import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/home/home_controller.dart';

class _MockAllergenService extends Mock implements AllergenService {}

class _MockMealPlanService extends Mock implements MealPlanService {}

class _MockRecipeService extends Mock implements RecipeService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

const _babyId = 'baby-1';

final _baby = Baby(
  id: _babyId,
  userId: 'user-1',
  name: 'Test Baby',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

const _recipe = Recipe(
  id: 'recipe-1',
  title: 'Pea Puree',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

AllergenLog _log(String allergenKey, {bool hadReaction = false, int n = 0}) =>
    AllergenLog(
      id: 'log-$allergenKey-$n',
      babyId: _babyId,
      allergenKey: allergenKey,
      hadReaction: hadReaction,
      logDate: DateTime(2026, 1, n + 1),
      createdAt: DateTime(2026, 1, n + 1),
    );

MealPlanEntry _entry(DateTime date, {String recipeId = 'recipe-1'}) =>
    MealPlanEntry(
      id: 'entry-$recipeId',
      babyId: _babyId,
      recipeId: recipeId,
      planDate: date,
    );

ProviderContainer _makeContainer({
  required _MockBabyProfileService babyProfile,
  required _MockAllergenService allergen,
  required _MockMealPlanService mealPlan,
  required _MockRecipeService recipe,
}) {
  final container = ProviderContainer(
    overrides: [
      babyProfileServiceProvider.overrideWithValue(babyProfile),
      allergenServiceProvider.overrideWithValue(allergen),
      mealPlanServiceProvider.overrideWithValue(mealPlan),
      recipeServiceProvider.overrideWithValue(recipe),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  tearDown(resetMocktailState);

  group('HomeController — no baby (empty state)', () {
    test('returns empty HomeState when getBaby returns null', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => null);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(
        () => mealPlan.getRolling7(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      final state = await container.read(
        homeControllerProvider(_babyId).future,
      );

      expect(state.baby, isNull);
      expect(state.allergenStatuses, isEmpty);
      expect(state.todaysMeals, isEmpty);
    });
  });

  group('HomeController — service failures', () {
    test('throws when allergen getLogs returns Failure', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(() => allergen.getLogs(_babyId)).thenAnswer(
        (_) async => const Result.failure(ServerException('logs fetch failed')),
      );
      when(
        () => mealPlan.getRolling7(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );

      await expectLater(
        container.read(homeControllerProvider(_babyId).future),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws when mealPlan getRolling7 returns Failure', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(() => mealPlan.getRolling7(_babyId)).thenAnswer(
        (_) async =>
            const Result.failure(ServerException('meal plan fetch failed')),
      );

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );

      await expectLater(
        container.read(homeControllerProvider(_babyId).future),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('HomeController — allergen status derivation', () {
    test('all allergens notStarted when no logs', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(
        () => mealPlan.getRolling7(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      final state = await container.read(
        homeControllerProvider(_babyId).future,
      );

      expect(
        state.allergenStatuses.values.every(
          (s) => s == AllergenStatus.notStarted,
        ),
        isTrue,
      );
    });

    test('single clean log → allergen inProgress', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => Result.success([_log('peanut')]));
      when(
        () => mealPlan.getRolling7(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      final state = await container.read(
        homeControllerProvider(_babyId).future,
      );

      expect(state.allergenStatuses['peanut'], AllergenStatus.inProgress);
    });

    test('reaction log → allergen flagged', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(() => allergen.getLogs(_babyId)).thenAnswer(
        (_) async => Result.success([_log('egg', hadReaction: true)]),
      );
      when(
        () => mealPlan.getRolling7(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      final state = await container.read(
        homeControllerProvider(_babyId).future,
      );

      expect(state.allergenStatuses['egg'], AllergenStatus.flagged);
    });
  });

  group('HomeController — log counts', () {
    test('reaction logs excluded from log count', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(() => allergen.getLogs(_babyId)).thenAnswer(
        (_) async => Result.success([
          _log('peanut'),
          _log('peanut', n: 1),
          _log('peanut', hadReaction: true, n: 2),
        ]),
      );
      when(
        () => mealPlan.getRolling7(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      final state = await container.read(
        homeControllerProvider(_babyId).future,
      );

      expect(state.allergenLogCounts['peanut'], 2);
    });
  });

  group('HomeController — meal plan and recipe hydration', () {
    test('today entry populates todaysMeals and hydrates recipe', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();
      final today = DateTime.now();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(
        () => mealPlan.getRolling7(_babyId),
      ).thenAnswer((_) async => Result.success([_entry(today)]));
      when(
        () => recipe.getRecipeById('recipe-1'),
      ).thenAnswer((_) async => const Result.success(_recipe));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      final state = await container.read(
        homeControllerProvider(_babyId).future,
      );

      expect(state.todaysMeals.length, 1);
      expect(state.todaysRecipes['recipe-1'], _recipe);
    });

    test(
      'future entry excluded from todaysMeals, hasAnyPlannedMeal true',
      () async {
        final babyProfile = _MockBabyProfileService();
        final allergen = _MockAllergenService();
        final mealPlan = _MockMealPlanService();
        final recipe = _MockRecipeService();
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        when(babyProfile.getBaby).thenAnswer((_) async => _baby);
        when(
          () => allergen.getLogs(_babyId),
        ).thenAnswer((_) async => const Result.success([]));
        when(
          () => mealPlan.getRolling7(_babyId),
        ).thenAnswer((_) async => Result.success([_entry(tomorrow)]));

        final container = _makeContainer(
          babyProfile: babyProfile,
          allergen: allergen,
          mealPlan: mealPlan,
          recipe: recipe,
        );
        final state = await container.read(
          homeControllerProvider(_babyId).future,
        );

        expect(state.todaysMeals, isEmpty);
        expect(state.hasAnyPlannedMeal, isTrue);
      },
    );

    test('failed recipe fetch is silently skipped (P3)', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();
      final today = DateTime.now();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(() => mealPlan.getRolling7(_babyId)).thenAnswer(
        (_) async => Result.success([
          _entry(today),
          _entry(today, recipeId: 'recipe-2'),
        ]),
      );
      when(
        () => recipe.getRecipeById('recipe-1'),
      ).thenAnswer((_) async => const Result.success(_recipe));
      when(() => recipe.getRecipeById('recipe-2')).thenAnswer(
        (_) async => const Result.failure(ServerException('not found')),
      );

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      final state = await container.read(
        homeControllerProvider(_babyId).future,
      );

      expect(state.todaysMeals.length, 2);
      expect(state.todaysRecipes.containsKey('recipe-1'), isTrue);
      expect(state.todaysRecipes.containsKey('recipe-2'), isFalse);
    });

    test('empty rolling window skips recipeService entirely', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(
        () => mealPlan.getRolling7(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      await container.read(homeControllerProvider(_babyId).future);

      verifyNever(() => recipe.getRecipeById(any<String>()));
    });
  });
}
