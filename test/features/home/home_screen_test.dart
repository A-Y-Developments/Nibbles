import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/home/home_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockBabyProfileService extends Mock implements BabyProfileService {}

class MockAllergenService extends Mock implements AllergenService {}

class MockMealPlanService extends Mock implements MealPlanService {}

class MockRecipeService extends Mock implements RecipeService {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _babyId = 'baby-001';

final _fakeBaby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

const _peanutAllergen = Allergen(
  key: 'peanut',
  name: 'Peanut',
  sequenceOrder: 1,
  emoji: '🥜',
);

AllergenBoardItem _makeBoardItem({
  AllergenStatus status = AllergenStatus.inProgress,
}) =>
    AllergenBoardItem(
      allergen: _peanutAllergen,
      logs: const [],
      status: status,
    );

AllergenProgramState _makeProgramState({
  AllergenProgramStatus status = AllergenProgramStatus.inProgress,
  String currentKey = 'peanut',
  int currentOrder = 1,
}) {
  final now = DateTime.now();
  return AllergenProgramState(
    id: 'ps-1',
    babyId: _babyId,
    currentAllergenKey: currentKey,
    currentSequenceOrder: currentOrder,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

const _fakeRecipe = Recipe(
  id: 'recipe-001',
  title: 'Peanut Butter Toast',
  ageRange: '6m+',
  allergenTags: ['peanut'],
  ingredients: [],
  steps: [],
  howToServe: 'Serve mashed.',
);

MealPlanEntry get _todayMeal => MealPlanEntry(
      id: 'mp-001',
      babyId: _babyId,
      recipeId: 'recipe-001',
      planDate: DateTime.now(),
    );

// ---------------------------------------------------------------------------
// Router + widget helper
// ---------------------------------------------------------------------------

GoRouter _routerFor(Widget screen) => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => screen),
        GoRoute(
          path: AppRoute.profile.path,
          name: AppRoute.profile.name,
          builder: (_, __) => const Scaffold(body: Text('Profile')),
        ),
        GoRoute(
          path: AppRoute.recipeLibrary.path,
          name: AppRoute.recipeLibrary.name,
          builder: (_, __) => const Scaffold(body: Text('Recipes')),
        ),
        GoRoute(
          path: '/home/recipes/:recipeId',
          name: AppRoute.recipeDetail.name,
          builder: (_, __) => const Scaffold(body: Text('Recipe Detail')),
        ),
        GoRoute(
          path: AppRoute.shoppingList.path,
          name: AppRoute.shoppingList.name,
          builder: (_, __) => const Scaffold(body: Text('Shopping List')),
        ),
      ],
    );

Widget _wrap(Widget screen, List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(routerConfig: _routerFor(screen)),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockBabyProfileService mockBabyService;
  late MockAllergenService mockAllergenService;
  late MockMealPlanService mockMealPlanService;
  late MockRecipeService mockRecipeService;

  setUp(() {
    mockBabyService = MockBabyProfileService();
    mockAllergenService = MockAllergenService();
    mockMealPlanService = MockMealPlanService();
    mockRecipeService = MockRecipeService();
  });

  List<Override> buildOverrides() => [
        babyProfileServiceProvider.overrideWithValue(mockBabyService),
        allergenServiceProvider.overrideWithValue(mockAllergenService),
        mealPlanServiceProvider.overrideWithValue(mockMealPlanService),
        recipeServiceProvider.overrideWithValue(mockRecipeService),
      ];

  /// Stubs the minimum service calls required for the home controller to build.
  void stubCommon({
    required AllergenProgramState programState,
    bool hasLoggedToday = false,
    List<Recipe> recommendations = const [],
    List<MealPlanEntry> weekMeals = const [],
    Recipe? recipeForMeal,
    AllergenBoardItem? boardItem,
  }) {
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(() => mockAllergenService.getProgramState(_babyId))
        .thenAnswer((_) async => Result.success(programState));
    when(() => mockMealPlanService.getWeekMeals(_babyId, any()))
        .thenAnswer((_) async => Result.success(weekMeals));
    if (recipeForMeal != null) {
      when(() => mockRecipeService.getRecipeById(any()))
          .thenAnswer((_) async => Result.success(recipeForMeal));
    }
    if (programState.status != AllergenProgramStatus.completed) {
      when(() => mockAllergenService.getAllergenBoardSummary(_babyId))
          .thenAnswer(
            (_) async => Result.success([boardItem ?? _makeBoardItem()]),
          );
      when(() => mockAllergenService.hasLoggedToday(_babyId, any()))
          .thenAnswer((_) async => Result.success(hasLoggedToday));
      when(
        () => mockRecipeService
            .getRecommendationsForAllergen(any(), _babyId),
      ).thenAnswer((_) async => Result.success(recommendations));
    }
  }

  // -------------------------------------------------------------------------
  // State A: active, not logged today
  // -------------------------------------------------------------------------

  testWidgets(
    'State A — allergen emoji, name, Day X/3 and Log Food button shown',
    (tester) async {
      stubCommon(programState: _makeProgramState());

      await tester.pumpWidget(_wrap(const HomeScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      expect(find.text('🥜'), findsWidgets);
      expect(find.text('Peanut'), findsOneWidget);
      expect(find.textContaining('Day'), findsOneWidget);
      expect(find.byKey(const Key('log_food_button')), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // State B: logged today
  // -------------------------------------------------------------------------

  testWidgets(
    'State B — Log Food replaced by "Logged today" indicator when logged today',
    (tester) async {
      stubCommon(programState: _makeProgramState(), hasLoggedToday: true);

      await tester.pumpWidget(_wrap(const HomeScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('log_food_button')), findsNothing);
      expect(find.text('Logged today'), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // State C: program complete
  // -------------------------------------------------------------------------

  testWidgets(
    'State C — completion banner shown, allergen widget and strip absent',
    (tester) async {
      stubCommon(
        programState: _makeProgramState(
          status: AllergenProgramStatus.completed,
        ),
      );

      await tester.pumpWidget(_wrap(const HomeScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('has completed the allergen program'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('log_food_button')), findsNothing);
      expect(find.textContaining('Recommended for'), findsNothing);
    },
  );

  // -------------------------------------------------------------------------
  // No meal today
  // -------------------------------------------------------------------------

  testWidgets(
    'No meal today — empty state copy and Browse Recipe Library CTA shown',
    (tester) async {
      stubCommon(programState: _makeProgramState());

      await tester.pumpWidget(_wrap(const HomeScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'No meal planned for today. Add one from the recipe library.',
        ),
        findsOneWidget,
      );
      expect(find.text('Browse Recipe Library'), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // With meal today
  // -------------------------------------------------------------------------

  testWidgets(
    'With meal today — recipe name and allergen badge shown',
    (tester) async {
      stubCommon(
        programState: _makeProgramState(),
        weekMeals: [_todayMeal],
        recipeForMeal: _fakeRecipe,
      );

      await tester.pumpWidget(_wrap(const HomeScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      expect(find.text('Peanut Butter Toast'), findsOneWidget);
      expect(find.textContaining('peanut'), findsWidgets);
    },
  );

  // -------------------------------------------------------------------------
  // Recommendations strip visible
  // -------------------------------------------------------------------------

  testWidgets(
    'Recommendations strip visible when program in progress and recipes exist',
    (tester) async {
      stubCommon(
        programState: _makeProgramState(),
        recommendations: [_fakeRecipe],
      );

      await tester.pumpWidget(_wrap(const HomeScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Recommended for'), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // Recommendations hidden — program complete
  // -------------------------------------------------------------------------

  testWidgets(
    'Recommendations strip absent when allergen program is completed',
    (tester) async {
      stubCommon(
        programState: _makeProgramState(
          status: AllergenProgramStatus.completed,
        ),
      );

      await tester.pumpWidget(_wrap(const HomeScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Recommended for'), findsNothing);
    },
  );

  // -------------------------------------------------------------------------
  // Recommendations hidden — no matching recipes
  // -------------------------------------------------------------------------

  testWidgets(
    'Recommendations strip absent when no recipes match current allergen',
    (tester) async {
      stubCommon(programState: _makeProgramState());

      await tester.pumpWidget(_wrap(const HomeScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Recommended for'), findsNothing);
    },
  );
}
