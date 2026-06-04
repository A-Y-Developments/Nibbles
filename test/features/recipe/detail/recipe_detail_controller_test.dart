// Unit tests for RecipeDetailController.build() error degradation:
//   * a SECONDARY allergen program/logs read failure must NOT collapse the
//     screen — the recipe still renders with empty allergen data (P3);
//   * the recipe read itself is essential — its failure still throws.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_controller.dart';

class _MockRecipeService extends Mock implements RecipeService {}

class _MockAllergenService extends Mock implements AllergenService {}

const _babyId = 'baby-1';
const _recipe = Recipe(
  id: 'r1',
  title: 'Plain Carrot',
  ageRange: '6+ months',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

void main() {
  late _MockRecipeService recipeSvc;
  late _MockAllergenService allergenSvc;

  setUp(() {
    recipeSvc = _MockRecipeService();
    allergenSvc = _MockAllergenService();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        recipeServiceProvider.overrideWithValue(recipeSvc),
        allergenServiceProvider.overrideWithValue(allergenSvc),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('allergen program/logs read failure still renders the recipe', () async {
    when(
      () => recipeSvc.getRecipeById(any()),
    ).thenAnswer((_) async => const Result.success(_recipe));
    when(
      () => allergenSvc.getProgramState(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));
    when(
      () => allergenSvc.getLogs(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));

    final state = await container().read(
      recipeDetailControllerProvider(_babyId, 'r1').future,
    );

    expect(state.recipe.id, 'r1');
    expect(state.currentAllergenKey, '');
    expect(state.allergenStatuses, isEmpty);
  });

  test('recipe read failure still throws (recipe is essential)', () async {
    when(
      () => recipeSvc.getRecipeById(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));
    when(
      () => allergenSvc.getProgramState(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));
    when(
      () => allergenSvc.getLogs(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));

    await expectLater(
      container().read(recipeDetailControllerProvider(_babyId, 'r1').future),
      throwsA(isA<NetworkException>()),
    );
  });
}
