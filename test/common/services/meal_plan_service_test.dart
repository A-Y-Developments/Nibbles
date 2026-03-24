import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/meal_plan_repository.dart';
import 'package:nibbles/src/common/data/repositories/recipe_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';

class MockMealPlanRepository extends Mock implements MealPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

const _babyId = 'baby-001';
final _weekStart = DateTime(2026, 3, 23);
final _weekEnd = DateTime(2026, 3, 29); // weekStart + 6 days

MealPlanEntry _makeEntry({String id = 'e1', String recipeId = 'r1'}) =>
    MealPlanEntry(
      id: id,
      babyId: _babyId,
      recipeId: recipeId,
      planDate: _weekStart,
    );

Recipe _makeRecipe({
  String id = 'r1',
  List<Ingredient> ingredients = const [],
}) =>
    Recipe(
      id: id,
      title: 'Recipe $id',
      ageRange: '6m+',
      allergenTags: const [],
      ingredients: ingredients,
      steps: const ['Step 1'],
      howToServe: 'Serve warm.',
    );

void main() {
  late MockMealPlanRepository mockMealPlanRepo;
  late MockRecipeRepository mockRecipeRepo;
  late MealPlanService sut;

  setUpAll(() {
    registerFallbackValue(const TimeOfDay(hour: 0, minute: 0));
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(_makeEntry());
  });

  setUp(() {
    mockMealPlanRepo = MockMealPlanRepository();
    mockRecipeRepo = MockRecipeRepository();
    sut = MealPlanService(mockMealPlanRepo, mockRecipeRepo);
  });

  // ---------------------------------------------------------------------------
  // assignRecipe
  // ---------------------------------------------------------------------------

  group('MealPlanService.assignRecipe', () {
    test('delegates to repo with all positional args', () async {
      final entry = _makeEntry();
      when(
        () => mockMealPlanRepo.assignRecipe(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => Result.success(entry));

      final result = await sut.assignRecipe(_babyId, 'r1', _weekStart);

      expect(result.isSuccess, isTrue);
      verify(
        () => mockMealPlanRepo.assignRecipe(_babyId, 'r1', _weekStart, null),
      ).called(1);
    });

    test('passes mealTime when provided', () async {
      final entry = _makeEntry();
      const mealTime = TimeOfDay(hour: 12, minute: 0);
      when(
        () => mockMealPlanRepo.assignRecipe(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => Result.success(entry));

      await sut.assignRecipe(_babyId, 'r1', _weekStart, mealTime: mealTime);

      verify(
        () => mockMealPlanRepo.assignRecipe(
          _babyId,
          'r1',
          _weekStart,
          mealTime,
        ),
      ).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // clearWeek
  // ---------------------------------------------------------------------------

  group('MealPlanService.clearWeek', () {
    test('passes weekStart and weekStart+6days to repo', () async {
      when(
        () => mockMealPlanRepo.clearWeek(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.clearWeek(_babyId, _weekStart);

      expect(result.isSuccess, isTrue);
      verify(
        () => mockMealPlanRepo.clearWeek(_babyId, _weekStart, _weekEnd),
      ).called(1);
    });

    test('repo failure propagates', () async {
      when(() => mockMealPlanRepo.clearWeek(any(), any(), any())).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.clearWeek(_babyId, _weekStart);

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getWeekIngredientNames
  // ---------------------------------------------------------------------------

  group('MealPlanService.getWeekIngredientNames', () {
    test('deduplicates ingredient names across recipes', () async {
      when(
        () => mockMealPlanRepo.getWeekMeals(any(), any(), any()),
      ).thenAnswer(
        (_) async => Result.success([
          _makeEntry(),
          _makeEntry(id: 'e2', recipeId: 'r2'),
        ]),
      );
      when(() => mockRecipeRepo.getRecipeById('r1')).thenAnswer(
        (_) async => Result.success(
          _makeRecipe(
            ingredients: [
              const Ingredient(name: 'Olive Oil', quantity: '1 tbsp'),
              const Ingredient(name: 'Rice', quantity: '1 cup'),
            ],
          ),
        ),
      );
      when(() => mockRecipeRepo.getRecipeById('r2')).thenAnswer(
        (_) async => Result.success(
          _makeRecipe(
            id: 'r2',
            ingredients: [
              const Ingredient(name: 'Rice', quantity: '2 cups'),
            ],
          ),
        ),
      );

      final result = await sut.getWeekIngredientNames(_babyId, _weekStart);

      expect(result.isSuccess, isTrue);
      final names = result.dataOrNull!;
      expect(names, containsAll(['Olive Oil', 'Rice']));
      // Deduplicated: Rice appears only once
      expect(names.where((n) => n == 'Rice'), hasLength(1));
    });

    test('skips failed recipe fetch (best-effort)', () async {
      when(
        () => mockMealPlanRepo.getWeekMeals(any(), any(), any()),
      ).thenAnswer(
        (_) async => Result.success([
          _makeEntry(),
          _makeEntry(id: 'e2', recipeId: 'r2'),
        ]),
      );
      when(() => mockRecipeRepo.getRecipeById('r1')).thenAnswer(
        (_) async => const Result.failure(ServerException('not found')),
      );
      when(() => mockRecipeRepo.getRecipeById('r2')).thenAnswer(
        (_) async => Result.success(
          _makeRecipe(
            id: 'r2',
            ingredients: [
              const Ingredient(name: 'Bread', quantity: '2 slices'),
            ],
          ),
        ),
      );

      final result = await sut.getWeekIngredientNames(_babyId, _weekStart);

      // Not a failure — skips r1 and returns r2's ingredients
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(['Bread']));
    });

    test('getWeekMeals failure → propagates, no recipe fetches', () async {
      when(
        () => mockMealPlanRepo.getWeekMeals(any(), any(), any()),
      ).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.getWeekIngredientNames(_babyId, _weekStart);

      expect(result.isFailure, isTrue);
      verifyNever(() => mockRecipeRepo.getRecipeById(any()));
    });

    test('empty week → returns empty list', () async {
      when(
        () => mockMealPlanRepo.getWeekMeals(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success([]));

      final result = await sut.getWeekIngredientNames(_babyId, _weekStart);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });
  });
}
