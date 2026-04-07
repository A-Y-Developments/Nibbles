import 'dart:math';

import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeState> build(String babyId) async {
    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) throw const UnknownException('Baby profile not found.');

    final recipeService = ref.read(recipeServiceProvider);

    final programResult = await ref
        .read(allergenServiceProvider)
        .getProgramState(babyId);
    if (programResult.isFailure) throw programResult.errorOrNull!;
    final programState = programResult.dataOrNull!;

    final flaggedResult = await recipeService.getFlaggedAllergenKeys(babyId);
    final flaggedKeys = flaggedResult.dataOrNull ?? <String>{};

    // Get today's meals from this week's plan
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday % 7));
    var todayMeals = <MealPlanEntry>[];
    final todayRecipes = <Recipe>[];
    final weekMealsResult = await ref
        .read(mealPlanServiceProvider)
        .getWeekMeals(babyId, weekStart);
    if (weekMealsResult.isSuccess) {
      todayMeals = weekMealsResult.dataOrNull!
          .where((MealPlanEntry e) => _isSameDay(e.planDate, today))
          .toList();
      for (final meal in todayMeals) {
        final recipeResult = await recipeService.getRecipeById(meal.recipeId);
        if (recipeResult.dataOrNull != null) {
          todayRecipes.add(recipeResult.dataOrNull!);
        }
      }
    }

    AllergenBoardItem? currentBoardItem;
    var recommendations = <Recipe>[];
    var generalRecommendations = <Recipe>[];

    if (programState.status != AllergenProgramStatus.completed) {
      final boardResult = await ref
          .read(allergenServiceProvider)
          .getAllergenBoardSummary(babyId);
      if (boardResult.isSuccess) {
        currentBoardItem = boardResult.dataOrNull!
            .where(
              (AllergenBoardItem item) =>
                  item.allergen.key == programState.currentAllergenKey,
            )
            .firstOrNull;
      }

      final isAllergenDone =
          currentBoardItem?.status == AllergenStatus.safe ||
          currentBoardItem?.status == AllergenStatus.flagged;

      if (isAllergenDone) {
        final recsResult = await recipeService.getGeneralRecommendations(
          babyId,
        );
        generalRecommendations = recsResult.dataOrNull ?? [];
      } else {
        final recsResult = await recipeService.getRecommendationsForAllergen(
          programState.currentAllergenKey,
          babyId,
        );
        recommendations = recsResult.dataOrNull ?? [];

        // Also fetch randomised general recommendations shown below the
        // allergen-specific strip when the allergen is still in progress.
        final allResult = await recipeService.getAllRecipes(babyId);
        if (allResult.isSuccess) {
          final all = List<Recipe>.from(allResult.dataOrNull!)
            ..shuffle(Random());
          generalRecommendations = all.take(10).toList();
        }
      }
    }

    return HomeState(
      baby: baby,
      programState: programState,
      currentAllergenBoardItem: currentBoardItem,
      todayMeals: todayMeals,
      todayRecipes: todayRecipes,
      recommendations: recommendations,
      isGeneralRecommendations:
          currentBoardItem?.status == AllergenStatus.safe ||
          currentBoardItem?.status == AllergenStatus.flagged,
      generalRecommendations: generalRecommendations,
      flaggedAllergenKeys: flaggedKeys,
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
