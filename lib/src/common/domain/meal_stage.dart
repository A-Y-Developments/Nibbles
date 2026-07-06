import 'package:nibbles/src/utils/age_in_months.dart';

/// Solids-progression stage derived from the baby's age. Each stage carries a
/// human label, a texture-rule description (from the feeding flowchart), and a
/// target number of solid meals per day. Drives the meal-prep slot counts and
/// the AI generation prompt.
enum MealStage { stage0, stage1, stage2, stage3, stage4, stage5 }

extension MealStageInfo on MealStage {
  /// Human-readable texture rule for the stage.
  String get texture => switch (this) {
    MealStage.stage0 => 'Milk only',
    MealStage.stage1 => 'Smooth / finely mashed',
    MealStage.stage2 => 'Thick mash / soft small lumps',
    MealStage.stage3 => 'Lumpy mash / minced / soft finger foods',
    MealStage.stage4 => 'Chopped soft foods / mixed textures',
    MealStage.stage5 => 'Soft family foods',
  };

  /// Zero-based stage index (stage0 → 0 … stage5 → 5).
  int get stageNumber => index;

  /// Display label, e.g. "Stage 2".
  String get label => 'Stage $stageNumber';
}

/// Maps an age in whole months to its [MealStage].
///
/// `<5 → stage0`, `5 → stage1`, `6 → stage2`, `7–8 → stage3`,
/// `9–11 → stage4`, `>=12 → stage5`.
MealStage mealStageForAge(int ageMonths) {
  if (ageMonths < 5) return MealStage.stage0;
  if (ageMonths == 5) return MealStage.stage1;
  if (ageMonths == 6) return MealStage.stage2;
  if (ageMonths <= 8) return MealStage.stage3;
  if (ageMonths <= 11) return MealStage.stage4;
  return MealStage.stage5;
}

/// Target number of solid meals per day for an age in whole months, clamped to
/// `[1, 3]`. Soft target — the planner allows more or fewer.
int mealsPerDayForAge(int ageMonths) {
  final perStage = switch (mealStageForAge(ageMonths)) {
    MealStage.stage0 => 1,
    MealStage.stage1 => 1,
    MealStage.stage2 => 2,
    MealStage.stage3 => 2,
    MealStage.stage4 => 3,
    MealStage.stage5 => 3,
  };
  return perStage.clamp(1, 3);
}

/// Convenience: target meals per day derived directly from a date of birth.
int mealsPerDayForDob(DateTime dob, {DateTime? now}) =>
    mealsPerDayForAge(ageInMonths(dob, now: now));
