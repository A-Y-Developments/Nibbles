// Widget tests for the rebuilt Recipe Detail screen.
//
// Renders the screen by overriding [recipeDetailControllerProvider] with a
// canned [RecipeDetailState] and asserts:
//   * the top bar (back icon + "Recipe Detail" title + overflow icon)
//   * the hero banner + banner card + ingredients + method blocks
//   * the allergen card shows the composed sentence + verbatim advisory copy
//     (no per-allergen chips in this redesign)
//   * the storage / freezer / tip cards are HIDDEN when every state getter is
//     null, and render when overridden non-null via a `_FakeDetailState`
//   * the Add to Meal Plan CTA tap opens the multi-day Add-to-Meal-Plan sheet
//
// The post-save success/error toast is covered by the shared AppToast
// widget tests (test/common/components/feedback/app_toast_test.dart), not
// here — this screen just calls AppToast.success/.error.
//
// Firebase platform-interface packages are transitive deps; the public barrels
// don't re-export FirebaseAnalyticsPlatform/setupFirebaseCoreMocks. Test-only.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_controller.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_state.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_controller.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_screen.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_state.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/contains_allergens_card.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_banner_card.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_hero_banner.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_storage_row.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_tip_card.dart';

const _babyId = 'baby-001';

const _recipe = Recipe(
  id: 'r1',
  title: 'Avocado Toast',
  ageRange: '6+ months',
  allergenTags: ['peanut', 'egg'],
  ingredients: [
    Ingredient(name: 'Avocado', quantity: '1 whole'),
    Ingredient(name: 'Bread', quantity: '2 slices'),
  ],
  steps: ['Mash.', 'Spread.'],
  howToServe: 'Serve immediately.',
  nutritionTags: ['Iron-rich', 'Quick'],
  category: 'Purees',
);

const _emptyRecipe = Recipe(
  id: 'r-empty',
  title: 'Plain Carrot',
  ageRange: '6+ months',
  allergenTags: [],
  ingredients: [Ingredient(name: 'Carrot', quantity: '1')],
  steps: ['Boil.'],
  howToServe: 'Serve.',
);

class _NoopAnalyticsPlatform extends FirebaseAnalyticsPlatform {
  _NoopAnalyticsPlatform() : super();

  @override
  FirebaseAnalyticsPlatform delegateFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) => this;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {}
}

/// Implements [RecipeDetailState] so the storage / freezer / tip / utensils
/// getters can be overridden non-null without modifying production code.
/// The default freezed state only exposes those derived fields as `=> null`
/// getters that copyWith can't reach.
// allergenStatuses / isAdding* / storage / freezer are part of the interface
// contract — keep them constructor-addressable even though every current call
// site relies on the default.
// ignore_for_file: unused_element_parameter
class _FakeDetailState implements RecipeDetailState {
  const _FakeDetailState({
    required this.recipe,
    required this.currentAllergenKey,
    this.allergenStatuses = const {},
    this.isAddingToShoppingList = false,
    this.storage,
    this.freezer,
    this.texture,
    this.why,
    this.utensilsList,
  });

  @override
  final Recipe recipe;

  @override
  final String currentAllergenKey;

  @override
  final Map<String, AllergenStatus> allergenStatuses;

  @override
  final bool isAddingToShoppingList;

  final String? storage;
  final String? freezer;
  final String? texture;
  final String? why;
  final List<String>? utensilsList;

  @override
  String? get storageNote => storage;

  @override
  String? get freezerNote => freezer;

  @override
  String? get textureTip => texture;

  @override
  String? get whyThisMeal => why;

  @override
  List<String>? get utensils => utensilsList;

  // copyWith is not exercised by the screen.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRecipeDetailController extends RecipeDetailController {
  _FakeRecipeDetailController(this._state);

  final RecipeDetailState _state;

  @override
  Future<RecipeDetailState> build(String babyId, String recipeId) async =>
      _state;
}

/// Fake with no active plan — the Add-to-Meal-Plan sheet's Step 1
/// ("Select Period Date") is what the CTA tap flow asserts against below.
final _emptyMealPlanState = MealPlanState(
  windowStart: DateTime(2026),
  windowEnd: DateTime(2026),
  entries: const [],
);

class _FakeMealPlanController extends MealPlanController {
  @override
  Future<MealPlanState> build(String babyId) async => _emptyMealPlanState;
}

Widget _buildSut({required RecipeDetailState state, required String recipeId}) {
  return ProviderScope(
    overrides: [
      currentBabyIdProvider.overrideWith((ref) async => _babyId),
      recipeDetailControllerProvider(
        _babyId,
        recipeId,
      ).overrideWith(() => _FakeRecipeDetailController(state)),
      mealPlanControllerProvider(
        _babyId,
      ).overrideWith(_FakeMealPlanController.new),
    ],
    child: MaterialApp(home: RecipeDetailScreen(recipeId: recipeId)),
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required RecipeDetailState state,
  String recipeId = 'r1',
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildSut(state: state, recipeId: recipeId));
  // PostFrame Analytics fire is unawaited — settle so the screen renders.
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  group('RecipeDetailScreen — base layout', () {
    testWidgets('renders top bar + hero + banner + ingredients + method', (
      tester,
    ) async {
      const state = RecipeDetailState(
        recipe: _recipe,
        currentAllergenKey: 'peanut',
      );

      await _pump(tester, state: state);

      // Top bar.
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.text('Recipe Detail'), findsOneWidget);
      // Hero + banner.
      expect(find.byType(RecipeHeroBanner), findsOneWidget);
      expect(find.byType(RecipeBannerCard), findsOneWidget);
      expect(find.text(_recipe.title), findsWidgets);
      // "Best for $ageRange" subtitle line in banner card.
      expect(find.text('Best for ${_recipe.ageRange}'), findsOneWidget);
      // Ingredients + Method section headers.
      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('Method'), findsOneWidget);
      // CTA row below the content list.
      expect(find.text('Add to Meal Plan'), findsOneWidget);
      expect(find.text('Add to Shopping List'), findsOneWidget);
    });

    testWidgets(
      'ContainsAllergensCard renders title + composed sentence + advisory',
      (tester) async {
        const state = RecipeDetailState(
          recipe: _recipe,
          currentAllergenKey: 'peanut',
        );

        await _pump(tester, state: state);

        expect(find.byType(ContainsAllergensCard), findsOneWidget);
        expect(find.text('Contains allergens'), findsOneWidget);
        expect(
          find.text(
            'This recipe contains peanut and egg, which are included in '
            'the Big 11 allergens.',
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'Always consult your pediatrician before introducing '
            'allergens to your baby.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('ContainsAllergensCard is hidden when allergenTags is empty', (
      tester,
    ) async {
      const state = RecipeDetailState(
        recipe: _emptyRecipe,
        currentAllergenKey: 'peanut',
      );

      await _pump(tester, state: state);

      expect(find.byType(ContainsAllergensCard), findsNothing);
      expect(find.text('Contains allergens'), findsNothing);
    });
  });

  group('RecipeDetailScreen — storage / freezer / tip card branches', () {
    testWidgets(
      'all-null getters → RecipeStorageRow + RecipeTipCard branches HIDDEN',
      (tester) async {
        // Default RecipeDetailState getters all return null. Placeholder state.
        const state = RecipeDetailState(
          recipe: _emptyRecipe,
          currentAllergenKey: 'peanut',
        );

        await _pump(tester, state: state);

        expect(find.byType(RecipeStorageRow), findsNothing);
        expect(find.byType(RecipeTipCard), findsNothing);
        // Utensils section is also gated; header should not render.
        expect(find.text('Utensils / appliances'), findsNothing);
      },
    );

    testWidgets(
      'non-null storage + freezer → RecipeStorageRow renders both notes',
      (tester) async {
        const state = _FakeDetailState(
          recipe: _emptyRecipe,
          currentAllergenKey: 'peanut',
          storage: 'Fridge up to 24 hours',
          freezer: 'Freeze up to 2 months',
        );

        await _pump(tester, state: state);

        expect(find.byType(RecipeStorageRow), findsOneWidget);
        expect(find.text('Storage'), findsOneWidget);
        expect(find.text('Fridge up to 24 hours'), findsOneWidget);
        expect(find.text('Freezer'), findsOneWidget);
        expect(find.text('Freeze up to 2 months'), findsOneWidget);
      },
    );

    testWidgets(
      'non-null textureTip and whyThisMeal → RecipeTipCard renders for each',
      (tester) async {
        const state = _FakeDetailState(
          recipe: _emptyRecipe,
          currentAllergenKey: 'peanut',
          texture: 'Mash to a smooth puree.',
          why: 'High in vitamin A.',
        );

        await _pump(tester, state: state);

        expect(find.byType(RecipeTipCard), findsNWidgets(2));
      },
    );

    testWidgets('non-null utensils → Utensils / appliances section renders', (
      tester,
    ) async {
      const state = _FakeDetailState(
        recipe: _emptyRecipe,
        currentAllergenKey: 'peanut',
        utensilsList: ['Spoon', 'Bowl'],
      );

      await _pump(tester, state: state);

      expect(find.text('Utensils / appliances'), findsOneWidget);
      expect(find.text('Spoon'), findsOneWidget);
      expect(find.text('Bowl'), findsOneWidget);
    });
  });

  group('RecipeDetailScreen — CTA row flow', () {
    testWidgets(
      'tap on Add to Meal Plan CTA opens the plan-aware sheet, defaulting '
      "to Select Period Date when there's no active plan",
      (tester) async {
        const state = RecipeDetailState(
          recipe: _recipe,
          currentAllergenKey: 'peanut',
        );

        await _pump(tester, state: state);

        await tester.tap(find.text('Add to Meal Plan'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Fake mealPlanControllerProvider has no active plan → the sheet
        // opens on Step 1 ("Select Period Date", Figma 971:8053).
        expect(find.text('Select Period Date'), findsOneWidget);
      },
    );
  });

  group('RecipeDetailScreen — overflow menu', () {
    testWidgets('shows Add to Meal Plan and Add to Shopping List options', (
      tester,
    ) async {
      const state = RecipeDetailState(
        recipe: _recipe,
        currentAllergenKey: 'peanut',
      );

      await _pump(tester, state: state);

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'Add to Meal Plan'), findsOneWidget);
      expect(
        find.widgetWithText(ListTile, 'Add to Shopping List'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Add to Meal Plan opens the plan-aware sheet', (
      tester,
    ) async {
      const state = RecipeDetailState(
        recipe: _recipe,
        currentAllergenKey: 'peanut',
      );

      await _pump(tester, state: state);

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Add to Meal Plan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Select Period Date'), findsOneWidget);
    });

    testWidgets('tapping Add to Shopping List opens the shoplist sheet', (
      tester,
    ) async {
      const state = RecipeDetailState(
        recipe: _recipe,
        currentAllergenKey: 'peanut',
      );

      await _pump(tester, state: state);

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Add to Shopping List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Add to Shoplist'), findsOneWidget);
    });
  });

  group('RecipeDetailScreen — empty section guards', () {
    const bareRecipe = Recipe(
      id: 'r-bare',
      title: 'Bare Recipe',
      ageRange: '6+ months',
      allergenTags: [],
      ingredients: [],
      steps: [],
      howToServe: 'Serve.',
    );

    testWidgets('empty ingredients/steps -> no Ingredients/Method headers', (
      tester,
    ) async {
      await _pump(
        tester,
        state: const RecipeDetailState(
          recipe: bareRecipe,
          currentAllergenKey: '',
        ),
        recipeId: 'r-bare',
      );

      expect(find.text('Ingredients'), findsNothing);
      expect(find.text('Method'), findsNothing);
    });

    testWidgets('non-empty ingredients/steps -> headers present', (
      tester,
    ) async {
      await _pump(
        tester,
        state: const RecipeDetailState(
          recipe: _recipe,
          currentAllergenKey: 'peanut',
        ),
      );

      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('Method'), findsOneWidget);
    });
  });
}
