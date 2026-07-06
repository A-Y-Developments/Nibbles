import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/features/home/home_state.dart';

Map<String, AllergenStatus> _statuses({
  int safe = 0,
  int flagged = 0,
  int inProgress = 0,
}) {
  final keys = kAllergenKeys;
  final out = <String, AllergenStatus>{
    for (final k in keys) k: AllergenStatus.notStarted,
  };
  var i = 0;
  void assign(AllergenStatus status, int count) {
    for (var n = 0; n < count; n++) {
      out[keys[i++]] = status;
    }
  }

  assign(AllergenStatus.safe, safe);
  assign(AllergenStatus.flagged, flagged);
  assign(AllergenStatus.inProgress, inProgress);
  return out;
}

MealPlanEntry _entry() => MealPlanEntry(
  id: 'e1',
  babyId: 'b1',
  recipeId: 'r1',
  planDate: DateTime(2026),
);

void main() {
  group('HomeState.mealPrepSetUp', () {
    test('false with no meals', () {
      expect(const HomeState().mealPrepSetUp, isFalse);
    });

    test('true with at least one meal', () {
      expect(HomeState(allMeals: [_entry()]).mealPrepSetUp, isTrue);
    });
  });

  group('HomeState counts', () {
    test('introducedCount = safe + flagged', () {
      final state = HomeState(allergenStatuses: _statuses(safe: 3, flagged: 2));
      expect(state.introducedCount, 5);
      expect(state.safeCount, 3);
      expect(state.flaggedCount, 2);
    });

    test('allAllergensDone false below the full count', () {
      final state = HomeState(allergenStatuses: _statuses(safe: 10));
      expect(state.allAllergensDone, isFalse);
    });

    test('allAllergensDone true when all 11 are safe/flagged', () {
      final state = HomeState(
        allergenStatuses: _statuses(safe: 8, flagged: 3),
      );
      expect(state.introducedCount, kAllergenKeys.length);
      expect(state.allAllergensDone, isTrue);
    });

    test('hasActiveProgramAllergen tracks introduced or in-progress', () {
      expect(const HomeState().hasActiveProgramAllergen, isFalse);
      expect(
        HomeState(allergenStatuses: _statuses(inProgress: 1))
            .hasActiveProgramAllergen,
        isTrue,
      );
      final withSafe = HomeState(allergenStatuses: _statuses(safe: 1));
      expect(withSafe.hasActiveProgramAllergen, isTrue);
    });
  });

  group('HomeState.allergenHeroState', () {
    test('start when current allergen not started', () {
      const state = HomeState(
        currentAllergenKey: 'milk',
      );
      expect(state.allergenHeroState, HomeAllergenHeroState.start);
    });

    test('ongoing when current allergen in progress', () {
      const state = HomeState(
        currentAllergenKey: 'milk',
        currentAllergenStatus: AllergenStatus.inProgress,
      );
      expect(state.allergenHeroState, HomeAllergenHeroState.ongoing);
    });

    test('finishedStartNext when current allergen safe', () {
      const state = HomeState(
        currentAllergenKey: 'milk',
        currentAllergenStatus: AllergenStatus.safe,
      );
      expect(state.allergenHeroState, HomeAllergenHeroState.finishedStartNext);
    });

    test('finishedStartNext when current allergen flagged', () {
      const state = HomeState(
        currentAllergenKey: 'milk',
        currentAllergenStatus: AllergenStatus.flagged,
      );
      expect(state.allergenHeroState, HomeAllergenHeroState.finishedStartNext);
    });

    test('allDone overrides current status once all introduced', () {
      final state = HomeState(
        currentAllergenKey: 'milk',
        currentAllergenStatus: AllergenStatus.safe,
        allergenStatuses: _statuses(safe: 8, flagged: 3),
      );
      expect(state.allergenHeroState, HomeAllergenHeroState.allDone);
    });
  });
}
