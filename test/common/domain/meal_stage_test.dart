import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/meal_stage.dart';

void main() {
  group('mealStageForAge', () {
    test('boundaries map to expected stage', () {
      expect(mealStageForAge(3), MealStage.stage0);
      expect(mealStageForAge(4), MealStage.stage0);
      expect(mealStageForAge(5), MealStage.stage1);
      expect(mealStageForAge(6), MealStage.stage2);
      expect(mealStageForAge(7), MealStage.stage3);
      expect(mealStageForAge(8), MealStage.stage3);
      expect(mealStageForAge(9), MealStage.stage4);
      expect(mealStageForAge(11), MealStage.stage4);
      expect(mealStageForAge(12), MealStage.stage5);
      expect(mealStageForAge(18), MealStage.stage5);
    });
  });

  group('mealsPerDayForAge', () {
    test('boundaries map to expected meals per day (clamped [1,3])', () {
      expect(mealsPerDayForAge(3), 1);
      expect(mealsPerDayForAge(4), 1);
      expect(mealsPerDayForAge(5), 1);
      expect(mealsPerDayForAge(6), 2);
      expect(mealsPerDayForAge(7), 2);
      expect(mealsPerDayForAge(8), 2);
      expect(mealsPerDayForAge(9), 3);
      expect(mealsPerDayForAge(11), 3);
      expect(mealsPerDayForAge(12), 3);
      expect(mealsPerDayForAge(18), 3);
    });

    test('result always within [1,3]', () {
      for (var age = 0; age <= 36; age++) {
        final meals = mealsPerDayForAge(age);
        expect(meals, greaterThanOrEqualTo(1));
        expect(meals, lessThanOrEqualTo(3));
      }
    });
  });

  group('MealStageInfo', () {
    test('texture strings match the flowchart', () {
      expect(MealStage.stage0.texture, 'Milk only');
      expect(MealStage.stage1.texture, 'Smooth / finely mashed');
      expect(MealStage.stage2.texture, 'Thick mash / soft small lumps');
      expect(
        MealStage.stage3.texture,
        'Lumpy mash / minced / soft finger foods',
      );
      expect(MealStage.stage4.texture, 'Chopped soft foods / mixed textures');
      expect(MealStage.stage5.texture, 'Soft family foods');
    });

    test('stageNumber and label', () {
      expect(MealStage.stage0.stageNumber, 0);
      expect(MealStage.stage5.stageNumber, 5);
      expect(MealStage.stage2.label, 'Stage 2');
    });
  });

  group('mealsPerDayForDob', () {
    test('derives meals per day from a date of birth', () {
      final now = DateTime(2026, 7, 7);
      // 6 months old → stage2 → 2 meals.
      expect(mealsPerDayForDob(DateTime(2026, 1, 7), now: now), 2);
      // 12 months old → stage5 → 3 meals.
      expect(mealsPerDayForDob(DateTime(2025, 7, 7), now: now), 3);
      // 3 months old → stage0 → 1 meal.
      expect(mealsPerDayForDob(DateTime(2026, 4, 7), now: now), 1);
    });
  });
}
