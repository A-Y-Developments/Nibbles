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
}) => Recipe(
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
        () => mockMealPlanRepo.assignRecipe(any(), any(), any(), any()),
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
        () => mockMealPlanRepo.assignRecipe(any(), any(), any(), any()),
      ).thenAnswer((_) async => Result.success(entry));

      await sut.assignRecipe(_babyId, 'r1', _weekStart, mealTime: mealTime);

      verify(
        () =>
            mockMealPlanRepo.assignRecipe(_babyId, 'r1', _weekStart, mealTime),
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
      when(() => mockMealPlanRepo.getWeekMeals(any(), any(), any())).thenAnswer(
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
            ingredients: [const Ingredient(name: 'Rice', quantity: '2 cups')],
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
      when(() => mockMealPlanRepo.getWeekMeals(any(), any(), any())).thenAnswer(
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
      when(() => mockMealPlanRepo.getWeekMeals(any(), any(), any())).thenAnswer(
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

  // ---------------------------------------------------------------------------
  // NIB-59: getRolling7
  // ---------------------------------------------------------------------------

  group('MealPlanService.getRolling7', () {
    test('passes (today, today+6) to repo.getEntriesInRange', () async {
      final today = DateTime(2026, 5, 30);
      final expectedEnd = today.add(const Duration(days: 6));
      when(
        () => mockMealPlanRepo.getEntriesInRange(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success([]));

      final result = await sut.getRolling7(_babyId, today: today);

      expect(result.isSuccess, isTrue);
      verify(
        () => mockMealPlanRepo.getEntriesInRange(_babyId, today, expectedEnd),
      ).called(1);
    });

    test('normalizes today to date-only (strips time)', () async {
      final raw = DateTime(2026, 5, 30, 14, 32, 11);
      final expectedStart = DateTime(2026, 5, 30);
      final expectedEnd = expectedStart.add(const Duration(days: 6));
      when(
        () => mockMealPlanRepo.getEntriesInRange(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success([]));

      await sut.getRolling7(_babyId, today: raw);

      verify(
        () => mockMealPlanRepo.getEntriesInRange(
          _babyId,
          expectedStart,
          expectedEnd,
        ),
      ).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // NIB-59: appendMealsToRange — APPEND, not replace.
  // ---------------------------------------------------------------------------

  group('MealPlanService.appendMealsToRange', () {
    test(
      'maps dayOffset to startDate+offset and calls repo.appendBulk',
      () async {
        final start = DateTime(2026, 5, 30);
        final end = start.add(const Duration(days: 6));
        when(() => mockMealPlanRepo.appendBulk(any())).thenAnswer(
          (_) async => const Result.success([]),
        );

        final result = await sut.appendMealsToRange(
          babyId: _babyId,
          startDate: start,
          endDate: end,
          assignments: const [
            RecipeAssignment(recipeId: 'r1', dayOffset: 0),
            RecipeAssignment(recipeId: 'r2', dayOffset: 3),
            RecipeAssignment(recipeId: 'r3', dayOffset: 6),
          ],
        );

        expect(result.isSuccess, isTrue);
        final captured = verify(
          () => mockMealPlanRepo.appendBulk(captureAny()),
        ).captured.single as List<MealPlanEntryInsert>;
        expect(captured, hasLength(3));
        expect(captured[0].recipeId, 'r1');
        expect(captured[0].planDate, start);
        expect(captured[1].recipeId, 'r2');
        expect(captured[1].planDate, start.add(const Duration(days: 3)));
        expect(captured[2].recipeId, 'r3');
        expect(captured[2].planDate, end);
        // Never uses upsert/clear before insert — pure APPEND.
        verifyNever(() => mockMealPlanRepo.deleteRange(any(), any(), any()));
        verifyNever(() => mockMealPlanRepo.clearWeek(any(), any(), any()));
      },
    );

    test(
      'rejects assignments with out-of-range dayOffset as Failure',
      () async {
        final start = DateTime(2026, 5, 30);
        final end = start.add(const Duration(days: 6));

        final result = await sut.appendMealsToRange(
          babyId: _babyId,
          startDate: start,
          endDate: end,
          assignments: const [RecipeAssignment(recipeId: 'r1', dayOffset: 7)],
        );

        expect(result.isFailure, isTrue);
        verifyNever(() => mockMealPlanRepo.appendBulk(any()));
      },
    );

    test('empty assignments short-circuits to Success([])', () async {
      final start = DateTime(2026, 5, 30);
      final end = start.add(const Duration(days: 6));

      final result = await sut.appendMealsToRange(
        babyId: _babyId,
        startDate: start,
        endDate: end,
        assignments: const [],
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
      verifyNever(() => mockMealPlanRepo.appendBulk(any()));
    });
  });

  // ---------------------------------------------------------------------------
  // NIB-59: clearRange
  // ---------------------------------------------------------------------------

  group('MealPlanService.clearRange', () {
    test('delegates to repo.deleteRange with date-only bounds', () async {
      final start = DateTime(2026, 5, 30, 9);
      final end = DateTime(2026, 6, 5, 23, 59);
      when(
        () => mockMealPlanRepo.deleteRange(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.clearRange(_babyId, start, end);

      expect(result.isSuccess, isTrue);
      verify(
        () => mockMealPlanRepo.deleteRange(
          _babyId,
          DateTime(2026, 5, 30),
          DateTime(2026, 6, 5),
        ),
      ).called(1);
    });
  });
}
