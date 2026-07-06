import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/app/constants/guidance_tips.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/guidance_service.dart';

Recipe _recipe({
  String id = 'r',
  List<String> nutritionTags = const [],
  String? category,
  List<String> ingredientNames = const [],
}) => Recipe(
  id: id,
  title: 'Recipe $id',
  ageRange: '6m+',
  allergenTags: const [],
  ingredients: ingredientNames
      .map((n) => Ingredient(name: n, quantity: '1'))
      .toList(),
  steps: const ['step'],
  howToServe: 'serve',
  nutritionTags: nutritionTags,
  category: category,
);

void main() {
  List<String> ids(int ageMonths, List<Recipe> recipes) => GuidanceService
      .tipsFor(ageMonths: ageMonths, todaysRecipes: recipes)
      .map((t) => t.id)
      .toList();

  group('GuidanceService.tipsFor — cardinality', () {
    test('returns at most 3 tips', () {
      final tips = GuidanceService.tipsFor(
        ageMonths: 9,
        todaysRecipes: const [],
      );
      expect(tips.length, lessThanOrEqualTo(3));
    });
  });

  group('GuidanceService.tipsFor — age predicates', () {
    test('milk priority shown under 12 months', () {
      expect(ids(8, const []), contains('milk_priority'));
    });

    test('milk priority hidden at 12 months and over', () {
      expect(ids(12, const []), isNot(contains('milk_priority')));
    });

    test('offer water shown from 6 months', () {
      expect(ids(6, const []), contains('offer_water'));
    });

    test('offer water hidden under 6 months', () {
      expect(ids(5, const []), isNot(contains('offer_water')));
    });

    test('finger foods gated at 8 months', () {
      // Fruit + iron present so the two meal-contextual tips don't fire and
      // milk_priority is gone at 12mo, letting the age tip surface within the
      // 3-tip cap.
      final withMeal = [
        _recipe(nutritionTags: const ['iron'], ingredientNames: const ['pear']),
      ];
      expect(ids(12, withMeal), contains('try_finger_foods'));
      expect(ids(7, withMeal), isNot(contains('try_finger_foods')));
    });
  });

  group('GuidanceService.tipsFor — meal predicates', () {
    test('no-fruit tip shown when meals exist but none is fruit', () {
      final tips = ids(9, [
        _recipe(ingredientNames: const ['chicken', 'carrot']),
      ]);
      expect(tips, contains('no_fruit_today'));
    });

    test('no-fruit tip hidden when a fruit is present', () {
      final tips = ids(9, [
        _recipe(ingredientNames: const ['banana', 'oats']),
      ]);
      expect(tips, isNot(contains('no_fruit_today')));
    });

    test('no-fruit tip hidden when there are no meals', () {
      expect(ids(9, const []), isNot(contains('no_fruit_today')));
    });

    test('iron tip shown when meals exist but none is iron-rich', () {
      final tips = ids(9, [
        _recipe(ingredientNames: const ['apple']),
      ]);
      expect(tips, contains('include_iron'));
    });

    test('iron tip hidden when an iron-rich recipe is present', () {
      final tips = ids(9, [
        _recipe(
          nutritionTags: const ['Iron Rich'],
          ingredientNames: const ['apple'],
        ),
      ]);
      expect(tips, isNot(contains('include_iron')));
    });

    test('fruit detected via category', () {
      final tips = ids(9, [_recipe(category: 'Fruit Purees')]);
      expect(tips, isNot(contains('no_fruit_today')));
    });
  });

  group('GuidanceService.tipsFor — priority ordering', () {
    test('meal-contextual tips rank ahead of age tips', () {
      final tips = ids(9, [
        _recipe(ingredientNames: const ['chicken']),
      ]);
      expect(tips.first, 'no_fruit_today');
      expect(tips[1], 'include_iron');
    });
  });

  test('disclaimer copy is never returned as a tip', () {
    for (final age in [6, 9, 12, 18]) {
      final tips = GuidanceService.tipsFor(
        ageMonths: age,
        todaysRecipes: [
          _recipe(ingredientNames: const ['banana']),
        ],
      );
      expect(
        tips.map((t) => t.body),
        isNot(contains(GuidanceTips.healthDisclaimerBody)),
      );
    }
  });
}
