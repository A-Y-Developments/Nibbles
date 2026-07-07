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
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_screen.dart';
import 'package:nibbles/src/features/meal_plan/sheets/select_period_date_sheet.dart';
import 'package:nibbles/src/features/meal_plan/widgets/add_date_pill.dart';
import 'package:nibbles/src/features/meal_plan/widgets/day_accordion_card.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_empty_state.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_header.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

import '../../support/fake_analytics.dart';

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockMealPlanService extends Mock implements MealPlanService {}

class _MockRecipeService extends Mock implements RecipeService {}

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

const _peanutAllergen = Allergen(
  key: 'peanut',
  name: 'Peanut',
  sequenceOrder: 1,
  emoji: '🥜',
);

const _fakeRecipe = Recipe(
  id: 'recipe-001',
  title: 'Peanut Butter Toast',
  ageRange: '6m+',
  allergenTags: ['peanut'],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

MealPlan _planFrom(DateTime start, {int days = 7}) => MealPlan(
  id: 'plan-1',
  babyId: _babyId,
  startDate: start,
  endDate: start.add(Duration(days: days - 1)),
  createdAt: start,
);

AllergenProgramState _makeProgramState({
  AllergenProgramStatus status = AllergenProgramStatus.inProgress,
}) {
  final now = DateTime(2026, 5, 30);
  return AllergenProgramState(
    id: 'ps-1',
    babyId: _babyId,
    currentAllergenKey: 'peanut',
    currentSequenceOrder: 1,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

MealPlanEntry _entry(DateTime planDate, {String id = 'mp-1'}) => MealPlanEntry(
  id: id,
  babyId: _babyId,
  recipeId: 'recipe-001',
  planDate: planDate,
);

GoRouter _testRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const MealPlanScreen()),
    GoRoute(
      path: AppRoute.mealPlanMap.path,
      name: AppRoute.mealPlanMap.name,
      builder: (_, __) => const Scaffold(body: Text('Map Stub')),
    ),
    GoRoute(
      path: AppRoute.recipeDetail.path,
      name: AppRoute.recipeDetail.name,
      builder: (_, __) => const Scaffold(body: Text('Recipe Detail Stub')),
    ),
  ],
);

void main() {
  late _MockBabyProfileService mockBabyService;
  late _MockMealPlanService mockMealPlanService;
  late _MockRecipeService mockRecipeService;
  late _MockAllergenService mockAllergenService;
  late FakeAnalytics fakeAnalytics;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockBabyService = _MockBabyProfileService();
    mockMealPlanService = _MockMealPlanService();
    mockRecipeService = _MockRecipeService();
    mockAllergenService = _MockAllergenService();
    fakeAnalytics = FakeAnalytics();
  });

  void stubBoot({
    MealPlan? plan,
    List<MealPlanEntry> entries = const [],
    AllergenProgramState? programState,
  }) {
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(
      () => mockMealPlanService.getActivePlan(any()),
    ).thenAnswer((_) async => Result.success(plan));
    when(
      () => mockMealPlanService.getEntriesForPlan(any()),
    ).thenAnswer((_) async => Result.success(entries));
    when(
      () => mockRecipeService.getFlaggedAllergenKeys(any()),
    ).thenAnswer((_) async => const Result.success(<String>{}));
    when(() => mockAllergenService.getProgramState(any())).thenAnswer(
      (_) async => Result.success(programState ?? _makeProgramState()),
    );
    when(() => mockAllergenService.getAllergenBoardSummary(any())).thenAnswer(
      (_) async => const Result.success(<AllergenBoardItem>[
        AllergenBoardItem(
          allergen: _peanutAllergen,
          logs: [],
          status: AllergenStatus.inProgress,
        ),
      ]),
    );
    when(
      () => mockRecipeService.getRecipeById(any()),
    ).thenAnswer((_) async => const Result.success(_fakeRecipe));
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          babyProfileServiceProvider.overrideWithValue(mockBabyService),
          mealPlanServiceProvider.overrideWithValue(mockMealPlanService),
          recipeServiceProvider.overrideWithValue(mockRecipeService),
          allergenServiceProvider.overrideWithValue(mockAllergenService),
          analyticsProvider.overrideWithValue(fakeAnalytics),
        ],
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('MealPlanScreen empty branch', () {
    testWidgets(
      'no active plan → MealPlanEmptyState + header (no day-count line) + no '
      'DayAccordionCards + no overflow button',
      (tester) async {
        stubBoot();
        await pumpScreen(tester);

        expect(find.byType(MealPlanEmptyState), findsOneWidget);
        expect(find.byType(DayAccordionCard), findsNothing);
        expect(find.byType(MealPlanHeader), findsOneWidget);
        expect(find.textContaining('Meal plan for'), findsNothing);
        // Overflow is hidden on the empty state.
        expect(find.byType(MealPlanOverflowButton), findsNothing);
        // Both meal-prep CTAs are present (disabled until a range is chosen).
        expect(find.text('Set a Meal Prep'), findsOneWidget);
        expect(find.text('Fill in myself'), findsOneWidget);
      },
    );
  });

  group('MealPlanScreen populated branch', () {
    testWidgets('active plan → MealPlanHeader + 7 DayAccordionCards + '
        'AddDatePill', (tester) async {
      final today = _today();
      stubBoot(plan: _planFrom(today), entries: [_entry(today)]);
      await pumpScreen(tester);

      expect(find.byType(MealPlanHeader), findsOneWidget);
      expect(find.byType(DayAccordionCard), findsNWidgets(7));
      expect(find.byType(AddDatePill), findsOneWidget);
      expect(find.byType(MealPlanEmptyState), findsNothing);
    });
  });

  group('MealPlanScreen overflow menu', () {
    testWidgets('shows exactly 3 items in the screen-level menu', (
      tester,
    ) async {
      final today = _today();
      stubBoot(plan: _planFrom(today), entries: [_entry(today)]);
      await pumpScreen(tester);

      await tester.tap(find.byType(MealPlanOverflowButton));
      await tester.pumpAndSettle();

      expect(find.text('Add to shop list'), findsOneWidget);
      expect(find.text('Create new meal prep'), findsOneWidget);
      expect(find.text('Clear current plan'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is PopupMenuItem),
        findsNWidgets(3),
      );
    });

    testWidgets('Create new meal prep opens SelectPeriodDateSheet', (
      tester,
    ) async {
      final today = _today();
      stubBoot(plan: _planFrom(today), entries: [_entry(today)]);
      await pumpScreen(tester);

      await tester.tap(find.byType(MealPlanOverflowButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create new meal prep'));
      await tester.pumpAndSettle();

      expect(find.byType(SelectPeriodDateSheet), findsOneWidget);
      expect(find.text('Select Period Date'), findsOneWidget);
    });

    testWidgets('per-card overflow menu shows exactly 2 items', (tester) async {
      final today = _today();
      stubBoot(plan: _planFrom(today), entries: [_entry(today)]);
      await pumpScreen(tester);

      final cardKebab = find
          .descendant(
            of: find.byType(DayAccordionCard).first,
            matching: find.byIcon(Icons.more_horiz),
          )
          .first;
      await tester.tap(cardKebab);
      await tester.pumpAndSettle();

      expect(find.text('Add to shop list'), findsOneWidget);
      expect(find.text('Clear current date'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is PopupMenuItem),
        findsNWidgets(2),
      );
    });
  });

  group('MealPlanScreen single-day Add flow', () {
    testWidgets('day-card Add pill → BrowseMealSheet returns [recipe] → '
        'appendMealsToRange called with startDate == endDate + plan id', (
      tester,
    ) async {
      final today = _today();
      stubBoot(plan: _planFrom(today), entries: [_entry(today)]);
      const sheetRecipe = Recipe(
        id: 'recipe-sheet',
        title: 'Avocado Mash',
        ageRange: '6m+',
        allergenTags: [],
        ingredients: [],
        steps: [],
        howToServe: 'Serve.',
      );
      when(
        () => mockRecipeService.getAllRecipes(any()),
      ).thenAnswer((_) async => const Result.success([sheetRecipe]));
      when(() => mockAllergenService.getAllergenStatuses(any())).thenAnswer(
        (_) async => const Result.success({
          'peanut': AllergenStatus.safe,
          'egg': AllergenStatus.safe,
          'dairy': AllergenStatus.safe,
          'tree_nuts': AllergenStatus.safe,
          'sesame': AllergenStatus.safe,
          'soy': AllergenStatus.safe,
          'wheat': AllergenStatus.safe,
          'fish': AllergenStatus.safe,
          'shellfish': AllergenStatus.safe,
        }),
      );
      when(
        () => mockMealPlanService.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          assignments: any(named: 'assignments'),
          mealPlanId: any(named: 'mealPlanId'),
        ),
      ).thenAnswer((_) async => const Result.success(<MealPlanEntry>[]));

      await pumpScreen(tester);

      // Day cards default to expanded, so the "Add" pill is already visible.
      final firstCard = find.byType(DayAccordionCard).first;
      final addPill = find
          .descendant(of: firstCard, matching: find.text('Add'))
          .first;
      await tester.tap(addPill);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      await tester.pump();

      // Select the recipe in the master list.
      await tester.tap(find.text(sheetRecipe.title).first);
      await tester.pump();

      // Single-date entry commits directly via "Add" — no review sheet.
      expect(find.text('Map Meals'), findsNothing);
      await tester.tap(find.text('Add').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      final captured = verify(
        () => mockMealPlanService.appendMealsToRange(
          babyId: _babyId,
          startDate: captureAny(named: 'startDate'),
          endDate: captureAny(named: 'endDate'),
          assignments: captureAny(named: 'assignments'),
          mealPlanId: 'plan-1',
        ),
      ).captured;
      expect(captured, hasLength(3));
      final startDate = captured[0] as DateTime;
      final endDate = captured[1] as DateTime;
      expect(startDate, endDate, reason: 'single-day range');
      expect(startDate, today);
      final assignments = captured[2] as List<dynamic>;
      expect(assignments, hasLength(1));
    });
  });

  group('MealPlanScreen delete-plan flow', () {
    testWidgets(
      'Clear current plan → Yes in confirm sheet → deletePlan on the service',
      (tester) async {
        final today = _today();
        stubBoot(plan: _planFrom(today), entries: [_entry(today)]);
        when(
          () => mockMealPlanService.deletePlan(any()),
        ).thenAnswer((_) async => const Result.success(null));

        await pumpScreen(tester);

        await tester.tap(find.byType(MealPlanOverflowButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear current plan'));
        await tester.pumpAndSettle();

        expect(find.text('Are you sure you want to delete?'), findsOneWidget);

        await tester.tap(find.text('Yes'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(() => mockMealPlanService.deletePlan('plan-1')).called(1);
      },
    );

    testWidgets('No in the confirm sheet leaves deletePlan uncalled', (
      tester,
    ) async {
      final today = _today();
      stubBoot(plan: _planFrom(today), entries: [_entry(today)]);

      await pumpScreen(tester);

      await tester.tap(find.byType(MealPlanOverflowButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear current plan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      verifyNever(() => mockMealPlanService.deletePlan(any()));
    });
  });
}
