import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';

Recipe _recipe(
  String id,
  String title, {
  List<String> nutritionTags = const [],
}) => Recipe(
  id: id,
  title: title,
  ageRange: '6m+',
  allergenTags: const [],
  ingredients: const [],
  steps: const [],
  howToServe: 'Serve.',
  nutritionTags: nutritionTags,
);

void main() {
  group(
    'RecipeLibraryState.filteredRecipes — NIB-196 word-boundary search',
    () {
      final eggYolk = _recipe('r1', 'Egg Yolk Puree');
      final scrambledEggs = _recipe('r2', 'Soft Scrambled Eggs');
      final tofuVeggie = _recipe('r3', 'Tofu Veggie Stir-Fry Puree');
      final pastaVeggies = _recipe('r4', 'Pasta with Tomato and Veggies');

      RecipeLibraryState stateWith(String query) => RecipeLibraryState(
        recipesByCategory: {
          'all': [eggYolk, scrambledEggs, tofuVeggie, pastaVeggies],
        },
        searchQuery: query,
      );

      test('"egg" matches egg recipes but NOT "Veggie"/"Veggies"', () {
        final titles = stateWith(
          'egg',
        ).filteredRecipes.map((r) => r.title).toList();

        // Word-boundary match: "Eggs" (word starting with egg) is included.
        expect(titles, containsAll(['Egg Yolk Puree', 'Soft Scrambled Eggs']));
        // The false positives the substring match used to return are excluded.
        expect(titles, isNot(contains('Tofu Veggie Stir-Fry Puree')));
        expect(titles, isNot(contains('Pasta with Tomato and Veggies')));
      });

      test('empty / whitespace query returns no results', () {
        expect(stateWith('').filteredRecipes, isEmpty);
        expect(stateWith('   ').filteredRecipes, isEmpty);
      });

      test('multi-word query still matches via the title', () {
        final titles = stateWith(
          'egg yolk',
        ).filteredRecipes.map((r) => r.title).toList();
        expect(titles, ['Egg Yolk Puree']);
      });

      test('matches a nutrition tag on a word boundary', () {
        final beef = _recipe('r5', 'Beef Mash', nutritionTags: ['Iron rich']);
        final state = RecipeLibraryState(
          recipesByCategory: {
            'all': [beef, tofuVeggie],
          },
          searchQuery: 'iron',
        );
        expect(state.filteredRecipes.map((r) => r.title), ['Beef Mash']);
      });
    },
  );
}
