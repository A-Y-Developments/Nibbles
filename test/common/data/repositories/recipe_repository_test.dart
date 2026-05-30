// Unit tests for [RecipeRepositoryImpl].
//
// Focus: the private `_recipeFromRow` mapping behaviour, exercised through
// the public `getRecipeById` cache-miss path. NIB-129 added two
// recipe-row fields (`nutrition_tags`, `category`); these tests pin the
// row-shape contract from the DB schema → `Recipe` entity:
//   * `nutrition_tags: [...]`  + `category: 'X'`  → entity carries both
//   * `nutrition_tags: null`                     → entity has empty list
//   * `category: null`                           → entity has null category
//   * Round-trip via `toJson` + `Recipe.fromJson` (the cache path used by
//     `getRecipeById` when the Hive cache is populated) preserves the same
//     null-safety semantics.
//
// We mock the entire Supabase chain because `_recipeFromRow` is private;
// the cleanest seam is the injected `SupabaseClient` + `HiveService`.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/recipe_repository.dart';
import 'package:nibbles/src/common/data/sources/local/hive_service.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockHiveService extends Mock implements HiveService {}

class _MockRecipesBox extends Mock implements Box<String> {}

class _MockQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// Builds a row Map satisfying every key `_recipeFromRow` reads
/// unconditionally.
Map<String, dynamic> _row({
  String id = 'r1',
  String title = 'Pea Puree',
  String ageRange = '6m+',
  List<dynamic> allergenTags = const <dynamic>[],
  List<dynamic> ingredients = const <dynamic>[
    {'name': 'Pea', 'quantity': '1 cup'},
  ],
  List<dynamic> steps = const <dynamic>['Step.'],
  String servingGuidance = 'Serve.',
  String? notes,
  String? thumbnailUrl,
  List<dynamic>? nutritionTags,
  String? category,
}) => <String, dynamic>{
  'id': id,
  'title': title,
  'age_range': ageRange,
  'allergen_tags': allergenTags,
  'ingredients': ingredients,
  'steps': steps,
  'serving_guidance': servingGuidance,
  'notes': notes,
  'thumbnail_url': thumbnailUrl,
  'nutrition_tags': nutritionTags,
  'category': category,
};

void main() {
  // ---------------------------------------------------------------------------
  // Direct entity tests — Recipe.fromJson is the deserialiser used by the
  // read-through cache path (`getAllRecipes` / `getRecipeById` cached). The
  // same NIB-129 defaulting rules apply: missing `nutritionTags` → empty list,
  // missing `category` → null. These complement the row-mapper tests below.
  // ---------------------------------------------------------------------------
  group('Recipe.fromJson — NIB-129 entity null-safety', () {
    test('missing nutritionTags → entity has empty list', () {
      final json = <String, dynamic>{
        'id': 'r1',
        'title': 'Pea Puree',
        'ageRange': '6m+',
        'allergenTags': <String>[],
        'ingredients': <Map<String, dynamic>>[],
        'steps': <String>[],
        'howToServe': 'Serve.',
        // 'nutritionTags' omitted on purpose.
      };
      final recipe = Recipe.fromJson(json);
      expect(recipe.nutritionTags, <String>[]);
    });

    test('missing category → entity has null category', () {
      final json = <String, dynamic>{
        'id': 'r1',
        'title': 'Pea Puree',
        'ageRange': '6m+',
        'allergenTags': <String>[],
        'ingredients': <Map<String, dynamic>>[],
        'steps': <String>[],
        'howToServe': 'Serve.',
        // 'category' omitted on purpose.
      };
      final recipe = Recipe.fromJson(json);
      expect(recipe.category, isNull);
    });

    test(
      'roundtrip Recipe → toJson → fromJson preserves nutritionTags + category',
      () {
        const original = Recipe(
          id: 'r1',
          title: 'Pea Puree',
          ageRange: '6m+',
          allergenTags: [],
          ingredients: [],
          steps: [],
          howToServe: 'Serve.',
          nutritionTags: ['Iron-rich', 'Quick'],
          category: 'Purees',
        );
        final roundtripped = Recipe.fromJson(original.toJson());
        expect(roundtripped.nutritionTags, ['Iron-rich', 'Quick']);
        expect(roundtripped.category, 'Purees');
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Row-mapper tests — drive `_recipeFromRow` indirectly through the public
  // `getRecipeById` cache-miss branch. The Hive cache is stubbed to return
  // `null` so the repo falls through to Supabase; we then stub the entire
  // chain to return a canned row Map. The resulting Recipe entity is the
  // direct output of `_recipeFromRow`.
  //
  // Each test creates its OWN mocks (no shared setUp) — mocktail's
  // interaction recorder gets confused when a class implementing `Future`
  // (our `_FakeSingleTerminal`) flows through a shared mock across tests
  // and leaves the recorder in a stub-response state.
  // ---------------------------------------------------------------------------
  group('RecipeRepositoryImpl.getRecipeById — _recipeFromRow', () {
    tearDown(resetMocktailState);

    Future<Recipe?> runRowMap(Map<String, dynamic> row) async {
      final mockSupabase = _MockSupabaseClient();
      final mockHive = _MockHiveService();
      final mockRecipesBox = _MockRecipesBox();
      final mockQueryBuilder = _MockQueryBuilder();

      when(() => mockHive.recipesBox).thenReturn(mockRecipesBox);
      when(() => mockRecipesBox.get(any<dynamic>())).thenReturn(null);
      // SupabaseQueryBuilder extends PostgrestBuilder which implements Future,
      // so mocktail rejects `thenReturn` for SupabaseQueryBuilder /
      // PostgrestFilterBuilder values — `thenAnswer` is the way around.
      when(
        () => mockSupabase.from('recipes'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(mockQueryBuilder.select).thenAnswer((_) => _FakeFilterChain(row));

      final sut = RecipeRepositoryImpl(
        supabaseClient: mockSupabase,
        hiveService: mockHive,
      );
      final result = await sut.getRecipeById(row['id'] as String);
      expect(result.isSuccess, isTrue);
      return result.dataOrNull;
    }

    test(
      'row with nutrition_tags + category → entity carries both values',
      () async {
        final recipe = await runRowMap(
          _row(
            id: 'r-1',
            nutritionTags: ['iron-rich', 'quick'],
            category: 'Purees',
          ),
        );
        expect(recipe!.id, 'r-1');
        expect(recipe.nutritionTags, ['iron-rich', 'quick']);
        expect(recipe.category, 'Purees');
      },
    );

    test('row with nutrition_tags: null → entity has empty list', () async {
      final recipe = await runRowMap(_row(category: 'Purees'));
      expect(recipe!.nutritionTags, <String>[]);
    });

    test('row with category: null → entity has null category', () async {
      final recipe = await runRowMap(_row(nutritionTags: const []));
      expect(recipe!.category, isNull);
    });

    test(
      'both nutrition_tags and category null → entity has empty list + null',
      () async {
        final recipe = await runRowMap(_row());
        expect(recipe!.nutritionTags, <String>[]);
        expect(recipe.category, isNull);
      },
    );
  });
}

/// Fake for `.select().eq('id', id).single()` — only `.eq` and `.single`.
///
/// Implements only `.eq(...)` and `.single()` — the two methods the repo
/// chains. We avoid mocktail's `Mock` base because mocktail's interaction
/// recorder gets confused when the same fake is used across multiple tests
/// (the captured invocations bleed across setUp boundaries). A plain Fake
/// works because the SDK methods are forwarded through `noSuchMethod` to
/// `Object`, not through mocktail's recorder.
class _FakeFilterChain implements PostgrestFilterBuilder<PostgrestList> {
  _FakeFilterChain(this._row);

  final Map<String, dynamic> _row;

  // `.eq('id', value)` returns the same chain — keep going.
  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object value) => this;

  // `.single()` is the terminal. The repo awaits it as a Map.
  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() {
    return _FakeSingleTerminal(_row);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Defensive: any other Postgrest call is unused by the repo. Throwing
    // surfaces an unexpected interaction rather than a silent null return.
    throw UnimplementedError(
      'Unexpected call on _FakeFilterChain: ${invocation.memberName}',
    );
  }
}

/// Terminal Future for `.single()`. Implements `Future<Map<String,dynamic>>`
/// by delegating to an inner Future created in the constructor.
class _FakeSingleTerminal
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  _FakeSingleTerminal(this._row);

  final Map<String, dynamic> _row;

  Future<Map<String, dynamic>> get _future =>
      Future<Map<String, dynamic>>.value(_row);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(Map<String, dynamic> value) onValue, {
    Function? onError,
  }) => _future.then(onValue, onError: onError);

  @override
  Future<Map<String, dynamic>> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) => _future.catchError(onError, test: test);

  @override
  Future<Map<String, dynamic>> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<Map<String, dynamic>> timeout(
    Duration timeLimit, {
    FutureOr<Map<String, dynamic>> Function()? onTimeout,
  }) => _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Stream<Map<String, dynamic>> asStream() => _future.asStream();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Unexpected call on _FakeSingleTerminal: ${invocation.memberName}',
    );
  }
}
