import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
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

const _milk = Allergen(
  key: 'milk',
  name: 'Milk',
  sequenceOrder: 1,
  emoji: '🥛',
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

AllergenProgramState _programState({
  required String selected,
  required String current,
}) => AllergenProgramState(
  id: 'ps-1',
  babyId: _babyId,
  currentAllergenKey: current,
  currentSequenceOrder: 1,
  status: AllergenProgramStatus.inProgress,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  selectedAllergenKey: selected,
);

MealPlanEntry _entry(DateTime date, {String recipeId = 'recipe-1'}) =>
    MealPlanEntry(
      id: 'entry-$recipeId-${date.day}',
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
  // Defaults so unrelated derivations don't interfere; individual tests
  // override before reading the provider.
  when(
    () => allergen.getProgramState(any()),
  ).thenAnswer((_) async => const Result.failure(UnknownException()));
  when(
    () => allergen.getCurrentAllergen(any()),
  ).thenAnswer((_) async => const Result.failure(UnknownException()));
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
        () => mealPlan.getAllEntries(_babyId),
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
      expect(state.allMeals, isEmpty);
      expect(state.mealPrepSetUp, isFalse);
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
        () => mealPlan.getAllEntries(_babyId),
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

    test('throws when mealPlan getAllEntries returns Failure', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(() => mealPlan.getAllEntries(_babyId)).thenAnswer(
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
        () => mealPlan.getAllEntries(_babyId),
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

    test('reaction log → allergen flagged and counts exclude it', () async {
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
        () => mealPlan.getAllEntries(_babyId),
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

      expect(state.allergenStatuses['peanut'], AllergenStatus.flagged);
      expect(state.allergenLogCounts['peanut'], 2);
    });
  });

  group('HomeController — current allergen wiring', () {
    test('populates current allergen key/status/count', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => Result.success([_log('milk')]));
      when(
        () => mealPlan.getAllEntries(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      // Registered after _makeContainer's any()-default so this specific stub
      // wins (mocktail resolves to the last matching stub).
      when(
        () => allergen.getCurrentAllergen(_babyId),
      ).thenAnswer((_) async => const Result.success(_milk));

      final state = await container.read(
        homeControllerProvider(_babyId).future,
      );

      expect(state.currentAllergenKey, 'milk');
      expect(state.currentAllergenStatus, AllergenStatus.inProgress);
      expect(state.currentAllergenReactionFlags, [false]);
    });

    test('selected (just-started + flagged) allergen wins over a completed '
        'one — Home matches the tracker, not the legacy pointer', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      // 'egg' finished safe (3 clean); 'milk' was just started via Start
      // Introduce, then reacted → flagged (no allergen is inProgress).
      when(() => allergen.getLogs(_babyId)).thenAnswer(
        (_) async => Result.success([
          _log('egg'),
          _log('egg', n: 1),
          _log('egg', n: 2),
          _log('milk', hadReaction: true, n: 3),
        ]),
      );
      when(
        () => mealPlan.getAllEntries(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final container = _makeContainer(
        babyProfile: babyProfile,
        allergen: allergen,
        mealPlan: mealPlan,
        recipe: recipe,
      );
      // selected_allergen_key → milk (the started one); the legacy
      // current_allergen_key still points at the completed egg.
      when(() => allergen.getProgramState(_babyId)).thenAnswer(
        (_) async =>
            Result.success(_programState(selected: 'milk', current: 'egg')),
      );

      final state = await container.read(
        homeControllerProvider(_babyId).future,
      );

      expect(state.currentAllergenKey, 'milk');
      expect(state.currentAllergenStatus, AllergenStatus.flagged);
      expect(state.currentAllergenReactionFlags, [true]);
    });
  });

  group('HomeController — meals, recipes, plannedDates', () {
    test(
      'all entries populate allMeals, hydrate recipes, sort dates',
      () async {
        final babyProfile = _MockBabyProfileService();
        final allergen = _MockAllergenService();
        final mealPlan = _MockMealPlanService();
        final recipe = _MockRecipeService();

        final d1 = DateTime(2026, 3, 10);
        final gap = DateTime(2026, 3, 11);
        final d2 = DateTime(2026, 3, 12);

        when(babyProfile.getBaby).thenAnswer((_) async => _baby);
        when(
          () => allergen.getLogs(_babyId),
        ).thenAnswer((_) async => const Result.success([]));
        when(
          () => mealPlan.getAllEntries(_babyId),
        ).thenAnswer((_) async => Result.success([_entry(d2), _entry(d1)]));
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

        expect(state.allMeals.length, 2);
        expect(state.allRecipes['recipe-1'], _recipe);
        expect(state.plannedDates, [d1, gap, d2]);
        expect(state.mealPrepSetUp, isTrue);
      },
    );

    test('failed recipe fetch is silently skipped (P3)', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();
      final day = DateTime(2026, 3, 10);

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(() => mealPlan.getAllEntries(_babyId)).thenAnswer(
        (_) async =>
            Result.success([_entry(day), _entry(day, recipeId: 'recipe-2')]),
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

      expect(state.allMeals.length, 2);
      expect(state.allRecipes.containsKey('recipe-1'), isTrue);
      expect(state.allRecipes.containsKey('recipe-2'), isFalse);
    });

    test('empty entries skip recipeService entirely', () async {
      final babyProfile = _MockBabyProfileService();
      final allergen = _MockAllergenService();
      final mealPlan = _MockMealPlanService();
      final recipe = _MockRecipeService();

      when(babyProfile.getBaby).thenAnswer((_) async => _baby);
      when(
        () => allergen.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(
        () => mealPlan.getAllEntries(_babyId),
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
