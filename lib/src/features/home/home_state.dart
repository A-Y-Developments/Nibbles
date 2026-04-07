import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required Baby baby,
    required AllergenProgramState programState,
    required List<Recipe> recommendations,
    AllergenBoardItem? currentAllergenBoardItem,
    @Default([]) List<MealPlanEntry> todayMeals,
    @Default([]) List<Recipe> todayRecipes,
    @Default(false) bool isGeneralRecommendations,
    @Default([]) List<Recipe> generalRecommendations,
    @Default(<String>{}) Set<String> flaggedAllergenKeys,
  }) = _HomeState;
}
