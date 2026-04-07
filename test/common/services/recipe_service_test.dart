import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/allergen_repository.dart';
import 'package:nibbles/src/common/data/repositories/recipe_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockAllergenRepository extends Mock implements AllergenRepository {}

const _babyId = 'baby-001';
final _now = DateTime(2026, 3, 24);

AllergenLog _makeLog({
  String allergenKey = 'peanut',
  bool hadReaction = false,
}) => AllergenLog(
  id: 'log-1',
  babyId: _babyId,
  allergenKey: allergenKey,
  emojiTaste: EmojiTaste.love,
  hadReaction: hadReaction,
  logDate: _now,
  createdAt: _now,
);

Recipe _makeRecipe({String id = 'r1', List<String> allergenTags = const []}) =>
    Recipe(
      id: id,
      title: 'Test Recipe $id',
      ageRange: '6m+',
      allergenTags: allergenTags,
      ingredients: const [],
      steps: const ['Step 1'],
      howToServe: 'Serve warm.',
    );

void main() {
  late MockRecipeRepository mockRecipeRepo;
  late MockAllergenRepository mockAllergenRepo;
  late RecipeService sut;

  setUpAll(() {
    registerFallbackValue(_makeLog());
    registerFallbackValue(_now);
  });

  setUp(() {
    mockRecipeRepo = MockRecipeRepository();
    mockAllergenRepo = MockAllergenRepository();
    sut = RecipeService(mockRecipeRepo, mockAllergenRepo);
  });

  // ---------------------------------------------------------------------------
  // getAllRecipes
  // ---------------------------------------------------------------------------

  group('RecipeService.getAllRecipes', () {
    test(
      'no flagged allergens → returns all recipes in original order',
      () async {
        when(
          () => mockAllergenRepo.getLogs(_babyId),
        ).thenAnswer((_) async => const Result.success([]));
        when(() => mockRecipeRepo.getAllRecipes()).thenAnswer(
          (_) async => Result.success([
            _makeRecipe(allergenTags: ['peanut']),
            _makeRecipe(id: 'r2', allergenTags: ['egg']),
          ]),
        );

        final result = await sut.getAllRecipes(_babyId);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, hasLength(2));
      },
    );

    test('flagged allergen → recipe sorted to end, not removed', () async {
      when(
        () => mockAllergenRepo.getLogs(_babyId),
      ).thenAnswer((_) async => Result.success([_makeLog(hadReaction: true)]));
      when(() => mockRecipeRepo.getAllRecipes()).thenAnswer(
        (_) async => Result.success([
          _makeRecipe(allergenTags: ['peanut']),
          _makeRecipe(id: 'r2', allergenTags: ['egg']),
        ]),
      );

      final result = await sut.getAllRecipes(_babyId);

      expect(result.isSuccess, isTrue);
      final recipes = result.dataOrNull!;
      expect(recipes, hasLength(2));
      // Safe recipe (egg) first, unsafe (peanut) last.
      expect(recipes.first.id, 'r2');
      expect(recipes.last.id, 'r1');
    });

    test('recipe with no allergen tags → never moved to end', () async {
      when(
        () => mockAllergenRepo.getLogs(_babyId),
      ).thenAnswer((_) async => Result.success([_makeLog(hadReaction: true)]));
      when(
        () => mockRecipeRepo.getAllRecipes(),
      ).thenAnswer((_) async => Result.success([_makeRecipe()]));

      final result = await sut.getAllRecipes(_babyId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, hasLength(1));
    });

    test(
      'recipe with non-flagged allergen tag → remains in safe group',
      () async {
        when(() => mockAllergenRepo.getLogs(_babyId)).thenAnswer(
          (_) async => Result.success([_makeLog(hadReaction: true)]),
        );
        when(() => mockRecipeRepo.getAllRecipes()).thenAnswer(
          (_) async => Result.success([
            _makeRecipe(allergenTags: ['egg']),
          ]),
        );

        final result = await sut.getAllRecipes(_babyId);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, hasLength(1));
      },
    );

    test(
      'allergenRepo failure → propagates, getAllRecipes never called',
      () async {
        when(() => mockAllergenRepo.getLogs(_babyId)).thenAnswer(
          (_) async => const Result.failure(ServerException('DB error')),
        );

        final result = await sut.getAllRecipes(_babyId);

        expect(result.isFailure, isTrue);
        verifyNever(() => mockRecipeRepo.getAllRecipes());
      },
    );

    test('recipeRepo failure → propagates', () async {
      when(
        () => mockAllergenRepo.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(() => mockRecipeRepo.getAllRecipes()).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.getAllRecipes(_babyId);

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getRecommendationsForAllergen
  // ---------------------------------------------------------------------------

  group('RecipeService.getRecommendationsForAllergen', () {
    test('target allergen not flagged → returns recipes from repo', () async {
      when(
        () => mockAllergenRepo.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));
      when(() => mockRecipeRepo.getRecipesByAllergen('egg')).thenAnswer(
        (_) async => Result.success([
          _makeRecipe(allergenTags: ['egg']),
        ]),
      );

      final result = await sut.getRecommendationsForAllergen('egg', _babyId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, hasLength(1));
    });

    test('recipe with OTHER flagged tag → sorted to end', () async {
      when(
        () => mockAllergenRepo.getLogs(_babyId),
      ).thenAnswer((_) async => Result.success([_makeLog(hadReaction: true)]));
      when(() => mockRecipeRepo.getRecipesByAllergen('egg')).thenAnswer(
        (_) async => Result.success([
          _makeRecipe(allergenTags: ['egg', 'peanut']),
          _makeRecipe(id: 'r2', allergenTags: ['egg']),
        ]),
      );

      final result = await sut.getRecommendationsForAllergen('egg', _babyId);

      expect(result.isSuccess, isTrue);
      final recipes = result.dataOrNull!;
      expect(recipes, hasLength(2));
      // Safe recipe first, flagged one last.
      expect(recipes.first.id, 'r2');
      expect(recipes.last.id, 'r1');
    });

    test('allergenRepo failure → propagates', () async {
      when(() => mockAllergenRepo.getLogs(_babyId)).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.getRecommendationsForAllergen('egg', _babyId);

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getFlaggedAllergenKeys
  // ---------------------------------------------------------------------------

  group('RecipeService.getFlaggedAllergenKeys', () {
    test('returns flagged allergen keys', () async {
      when(() => mockAllergenRepo.getLogs(_babyId)).thenAnswer(
        (_) async => Result.success([
          _makeLog(hadReaction: true),
          _makeLog(allergenKey: 'egg'),
          _makeLog(allergenKey: 'dairy', hadReaction: true),
        ]),
      );

      final result = await sut.getFlaggedAllergenKeys(_babyId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, {'peanut', 'dairy'});
    });

    test('no reactions → empty set', () async {
      when(
        () => mockAllergenRepo.getLogs(_babyId),
      ).thenAnswer((_) async => const Result.success([]));

      final result = await sut.getFlaggedAllergenKeys(_babyId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getRecipeById
  // ---------------------------------------------------------------------------

  group('RecipeService.getRecipeById', () {
    test('delegates to recipeRepo and returns result', () async {
      final recipe = _makeRecipe(id: 'r42');
      when(
        () => mockRecipeRepo.getRecipeById('r42'),
      ).thenAnswer((_) async => Result.success(recipe));

      final result = await sut.getRecipeById('r42');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, recipe);
      verify(() => mockRecipeRepo.getRecipeById('r42')).called(1);
    });

    test('propagates failure from repo', () async {
      when(() => mockRecipeRepo.getRecipeById(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('not found')),
      );

      final result = await sut.getRecipeById('r-missing');

      expect(result.isFailure, isTrue);
    });
  });
}
