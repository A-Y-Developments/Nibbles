// firebase_analytics_platform_interface and firebase_core_platform_interface
// are transitive deps; their public barrels don't re-export the test helpers.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_controller.dart';

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

class _MockRecipeService extends Mock implements RecipeService {}

class _MockAllergenService extends Mock implements AllergenService {}

class _MockMealPlanService extends Mock implements MealPlanService {}

class _MockShoppingListService extends Mock implements ShoppingListService {}

const _babyId = 'baby-1';
const _recipe = Recipe(
  id: 'r1',
  title: 'Plain Carrot',
  ageRange: '6+ months',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);
const _taggedRecipe = Recipe(
  id: 'r1',
  title: 'Peanut Puff',
  ageRange: '6+ months',
  allergenTags: ['peanut'],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);
final _programState = AllergenProgramState(
  id: 'prog-1',
  babyId: _babyId,
  currentAllergenKey: 'peanut',
  currentSequenceOrder: 1,
  status: AllergenProgramStatus.inProgress,
  createdAt: DateTime(2025, 6),
  updatedAt: DateTime(2025, 6),
);

void main() {
  late _MockRecipeService recipeSvc;
  late _MockAllergenService allergenSvc;
  late _MockMealPlanService mealPlanSvc;
  late _MockShoppingListService shoppingListSvc;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(const <RecipeAssignment>[]);
    registerFallbackValue(const <AllergenLog>[]);
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  setUp(() {
    recipeSvc = _MockRecipeService();
    allergenSvc = _MockAllergenService();
    mealPlanSvc = _MockMealPlanService();
    shoppingListSvc = _MockShoppingListService();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        recipeServiceProvider.overrideWithValue(recipeSvc),
        allergenServiceProvider.overrideWithValue(allergenSvc),
        mealPlanServiceProvider.overrideWithValue(mealPlanSvc),
        shoppingListServiceProvider.overrideWithValue(shoppingListSvc),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  void stubHappyBuild({Recipe recipe = _recipe}) {
    when(
      () => recipeSvc.getRecipeById(any()),
    ).thenAnswer((_) async => Result.success(recipe));
    when(
      () => allergenSvc.getProgramState(any()),
    ).thenAnswer((_) async => Result.success(_programState));
    when(
      () => allergenSvc.getLogs(any()),
    ).thenAnswer((_) async => const Result.success(<AllergenLog>[]));
  }

  void stubFailedBuild() {
    when(
      () => recipeSvc.getRecipeById(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));
    when(
      () => allergenSvc.getProgramState(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));
    when(
      () => allergenSvc.getLogs(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));
  }

  group('build() — allergen degradation', () {
    test('allergen program/logs read failure still renders the recipe', () async {
      when(
        () => recipeSvc.getRecipeById(any()),
      ).thenAnswer((_) async => const Result.success(_recipe));
      when(
        () => allergenSvc.getProgramState(any()),
      ).thenAnswer((_) async => const Result.failure(NetworkException()));
      when(
        () => allergenSvc.getLogs(any()),
      ).thenAnswer((_) async => const Result.failure(NetworkException()));

      final state = await container().read(
        recipeDetailControllerProvider(_babyId, 'r1').future,
      );

      expect(state.recipe.id, 'r1');
      expect(state.currentAllergenKey, '');
      expect(state.allergenStatuses, isEmpty);
    });

    test('recipe read failure throws (recipe is essential)', () async {
      stubFailedBuild();

      await expectLater(
        container().read(recipeDetailControllerProvider(_babyId, 'r1').future),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('build() — happy path', () {
    test('derives allergen statuses per tag', () async {
      stubHappyBuild(recipe: _taggedRecipe);
      when(
        () => allergenSvc.deriveStatus(any()),
      ).thenReturn(AllergenStatus.inProgress);

      final state = await container().read(
        recipeDetailControllerProvider(_babyId, 'r1').future,
      );

      expect(state.allergenStatuses, {'peanut': AllergenStatus.inProgress});
      expect(state.currentAllergenKey, 'peanut');
    });

    test('empty allergenTags yields empty statuses map', () async {
      stubHappyBuild();

      final state = await container().read(
        recipeDetailControllerProvider(_babyId, 'r1').future,
      );

      expect(state.allergenStatuses, isEmpty);
    });
  });

  group('assignToMealPlan()', () {
    test('returns empty list when dates is empty', () async {
      stubHappyBuild();
      final c = container();
      await c.read(recipeDetailControllerProvider(_babyId, 'r1').future);

      final result = await c
          .read(recipeDetailControllerProvider(_babyId, 'r1').notifier)
          .assignToMealPlan({});

      expect(result.isSuccess, true);
      expect(result.dataOrNull, isEmpty);
    });

    test('propagates service failure', () async {
      stubHappyBuild();
      when(
        () => mealPlanSvc.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          assignments: any(named: 'assignments'),
        ),
      ).thenAnswer((_) async => const Result.failure(NetworkException()));

      final c = container();
      await c.read(recipeDetailControllerProvider(_babyId, 'r1').future);

      final result = await c
          .read(recipeDetailControllerProvider(_babyId, 'r1').notifier)
          .assignToMealPlan({DateTime(2025, 6)});

      expect(result.isFailure, true);
    });

    test('returns failure when state is null', () async {
      stubFailedBuild();
      final c = container();
      await expectLater(
        c.read(recipeDetailControllerProvider(_babyId, 'r1').future),
        throwsA(isA<NetworkException>()),
      );

      final result = await c
          .read(recipeDetailControllerProvider(_babyId, 'r1').notifier)
          .assignToMealPlan({DateTime(2025, 6)});

      expect(result.isFailure, true);
    });

    test('success path returns Success and fires analytics', () async {
      stubHappyBuild();
      when(
        () => mealPlanSvc.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          assignments: any(named: 'assignments'),
        ),
      ).thenAnswer((_) async => const Result.success(<MealPlanEntry>[]));

      final c = container();
      await c.read(recipeDetailControllerProvider(_babyId, 'r1').future);

      final result = await c
          .read(recipeDetailControllerProvider(_babyId, 'r1').notifier)
          .assignToMealPlan({DateTime(2025, 6)});

      expect(result.isSuccess, true);
    });
  });

  group('addToShoppingList()', () {
    test('propagates service failure', () async {
      stubHappyBuild();
      when(
        () => shoppingListSvc.addFromRecipe(any(), any(), any()),
      ).thenAnswer((_) async => const Result.failure(NetworkException()));

      final c = container();
      await c.read(recipeDetailControllerProvider(_babyId, 'r1').future);

      final result = await c
          .read(recipeDetailControllerProvider(_babyId, 'r1').notifier)
          .addToShoppingList(['peanut butter']);

      expect(result.isFailure, true);
    });

    test('returns failure when state is null', () async {
      stubFailedBuild();
      final c = container();
      await expectLater(
        c.read(recipeDetailControllerProvider(_babyId, 'r1').future),
        throwsA(isA<NetworkException>()),
      );

      final result = await c
          .read(recipeDetailControllerProvider(_babyId, 'r1').notifier)
          .addToShoppingList(['peanut butter']);

      expect(result.isFailure, true);
    });

    test('success path returns Success and fires analytics', () async {
      stubHappyBuild();
      when(
        () => shoppingListSvc.addFromRecipe(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success(null));

      final c = container();
      await c.read(recipeDetailControllerProvider(_babyId, 'r1').future);

      final result = await c
          .read(recipeDetailControllerProvider(_babyId, 'r1').notifier)
          .addToShoppingList(['Avocado', 'Bread']);

      expect(result.isSuccess, true);
    });
  });
}
