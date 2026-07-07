// Widget tests for the plan-aware, two-step Add-to-Meal-Plan bottom sheet
// (Figma 971:8053 "Select Period Date" + 971:9467 "Meal Plan").
//
// Drives `showAddToMealPlanSheet(context, babyId: ..., recipe: ...)` and
// asserts:
//   * "Select Period Date" is shown when the baby has no active plan
//   * that step is SKIPPED (straight to "Meal Plan") when a plan exists
//   * tapping a day's "Add" pill stacks duplicate pending rows for the same
//     recipe, WITHOUT an "Added" toggle label anywhere
//   * the bottom CTA is disabled at zero picks
//   * confirming calls through to `appendBulkPrep` -> `appendMealsToRange`
//     and pops the sheet with `true` on success
//
// Firebase platform-interface packages are transitive deps; the public
// barrels don't re-export the test helpers used here.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/feedback/app_toast.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_meal_plan_sheet.dart';

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

class _MockMealPlanService extends Mock implements MealPlanService {}

class _MockRecipeService extends Mock implements RecipeService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockAllergenService extends Mock implements AllergenService {}

const _babyId = 'baby-001';

final _fakeBaby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

const _recipe = Recipe(
  id: 'recipe-001',
  title: 'Mashed Avocado',
  ageRange: '6+ months',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

final _defaultPlan = MealPlan(
  id: 'plan-1',
  babyId: _babyId,
  startDate: DateTime(2026, 5, 30),
  endDate: DateTime(2026, 6),
  createdAt: DateTime(2026, 5, 29),
);

AllergenProgramState _makeProgramState() => AllergenProgramState(
  id: 'ps-1',
  babyId: _babyId,
  currentAllergenKey: 'peanut',
  currentSequenceOrder: 1,
  status: AllergenProgramStatus.inProgress,
  createdAt: DateTime(2026, 5, 30),
  updatedAt: DateTime(2026, 5, 30),
);

Future<void> _setUpViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  late _MockMealPlanService mealPlanSvc;
  late _MockRecipeService recipeSvc;
  late _MockBabyProfileService babySvc;
  late _MockAllergenService allergenSvc;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(const <RecipeAssignment>[]);
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  setUp(() {
    mealPlanSvc = _MockMealPlanService();
    recipeSvc = _MockRecipeService();
    babySvc = _MockBabyProfileService();
    allergenSvc = _MockAllergenService();
  });

  void stubCommon() {
    when(() => babySvc.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(
      () => recipeSvc.getFlaggedAllergenKeys(any()),
    ).thenAnswer((_) async => const Result.success(<String>{}));
    when(
      () => allergenSvc.getProgramState(any()),
    ).thenAnswer((_) async => Result.success(_makeProgramState()));
    when(
      () => allergenSvc.getAllergenBoardSummary(any()),
    ).thenAnswer((_) async => const Result.success(<AllergenBoardItem>[]));
  }

  void stubNoPlan() {
    stubCommon();
    when(
      () => mealPlanSvc.getActivePlan(any()),
    ).thenAnswer((_) async => const Result.success(null));
  }

  void stubWithPlan({List<MealPlanEntry> entries = const []}) {
    stubCommon();
    when(
      () => mealPlanSvc.getActivePlan(any()),
    ).thenAnswer((_) async => Result.success(_defaultPlan));
    when(
      () => mealPlanSvc.getEntriesForPlan(any()),
    ).thenAnswer((_) async => Result.success(entries));
    when(
      () => recipeSvc.getRecipeById(any()),
    ).thenAnswer((_) async => const Result.success(_recipe));
  }

  /// Opens the sheet and returns its pending result Future.
  Future<Future<bool?>> openSheet(WidgetTester tester) async {
    late Future<bool?> pending;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealPlanServiceProvider.overrideWithValue(mealPlanSvc),
          recipeServiceProvider.overrideWithValue(recipeSvc),
          babyProfileServiceProvider.overrideWithValue(babySvc),
          allergenServiceProvider.overrideWithValue(allergenSvc),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    pending = showAddToMealPlanSheet(
                      context,
                      babyId: _babyId,
                      recipe: _recipe,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
    return pending;
  }

  group('AddToMealPlanSheet — Select Period Date step', () {
    testWidgets(
      'shown with a disabled Continue CTA when the baby has no active plan',
      (tester) async {
        await _setUpViewport(tester);
        stubNoPlan();
        await openSheet(tester);

        expect(find.text('Select Period Date'), findsOneWidget);
        expect(find.text('Meal Plan'), findsNothing);

        final continueCta = tester.widget<AppPillButton>(
          find.widgetWithText(AppPillButton, 'Continue'),
        );
        expect(continueCta.onPressed, isNull);
      },
    );

    testWidgets('is SKIPPED, going straight to Meal Plan, when a plan exists', (
      tester,
    ) async {
      await _setUpViewport(tester);
      stubWithPlan();
      await openSheet(tester);

      expect(find.text('Meal Plan'), findsOneWidget);
      expect(find.text('Select Period Date'), findsNothing);
    });
  });

  group('AddToMealPlanSheet — Meal Plan step: Add stacking', () {
    testWidgets(
      'tapping Add on the same day stacks duplicate rows, no "Added" toggle',
      (tester) async {
        await _setUpViewport(tester);
        stubWithPlan();
        await openSheet(tester);

        expect(find.text(_recipe.title), findsNothing);

        final addPill = find.widgetWithText(AppPillButton, 'Add').first;
        await tester.ensureVisible(addPill);
        await tester.tap(addPill);
        await tester.pumpAndSettle(const Duration(milliseconds: 220));
        expect(find.text(_recipe.title), findsOneWidget);
        expect(find.text('Added'), findsNothing);

        await tester.ensureVisible(addPill);
        await tester.tap(addPill);
        await tester.pumpAndSettle(const Duration(milliseconds: 220));
        expect(find.text(_recipe.title), findsNWidgets(2));
        expect(find.text('Added'), findsNothing);
        // Still labelled "Add" (never toggles) even after picking twice.
        expect(find.widgetWithText(AppPillButton, 'Add'), findsWidgets);
      },
    );
  });

  group('AddToMealPlanSheet — Meal Plan step: bottom CTA', () {
    testWidgets('disabled with "Add to Meal Plan" label at zero picks', (
      tester,
    ) async {
      await _setUpViewport(tester);
      stubWithPlan();
      await openSheet(tester);

      final cta = tester.widget<AppPillButton>(
        find.widgetWithText(AppPillButton, 'Add to Meal Plan'),
      );
      expect(cta.onPressed, isNull);
    });

    testWidgets(
      'saving calls appendMealsToRange with the picked assignment and pops '
      'true on success',
      (tester) async {
        await _setUpViewport(tester);
        stubWithPlan();
        when(
          () => mealPlanSvc.appendMealsToRange(
            babyId: any(named: 'babyId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            assignments: any(named: 'assignments'),
            mealPlanId: any(named: 'mealPlanId'),
          ),
        ).thenAnswer((_) async => const Result.success(<MealPlanEntry>[]));

        final pending = await openSheet(tester);

        await tester.tap(find.widgetWithText(AppPillButton, 'Add').first);
        await tester.pump();

        expect(find.text('1 Day Selected'), findsOneWidget);
        await tester.tap(find.widgetWithText(AppPillButton, '1 Day Selected'));
        await tester.pumpAndSettle(const Duration(milliseconds: 350));

        final saved = await pending;
        expect(saved, isTrue);

        final captured = verify(
          () => mealPlanSvc.appendMealsToRange(
            babyId: _babyId,
            startDate: DateTime(2026, 5, 30),
            endDate: DateTime(2026, 6),
            assignments: captureAny(named: 'assignments'),
            mealPlanId: 'plan-1',
          ),
        ).captured;

        final assignments = captured.single as List<RecipeAssignment>;
        expect(assignments, hasLength(1));
        expect(assignments.single.recipeId, _recipe.id);
        expect(assignments.single.dayOffset, 0);
      },
    );

    testWidgets('keeps the sheet open and shows a snackbar when saving fails', (
      tester,
    ) async {
      await _setUpViewport(tester);
      stubWithPlan();
      when(
        () => mealPlanSvc.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          assignments: any(named: 'assignments'),
          mealPlanId: any(named: 'mealPlanId'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(ServerException('append failed')),
      );

      await openSheet(tester);

      await tester.tap(find.widgetWithText(AppPillButton, 'Add').first);
      await tester.pump();
      await tester.tap(find.widgetWithText(AppPillButton, '1 Day Selected'));
      await tester.pumpAndSettle(const Duration(milliseconds: 350));

      expect(
        find.text("Couldn't add to meal plan. Try again."),
        findsOneWidget,
      );
      // The sheet stays mounted so the user can retry.
      expect(find.text('Meal Plan'), findsOneWidget);

      // Flush the toast's auto-close Timer so it doesn't leak past teardown.
      await tester.pump(kAppToastDuration + const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 700));
    });
  });
}
