import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
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

    final programResult =
        await ref.read(allergenServiceProvider).getProgramState(babyId);
    if (programResult.isFailure) throw programResult.errorOrNull!;
    final programState = programResult.dataOrNull!;

    // Get today's meal from this week's plan
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday % 7));
    MealPlanEntry? todayMeal;
    Recipe? todayRecipe;
    final weekMealsResult =
        await ref.read(mealPlanServiceProvider).getWeekMeals(babyId, weekStart);
    if (weekMealsResult.isSuccess) {
      todayMeal = weekMealsResult.dataOrNull!
          .where((MealPlanEntry e) => _isSameDay(e.planDate, today))
          .firstOrNull;
      if (todayMeal != null) {
        final recipeResult = await ref
            .read(recipeServiceProvider)
            .getRecipeById(todayMeal.recipeId);
        todayRecipe = recipeResult.dataOrNull;
      }
    }

    AllergenBoardItem? currentBoardItem;
    var hasLoggedToday = false;
    var recommendations = <Recipe>[];

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

      final hasLoggedResult = await ref
          .read(allergenServiceProvider)
          .hasLoggedToday(babyId, programState.currentAllergenKey);
      hasLoggedToday = hasLoggedResult.dataOrNull ?? false;

      final recsResult = await ref
          .read(recipeServiceProvider)
          .getRecommendationsForAllergen(
            programState.currentAllergenKey,
            babyId,
          );
      recommendations = recsResult.dataOrNull ?? [];
    }

    return HomeState(
      baby: baby,
      programState: programState,
      currentAllergenBoardItem: currentBoardItem,
      todayMeal: todayMeal,
      todayRecipe: todayRecipe,
      hasLoggedToday: hasLoggedToday,
      recommendations: recommendations,
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
