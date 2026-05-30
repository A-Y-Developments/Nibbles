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
import 'package:nibbles/src/features/meal_plan/meal_plan_screen.dart';
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
    List<MealPlanEntry> entries = const [],
    AllergenProgramState? programState,
  }) {
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(
      () => mockMealPlanService.getRolling7(
        any(),
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => Result.success(entries));
    when(
      () => mockRecipeService.getFlaggedAllergenKeys(any()),
    ).thenAnswer((_) async => const Result.success(<String>{}));
    when(
      () => mockAllergenService.getProgramState(any()),
    ).thenAnswer(
      (_) async => Result.success(programState ?? _makeProgramState()),
    );
    when(
      () => mockAllergenService.getAllergenBoardSummary(any()),
    ).thenAnswer(
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
    testWidgets('renders MealPlanEmptyState when entries is empty',
        (tester) async {
      stubBoot();
      await pumpScreen(tester);

      expect(find.byType(MealPlanEmptyState), findsOneWidget);
      expect(find.byType(DayAccordionCard), findsNothing);
      expect(find.byType(MealPlanHeader), findsNothing);
    });
  });

  group('MealPlanScreen populated branch', () {
    testWidgets(
      'renders MealPlanHeader + 7 DayAccordionCards + AddDatePill',
      (tester) async {
        final start = DateTime.now();
        final today = DateTime(start.year, start.month, start.day);
        stubBoot(entries: [_entry(today)]);
        await pumpScreen(tester);

        expect(find.byType(MealPlanHeader), findsOneWidget);
        // Rolling-7 window.
        expect(find.byType(DayAccordionCard), findsNWidgets(7));
        expect(find.byType(AddDatePill), findsOneWidget);
        expect(find.byType(MealPlanEmptyState), findsNothing);
      },
    );
  });

  group('MealPlanScreen overflow menu', () {
    testWidgets('shows exactly 3 items in the screen-level menu',
        (tester) async {
      final start = DateTime.now();
      final today = DateTime(start.year, start.month, start.day);
      stubBoot(entries: [_entry(today)]);
      await pumpScreen(tester);

      await tester.tap(find.byType(MealPlanOverflowButton));
      await tester.pumpAndSettle();

      expect(find.text('Add to shop list'), findsOneWidget);
      expect(find.text('Create new meal prep'), findsOneWidget);
      expect(find.text('Clear current week'), findsOneWidget);
      // PopupMenuItem<_ScreenMenuAction> is private — match by superclass.
      expect(
        find.byWidgetPredicate((w) => w is PopupMenuItem),
        findsNWidgets(3),
      );
    });

    testWidgets('per-card overflow menu shows exactly 2 items', (tester) async {
      final start = DateTime.now();
      final today = DateTime(start.year, start.month, start.day);
      stubBoot(entries: [_entry(today)]);
      await pumpScreen(tester);

      // Tap the kebab INSIDE the first DayAccordionCard (avoid the
      // header-level MealPlanOverflowButton which renders the same icon).
      final cardKebab = find
          .descendant(
            of: find.byType(DayAccordionCard).first,
            matching: find.byIcon(Icons.more_horiz),
          )
          .first;
      await tester.tap(cardKebab);
      await tester.pumpAndSettle();

      expect(find.text('Add to shop list'), findsOneWidget);
      expect(find.text('Clear current week'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is PopupMenuItem),
        findsNWidgets(2),
      );
    });
  });

  group('MealPlanScreen single-day Add flow', () {
    testWidgets(
      'tapping a day-card + Add pill → BrowseMealSheet returns [recipe] → '
      'appendMealsToRange called with startDate == endDate for that day',
      (tester) async {
        final start = DateTime.now();
        final today = DateTime(start.year, start.month, start.day);
        stubBoot(entries: [_entry(today)]);
        // BrowseMealSheet needs these to load + render. Use a distinct
        // sheet recipe so the master-list row tap doesn't collide with the
        // expanded day-card row that renders `_fakeRecipe.title`.
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
        when(
          () => mockAllergenService.getAllergenStatuses(any()),
        ).thenAnswer(
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
          ),
        ).thenAnswer((_) async => const Result.success(<MealPlanEntry>[]));

        await pumpScreen(tester);

        // Expand the first day card so its '+ Add' pill is visible.
        final firstCard = find.byType(DayAccordionCard).first;
        final chevron = find
            .descendant(of: firstCard, matching: find.byIcon(Icons.expand_more))
            .first;
        await tester.tap(chevron);
        await tester.pumpAndSettle();

        // Tap the '+ Add' pill inside the expanded card.
        final addPill = find
            .descendant(of: firstCard, matching: find.text('+ Add'))
            .first;
        await tester.tap(addPill);
        // Drive the sheet entrance + _load() — pumpAndSettle would hang on
        // the CircularProgressIndicator the sheet shows while loading.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump();
        await tester.pump();

        // Pick the recipe in the sheet's master list.
        await tester.tap(find.text(sheetRecipe.title).first);
        await tester.pump();

        // Confirm the picked count + tap the sticky CTA to pop with the list.
        expect(find.text('Add (1)'), findsOneWidget);
        await tester.tap(find.text('Add (1)'));
        // Drive the sheet dismissal + appendBulkPrep future.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        final captured = verify(
          () => mockMealPlanService.appendMealsToRange(
            babyId: _babyId,
            startDate: captureAny(named: 'startDate'),
            endDate: captureAny(named: 'endDate'),
            assignments: captureAny(named: 'assignments'),
          ),
        ).captured;
        expect(captured, hasLength(3));
        final startDate = captured[0] as DateTime;
        final endDate = captured[1] as DateTime;
        expect(startDate, endDate, reason: 'single-day range');
        expect(startDate, today);
        final assignments = captured[2] as List<dynamic>;
        expect(assignments, hasLength(1));
      },
    );
  });

  group('MealPlanScreen clear-week flow', () {
    testWidgets(
      'tapping Delete in the real confirm dialog calls clearRange on the '
      'service',
      (tester) async {
        final start = DateTime.now();
        final today = DateTime(start.year, start.month, start.day);
        stubBoot(entries: [_entry(today)]);
        when(
          () => mockMealPlanService.clearRange(any(), any(), any()),
        ).thenAnswer((_) async => const Result.success(null));

        await pumpScreen(tester);

        // Open the screen-level menu, pick Clear current week.
        await tester.tap(find.byType(MealPlanOverflowButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear current week'));
        await tester.pumpAndSettle();

        // Real confirm dialog rendered.
        expect(find.text('Are you sure you want to delete?'), findsOneWidget);

        await tester.tap(find.text('Delete'));
        // clearRange triggers ref.invalidateSelf → re-fetches getRolling7.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(
          () => mockMealPlanService.clearRange(_babyId, any(), any()),
        ).called(1);
      },
    );

    testWidgets(
      'tapping Cancel in the confirm dialog leaves clearRange unmocked-called',
      (tester) async {
        final start = DateTime.now();
        final today = DateTime(start.year, start.month, start.day);
        stubBoot(entries: [_entry(today)]);

        await pumpScreen(tester);

        await tester.tap(find.byType(MealPlanOverflowButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear current week'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        verifyNever(
          () => mockMealPlanService.clearRange(any(), any(), any()),
        );
      },
    );
  });
}
