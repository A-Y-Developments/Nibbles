import 'package:nibbles/src/app/constants/guidance_tips.dart';
import 'package:nibbles/src/common/domain/entities/guidance_tip.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Pure, deterministic selector for Home's guidance tips.
///
/// Rules are evaluated in a fixed priority order (meal-contextual tips first,
/// then age-based) and the top matching tips are returned. No I/O, no state —
/// directly unit-testable.
abstract final class GuidanceService {
  static const int _maxTips = 3;

  /// Returns up to 3 relevant [GuidanceTip]s for a baby of [ageMonths] given
  /// the recipes planned for the selected day ([todaysRecipes]).
  static List<GuidanceTip> tipsFor({
    required int ageMonths,
    required List<Recipe> todaysRecipes,
  }) {
    final hasMeals = todaysRecipes.isNotEmpty;
    final hasFruit = todaysRecipes.any(_isFruit);
    final hasIron = todaysRecipes.any(_isIronRich);

    final ranked = <({GuidanceTip tip, bool matches})>[
      (tip: GuidanceTips.noFruitToday, matches: hasMeals && !hasFruit),
      (
        tip: GuidanceTips.includeIron,
        matches: ageMonths >= 6 && hasMeals && !hasIron,
      ),
      (tip: GuidanceTips.offerWater, matches: ageMonths >= 6),
      (tip: GuidanceTips.milkPriority, matches: ageMonths < 12),
      (tip: GuidanceTips.skipSaltSugar, matches: ageMonths >= 6),
      (tip: GuidanceTips.tryFingerFoods, matches: ageMonths >= 8),
      (tip: GuidanceTips.offerVariety, matches: ageMonths >= 7),
      (tip: GuidanceTips.introduceAllergens, matches: ageMonths >= 6),
    ];

    return ranked
        .where((r) => r.matches)
        .map((r) => r.tip)
        .take(_maxTips)
        .toList(growable: false);
  }

  static bool _isIronRich(Recipe recipe) =>
      recipe.nutritionTags.any((t) => t.toLowerCase().contains('iron'));

  static bool _isFruit(Recipe recipe) {
    final haystack = <String>[
      if (recipe.category != null) recipe.category!.toLowerCase(),
      ...recipe.nutritionTags.map((t) => t.toLowerCase()),
      ...recipe.ingredients.map((i) => i.name.toLowerCase()),
    ];
    return haystack.any(
      (value) => kFruitTerms.any(value.contains),
    );
  }
}
