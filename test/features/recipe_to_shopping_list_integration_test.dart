// Integration widget test: recipe library → recipe detail →
// add to shopping list.
//
// Covers ticket NIB-32 acceptance criteria:
//   - names only in shopping list (zero quantity strings)
//   - deselected ingredients not added
//
// Scope: RC-01 → RC-02 → Add to Shopping List sheet → confirm with one
// ingredient deselected. Tests do NOT exercise "Add to Meal Plan" to avoid
// Firebase Analytics initialisation in the widget-test harness.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_screen.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class MockRecipeService extends Mock implements RecipeService {}

class MockAllergenService extends Mock implements AllergenService {}

class MockShoppingListService extends Mock implements ShoppingListService {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

const _babyId = 'baby-001';
final _now = DateTime(2026, 3, 24);

AllergenProgramState _makeProgramState() => AllergenProgramState(
  id: 'ps-1',
  babyId: _babyId,
  currentAllergenKey: 'peanut',
  currentSequenceOrder: 1,
  status: AllergenProgramStatus.inProgress,
  createdAt: _now,
  updatedAt: _now,
);

AllergenLog _makeLog() => AllergenLog(
  id: 'log-1',
  babyId: _babyId,
  allergenKey: 'peanut',
  emojiTaste: EmojiTaste.love,
  hadReaction: false,
  logDate: _now,
  createdAt: _now,
);

GoRouter _makeTestRouter() => GoRouter(
  initialLocation: AppRoute.recipeLibrary.path,
  routes: [
    GoRoute(
      path: AppRoute.recipeLibrary.path,
      name: AppRoute.recipeLibrary.name,
      builder: (_, __) => const RecipeLibraryScreen(),
    ),
    GoRoute(
      path: AppRoute.recipeDetail.path,
      name: AppRoute.recipeDetail.name,
      builder: (_, state) =>
          RecipeDetailScreen(recipeId: state.pathParameters['recipeId'] ?? ''),
    ),
  ],
);

Widget _buildSut({
  required MockRecipeService recipeService,
  required MockAllergenService allergenService,
  required MockShoppingListService shoppingListService,
  required MockLocalFlagService localFlagService,
  required GoRouter router,
}) => ProviderScope(
  overrides: [
    currentBabyIdProvider.overrideWith((ref) async => _babyId),
    recipeServiceProvider.overrideWithValue(recipeService),
    allergenServiceProvider.overrideWithValue(allergenService),
    shoppingListServiceProvider.overrideWithValue(shoppingListService),
    localFlagServiceProvider.overrideWithValue(localFlagService),
  ],
  child: MaterialApp.router(routerConfig: router),
);

void main() {
  late MockRecipeService mockRecipeService;
  late MockAllergenService mockAllergenService;
  late MockShoppingListService mockShoppingListService;
  late MockLocalFlagService mockLocalFlagService;
  late GoRouter testRouter;

  setUpAll(() {
    registerFallbackValue(_makeLog());
    registerFallbackValue(_makeProgramState());
    registerFallbackValue(_now);
    registerFallbackValue(<String>[]);
    // Suppress clipboard channel errors.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') return null;
          if (call.method == 'Clipboard.getData') return {'text': ''};
          return null;
        });
  });

  setUp(() {
    mockRecipeService = MockRecipeService();
    mockAllergenService = MockAllergenService();
    mockShoppingListService = MockShoppingListService();
    mockLocalFlagService = MockLocalFlagService();
    testRouter = _makeTestRouter();
  });

  // ---------------------------------------------------------------------------
  // Integration test
  // ---------------------------------------------------------------------------

  testWidgets(
    'RC-01 → RC-02 → Add to Shopping List: names only, deselected excluded',
    (tester) async {
      const recipe = Recipe(
        id: 'r1',
        title: 'Avocado Toast',
        ageRange: '6m+',
        allergenTags: [],
        ingredients: [
          Ingredient(name: 'Avocado', quantity: '1 whole'),
          Ingredient(name: 'Bread', quantity: '2 slices'),
        ],
        steps: ['Mash avocado.', 'Spread on bread.'],
        howToServe: 'Serve immediately.',
      );

      // --- Stubs ---

      // RC-01 (NIB-53): library now drives off getRecipesByCategory.
      // Keep getAllRecipes stubbed for any indirect callers.
      when(
        () => mockRecipeService.getAllRecipes(any()),
      ).thenAnswer((_) async => const Result.success([recipe]));
      when(
        () => mockRecipeService.getRecipesByCategory(any()),
      ).thenAnswer(
        (_) async => const Result.success({
          'Other': [recipe],
        }),
      );
      when(
        () => mockRecipeService.getFlaggedAllergenKeys(any()),
      ).thenAnswer((_) async => const Result.success(<String>{}));
      // RC-01 (NIB-53): allergen statuses replace program state for
      // ongoing-allergen detection in the library.
      when(
        () => mockAllergenService.getAllergenStatuses(any()),
      ).thenAnswer(
        (_) async => Result.success({
          for (final k in kAllergenKeys) k: AllergenStatus.notStarted,
        }),
      );
      // RecipeDetailController still relies on getProgramState (NIB-68
      // owns the detail reskin). Keep this stub so detail navigation works.
      when(
        () => mockAllergenService.getProgramState(any()),
      ).thenAnswer((_) async => Result.success(_makeProgramState()));
      // First-launch banner — flag the guide as seen so the test focuses on
      // the navigation flow without dismissing the banner first.
      when(
        () => mockLocalFlagService.isStartingGuideSeen(),
      ).thenReturn(true);

      // RC-02: recipe detail loads
      when(
        () => mockRecipeService.getRecipeById('r1'),
      ).thenAnswer((_) async => const Result.success(recipe));
      when(
        () => mockAllergenService.getLogs(any()),
      ).thenAnswer((_) async => const Result.success([]));
      // deriveStatus is a pure sync method — returns notStarted for empty logs
      when(
        () => mockAllergenService.deriveStatus(any()),
      ).thenReturn(AllergenStatus.notStarted);

      // Shopping list add
      when(
        () => mockShoppingListService.addFromRecipe(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(
        _buildSut(
          recipeService: mockRecipeService,
          allergenService: mockAllergenService,
          shoppingListService: mockShoppingListService,
          localFlagService: mockLocalFlagService,
          router: testRouter,
        ),
      );
      await tester.pumpAndSettle();

      // --- RC-01: Recipe Library ---
      expect(find.text('Avocado Toast'), findsOneWidget);

      // Tap recipe card to navigate to RC-02
      await tester.tap(find.text('Avocado Toast'));
      await tester.pumpAndSettle();

      // --- RC-02: Recipe Detail ---
      // Both CTAs visible at bottom
      expect(find.text('Add to Shopping List'), findsOneWidget);

      // Tap "Add to Shopping List"
      await tester.tap(find.text('Add to Shopping List'));
      await tester.pumpAndSettle();

      // --- Shopping List Sheet ---
      // Both ingredient names shown — no quantities
      expect(find.text('Avocado'), findsOneWidget);
      expect(find.text('Bread'), findsOneWidget);
      // Quantities NOT shown as text in the sheet
      expect(find.text('1 whole'), findsNothing);
      expect(find.text('2 slices'), findsNothing);

      // Deselect 'Bread' via its CheckboxListTile
      await tester.tap(
        find.ancestor(
          of: find.text('Bread'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      await tester.pumpAndSettle();

      // Confirm with 1 item selected
      expect(find.text('Add 1 item'), findsOneWidget);
      await tester.tap(find.text('Add 1 item'));
      await tester.pumpAndSettle();

      // --- Verify addFromRecipe call ---
      final captured = verify(
        () => mockShoppingListService.addFromRecipe(any(), any(), captureAny()),
      ).captured;

      final selectedNames = captured.single as List<String>;

      // Only 'Avocado' was selected
      expect(selectedNames, equals(['Avocado']));
      // 'Bread' was deselected
      expect(selectedNames, isNot(contains('Bread')));
      // No quantity strings present
      expect(
        selectedNames.any(
          (n) =>
              n.contains('whole') ||
              n.contains('slice') ||
              n.contains('cup') ||
              n.contains('tbsp'),
        ),
        isFalse,
      );
    },
  );
}
