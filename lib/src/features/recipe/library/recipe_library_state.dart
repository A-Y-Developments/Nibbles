import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

part 'recipe_library_state.freezed.dart';

@freezed
class RecipeLibraryState with _$RecipeLibraryState {
  const factory RecipeLibraryState({required List<RecipeSection> sections}) =
      _RecipeLibraryState;
}

@freezed
class RecipeSection with _$RecipeSection {
  const factory RecipeSection({
    required String title,
    required List<Recipe> recipes,
  }) = _RecipeSection;
}
