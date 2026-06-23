import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';

/// Temporary visual mock for the Recipe Library first-launch screen
/// (Figma 971:8644). Flip to `false` to restore the live
/// `RecipeLibraryController` data path. The sections, copy and card content
/// mirror the Figma frame so the screen can be designed against the real
/// layout before the backend supplies categorised content.
const bool kRecipeLibraryUseMock = false;

const List<String> _mockSectionTitles = [
  'Recomendation for Dairy Introduce',
  'Iron-rich Purées',
  'Whipped Bone Marrow',
  'Iron-rich Finger Foods',
  'Stool Softening Meals',
  '10-Minutes Meals (Minimal Prep)',
  'High-energy Meals for Small Appetites',
];

const int _cardsPerSection = 6;

Recipe _mockRecipe(String sectionKey, int index) => Recipe(
  id: '${sectionKey}_$index',
  title: 'Prawn, Egg, Spinach & Oat Flour',
  ageRange: '6+ months',
  allergenTags: const [],
  ingredients: const [],
  steps: const [],
  howToServe: '',
  thumbnailUrl: Assets.images.recipe.mockRecipe.path,
  nutritionTags: const ['Iron Rich', 'Protein', 'Omega-3'],
);

RecipeLibraryState buildMockRecipeLibraryState() {
  final byCategory = <String, List<Recipe>>{};
  for (final title in _mockSectionTitles) {
    final key = title.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');
    byCategory[title] = [
      for (var i = 0; i < _cardsPerSection; i++) _mockRecipe(key, i),
    ];
  }
  return RecipeLibraryState(recipesByCategory: byCategory);
}
