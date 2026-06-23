// Unit tests for [RecipeDetailState]'s entity-backed detail getters.
//
// These exercise the REAL getter logic against a REAL `Recipe` entity (not a
// fake subclass), pinning the wiring that surfaces the RC-02 Utensils /
// Storage / Texture-Tip / Why-this-meal sections:
//   * `utensils` collapses null OR empty → null (so the UI hides the section),
//     and passes a populated list through unchanged.
//   * storageNote / freezerNote / textureTip / whyThisMeal pass through from
//     the entity (null when absent).

import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_state.dart';

Recipe _recipe({
  List<String>? utensils,
  String? storageNote,
  String? freezerNote,
  String? textureTip,
  String? whyThisMeal,
}) => Recipe(
  id: 'r1',
  title: 'Pea Puree',
  ageRange: '6m+',
  allergenTags: const [],
  ingredients: const [],
  steps: const [],
  howToServe: 'Serve.',
  utensils: utensils,
  storageNote: storageNote,
  freezerNote: freezerNote,
  textureTip: textureTip,
  whyThisMeal: whyThisMeal,
);

RecipeDetailState _state(Recipe recipe) =>
    RecipeDetailState(recipe: recipe, currentAllergenKey: 'peanut');

void main() {
  group('RecipeDetailState.utensils', () {
    test('null utensils → null (section hidden)', () {
      expect(_state(_recipe()).utensils, isNull);
    });

    test('empty utensils → null (section hidden)', () {
      expect(_state(_recipe(utensils: const [])).utensils, isNull);
    });

    test('populated utensils → passes list through', () {
      expect(_state(_recipe(utensils: const ['Spoon', 'Bowl'])).utensils, [
        'Spoon',
        'Bowl',
      ]);
    });
  });

  group('RecipeDetailState detail copy getters', () {
    test('populated entity → getters surface the values', () {
      final state = _state(
        _recipe(
          storageNote: 'Fridge 3 days.',
          freezerNote: 'Freeze 1 month.',
          textureTip: 'Mash well.',
          whyThisMeal: 'Iron-rich first food.',
        ),
      );
      expect(state.storageNote, 'Fridge 3 days.');
      expect(state.freezerNote, 'Freeze 1 month.');
      expect(state.textureTip, 'Mash well.');
      expect(state.whyThisMeal, 'Iron-rich first food.');
    });

    test('absent entity fields → getters return null', () {
      final state = _state(_recipe());
      expect(state.storageNote, isNull);
      expect(state.freezerNote, isNull);
      expect(state.textureTip, isNull);
      expect(state.whyThisMeal, isNull);
    });
  });
}
