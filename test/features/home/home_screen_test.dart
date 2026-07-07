// Widget tests for the redesigned Home dashboard screen.
//
// The redesign drives Home from two providers:
//   * `homeControllerProvider(babyId)` — the full `HomeState` (baby, meals,
//     allergen statuses, hero sub-state).
//   * `homeDayViewProvider(babyId)` — the pure per-selected-day slice
//     (meals + counters + guidance).
//
// Strategy (mirrors the controller-fake pattern used elsewhere in the repo):
//   * Override `currentBabyIdProvider` so `_HomeBody` resolves a baby id.
//   * Override `homeControllerProvider(babyId)` with a canned `HomeState`.
//   * Override `homeDayViewProvider(babyId)` with a canned `HomeDayView` so
//     the meals section is deterministic (no date/clock coupling).
//   * Override `selectedHomeDateProvider` where a test asserts selection.
//   * Stub destination routes with marker text so navigation is assertable.
//   * Neutralise Firebase analytics with a no-op platform.
//
// Five dashboard states (per the redesign contract):
//   1. empty            — mealPrepSetUp=false, heroState=start.
//   2. ongoing          — meal-prepped, allergen in-progress.
//   3. finishedStartNext— meal-prepped, finished allergen (inset start).
//   4. allDone          — all 11 introduced (no hero allergen widget).
//   5. noMealsToday     — meal-prepped, but the selected day has 0 meals.

// Firebase platform-interface packages are transitive deps; the public
// barrels do not re-export FirebaseAnalyticsPlatform / setupFirebaseCoreMocks.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/components/cards/recipe_plan_row.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/features/home/home_controller.dart';
import 'package:nibbles/src/features/home/home_day_view.dart';
import 'package:nibbles/src/features/home/home_screen.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:nibbles/src/features/home/widgets/home_empty_state_full.dart';
import 'package:nibbles/src/features/home/widgets/home_header.dart';
import 'package:nibbles/src/features/home/widgets/home_no_meals_state.dart';
import 'package:nibbles/src/features/home/widgets/ongoing_allergen_card.dart';
import 'package:nibbles/src/features/home/widgets/start_allergen_button.dart';
import 'package:nibbles/src/features/home/widgets/todays_meals_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

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

MealPlanEntry _meal(String id, String recipeId, {String? mealTime}) =>
    MealPlanEntry(
      id: id,
      babyId: _babyId,
      recipeId: recipeId,
      planDate: DateTime(2026, 3, 10),
      mealTime: mealTime,
    );

/// Allergen status map over all Big-11 keys — first [safe] keys safe, next
/// [flagged] flagged, next [inProgress] in-progress, remainder notStarted.
Map<String, AllergenStatus> _statuses({
  int safe = 0,
  int flagged = 0,
  int inProgress = 0,
}) {
  final out = <String, AllergenStatus>{
    for (final k in kAllergenKeys) k: AllergenStatus.notStarted,
  };
  var i = 0;
  void assign(AllergenStatus s, int count) {
    for (var n = 0; n < count; n++) {
      out[kAllergenKeys[i++]] = s;
    }
  }

  assign(AllergenStatus.safe, safe);
  assign(AllergenStatus.flagged, flagged);
  assign(AllergenStatus.inProgress, inProgress);
  return out;
}

/// 1. Empty — no meals, no allergen activity → hero shows the start CTA.
HomeState _emptyState() =>
    HomeState(baby: _fakeBaby, allergenStatuses: _statuses());

/// 2. Ongoing — meal-prepped, current allergen in-progress.
HomeState _ongoingState() => HomeState(
  baby: _fakeBaby,
  allMeals: [_meal('mp-1', 'recipe-aaa', mealTime: 'breakfast')],
  plannedDates: [DateTime(2026, 3, 10)],
  allergenStatuses: _statuses(inProgress: 1),
  currentAllergenKey: kAllergenKeys.first,
  currentAllergenStatus: AllergenStatus.inProgress,
  currentAllergenReactionFlags: List.filled(2, false),
);

/// 3. FinishedStartNext — meal-prepped, current allergen finished (safe).
HomeState _finishedState() => HomeState(
  baby: _fakeBaby,
  allMeals: [_meal('mp-1', 'recipe-aaa', mealTime: 'breakfast')],
  plannedDates: [DateTime(2026, 3, 10)],
  allergenStatuses: _statuses(safe: 1),
  currentAllergenKey: kAllergenKeys.first,
  currentAllergenStatus: AllergenStatus.safe,
  currentAllergenReactionFlags: List.filled(3, false),
);

/// 4. AllDone — every allergen introduced → no hero allergen widget.
HomeState _allDoneState() => HomeState(
  baby: _fakeBaby,
  allMeals: [_meal('mp-1', 'recipe-aaa', mealTime: 'breakfast')],
  plannedDates: [DateTime(2026, 3, 10)],
  allergenStatuses: _statuses(safe: kAllergenKeys.length),
);

/// 5. NoMealsToday — meal-prepped somewhere, selected day empty.
HomeState _mealPreppedState() => HomeState(
  baby: _fakeBaby,
  allMeals: [_meal('mp-1', 'recipe-aaa', mealTime: 'breakfast')],
  plannedDates: [DateTime(2026, 3, 10), DateTime(2026, 3, 12)],
  allergenStatuses: _statuses(inProgress: 1),
  currentAllergenKey: kAllergenKeys.first,
  currentAllergenStatus: AllergenStatus.inProgress,
  currentAllergenReactionFlags: List.filled(1, false),
);

HomeDayView _dayView({int mealCount = 0, List<MealPlanEntry>? meals}) =>
    HomeDayView(meals: meals ?? const [], mealCount: mealCount, isToday: true);

// ---------------------------------------------------------------------------
// Firebase no-op platform — drops every `Analytics.instance` call.
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Marker destination stubs.
// ---------------------------------------------------------------------------

const _allergenTrackerMarker = 'ALLERGEN_TRACKER_STUB';
const _allergenDetailMarker = 'ALLERGEN_DETAIL_STUB';
const _mealPlanMarker = 'MEAL_PLAN_STUB';
const _profileMarker = 'PROFILE_STUB';

GoRouter _testRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: AppRoute.allergenTracker.path,
      name: AppRoute.allergenTracker.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text(_allergenTrackerMarker))),
    ),
    GoRoute(
      path: AppRoute.allergenDetail.path,
      name: AppRoute.allergenDetail.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text(_allergenDetailMarker))),
    ),
    GoRoute(
      path: AppRoute.mealPlan.path,
      name: AppRoute.mealPlan.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text(_mealPlanMarker))),
    ),
    GoRoute(
      path: AppRoute.profile.path,
      name: AppRoute.profile.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text(_profileMarker))),
    ),
    GoRoute(
      path: AppRoute.recipeDetail.path,
      name: AppRoute.recipeDetail.name,
      builder: (_, state) => Scaffold(
        body: Center(
          child: Text('RECIPE_DETAIL_STUB:${state.pathParameters['recipeId']}'),
        ),
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Fake controllers
// ---------------------------------------------------------------------------

class _FakeHomeController extends HomeController {
  _FakeHomeController(this._state);

  final HomeState _state;

  @override
  Future<HomeState> build(String babyId) async => _state;
}

class _ThrowingHomeController extends HomeController {
  _ThrowingHomeController(this._onBuild);

  final void Function() _onBuild;

  @override
  Future<HomeState> build(String babyId) async {
    _onBuild();
    throw Exception('boom');
  }
}

// ---------------------------------------------------------------------------
// Overrides + pump helpers
// ---------------------------------------------------------------------------

List<Override> _overrides({
  String? babyId = _babyId,
  HomeState? state,
  HomeDayView? dayView,
  DateTime? selectedDate,
  HomeController Function()? controllerFactory,
}) {
  final ovs = <Override>[
    currentBabyIdProvider.overrideWith((ref) async => babyId),
  ];
  if (babyId != null) {
    ovs
      ..add(
        homeControllerProvider(babyId).overrideWith(
          controllerFactory ??
              () => _FakeHomeController(state ?? _emptyState()),
        ),
      )
      ..add(
        homeDayViewProvider(babyId).overrideWithValue(dayView ?? _dayView()),
      );
    if (selectedDate != null) {
      ovs.add(selectedHomeDateProvider.overrideWith((ref) => selectedDate));
    }
  }
  return ovs;
}

ProviderContainer _container(List<Override> overrides) {
  final c = ProviderContainer(overrides: overrides);
  addTearDown(c.dispose);
  return c;
}

void _bigViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pump(
  WidgetTester tester, {
  required List<Override> overrides,
  GoRouter? router,
}) async {
  _bigViewport(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(routerConfig: router ?? _testRouter()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpContainer(
  WidgetTester tester, {
  required ProviderContainer container,
  GoRouter? router,
}) async {
  _bigViewport(tester);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router ?? _testRouter()),
    ),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  group('HomeScreen — 1. empty state (mealPrepSetUp=false, hero=start)', () {
    testWidgets(
      'renders StartAllergenButton + ReadyToStartCard, no WeekStrip, 0/2 + 0/11',
      (tester) async {
        await _pump(tester, overrides: _overrides(state: _emptyState()));

        expect(find.byType(HomeHeader), findsOneWidget);
        expect(find.byType(StartAllergenButton), findsOneWidget);
        expect(find.byType(ReadyToStartCard), findsOneWidget);
        // No date strip until the baby has any planned meal.
        expect(find.byType(WeekStrip), findsNothing);
        // Rings: today's meals 0/2, allergen 0/11.
        expect(find.text('/2'), findsOneWidget);
        expect(find.text('/11'), findsOneWidget);
        // No populated meals section.
        expect(find.byType(TodaysMealsCard), findsNothing);
        expect(find.byType(OngoingAllergenCard), findsNothing);
      },
    );
  });

  group('HomeScreen — 2. meal-prepped + allergen ongoing', () {
    testWidgets(
      'renders WeekStrip + OngoingAllergenCard (no inset) + TodaysMealsCard',
      (tester) async {
        await _pump(
          tester,
          overrides: _overrides(
            state: _ongoingState(),
            dayView: _dayView(
              mealCount: 1,
              meals: [_meal('mp-1', 'recipe-aaa', mealTime: 'breakfast')],
            ),
          ),
        );

        expect(find.byType(WeekStrip), findsOneWidget);
        expect(find.byType(OngoingAllergenCard), findsOneWidget);
        expect(find.byType(TodaysMealsCard), findsOneWidget);
        expect(find.byType(ReadyToStartCard), findsNothing);
        // Ongoing (not finished) -> no inset start button anywhere.
        expect(find.byType(StartAllergenButton), findsNothing);
        // Under target -> Add pill shows.
        expect(find.text('Add'), findsOneWidget);
      },
    );

    testWidgets('mealCount >= target -> Add pill absent, no banner', (
      tester,
    ) async {
      await _pump(
        tester,
        overrides: _overrides(
          state: _ongoingState(),
          dayView: _dayView(
            mealCount: 2,
            meals: [
              _meal('mp-1', 'recipe-aaa', mealTime: 'breakfast'),
              _meal('mp-2', 'recipe-bbb', mealTime: 'lunch'),
            ],
          ),
        ),
      );

      expect(find.text('Add'), findsNothing);
      expect(
        find.text('Great job! Everything important is covered'),
        findsNothing,
      );
    });
  });

  group('HomeScreen — 3. finishedStartNext', () {
    testWidgets('OngoingAllergenCard renders with an inset start button', (
      tester,
    ) async {
      await _pump(
        tester,
        overrides: _overrides(
          state: _finishedState(),
          dayView: _dayView(
            mealCount: 1,
            meals: [_meal('mp-1', 'recipe-aaa', mealTime: 'breakfast')],
          ),
        ),
      );

      expect(find.byType(OngoingAllergenCard), findsOneWidget);
      // finished-start-next surfaces the inset "Start New Allergen" CTA.
      expect(find.byType(StartAllergenButton), findsOneWidget);
    });
  });

  group('HomeScreen — 4. allDone', () {
    testWidgets('no start button and no ongoing card in the hero', (
      tester,
    ) async {
      await _pump(
        tester,
        overrides: _overrides(
          state: _allDoneState(),
          dayView: _dayView(
            mealCount: 1,
            meals: [_meal('mp-1', 'recipe-aaa', mealTime: 'breakfast')],
          ),
        ),
      );

      expect(find.byType(StartAllergenButton), findsNothing);
      expect(find.byType(OngoingAllergenCard), findsNothing);
    });
  });

  group('HomeScreen — 5. meal-prepped day with 0 meals', () {
    testWidgets('renders HomeNoMealsState instead of TodaysMealsCard', (
      tester,
    ) async {
      await _pump(
        tester,
        overrides: _overrides(state: _mealPreppedState(), dayView: _dayView()),
      );

      expect(find.byType(HomeNoMealsState), findsOneWidget);
      expect(find.byType(TodaysMealsCard), findsNothing);
      // Still meal-prepped, so the date strip is present.
      expect(find.byType(WeekStrip), findsOneWidget);
    });
  });

  group('HomeScreen — date selection', () {
    testWidgets('tapping the Today pill resets selection to today', (
      tester,
    ) async {
      final container = _container(
        _overrides(
          state: _mealPreppedState(),
          dayView: _dayView(),
          selectedDate: DateTime(2020),
        ),
      );
      await _pumpContainer(tester, container: container);

      // Pre-condition: selection is the overridden past date.
      expect(container.read(selectedHomeDateProvider), DateTime(2020));

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(
        container.read(selectedHomeDateProvider),
        homeDateOnly(DateTime.now()),
      );
    });

    testWidgets('tapping a day chip selects that planned date', (tester) async {
      final container = _container(
        _overrides(
          state: _mealPreppedState(),
          dayView: _dayView(),
          selectedDate: DateTime(2026, 3, 12),
        ),
      );
      await _pumpContainer(tester, container: container);

      // First chip -> plannedDates[0] == 2026-03-10.
      await tester.tap(find.byType(DayChip).first);
      await tester.pumpAndSettle();

      expect(container.read(selectedHomeDateProvider), DateTime(2026, 3, 10));
    });
  });

  group('HomeScreen — no baby', () {
    testWidgets('null babyId -> HomeEmptyStateFull', (tester) async {
      await _pump(tester, overrides: _overrides(babyId: null));

      expect(find.byType(HomeEmptyStateFull), findsOneWidget);
      expect(find.byType(HomeHeader), findsNothing);
    });

    testWidgets('empty-state CTA routes to the meal plan tab', (tester) async {
      await _pump(tester, overrides: _overrides(babyId: null));

      await tester.tap(find.text('Create First Meal'));
      await tester.pumpAndSettle();

      expect(find.text(_mealPlanMarker), findsOneWidget);
    });
  });

  group('HomeScreen — navigation', () {
    testWidgets('meal row tap routes to recipe detail', (tester) async {
      await _pump(
        tester,
        overrides: _overrides(
          state: _ongoingState(),
          dayView: _dayView(
            mealCount: 1,
            meals: [_meal('mp-1', 'recipe-aaa', mealTime: 'breakfast')],
          ),
        ),
      );

      await tester.tap(find.byType(RecipePlanRow));
      await tester.pumpAndSettle();

      expect(find.text('RECIPE_DETAIL_STUB:recipe-aaa'), findsOneWidget);
    });

    testWidgets('ReadyToStart CTA (empty state) routes to the meal plan tab', (
      tester,
    ) async {
      await _pump(tester, overrides: _overrides(state: _emptyState()));

      await tester.tap(find.text('Create First Meal'));
      await tester.pumpAndSettle();

      expect(find.text(_mealPlanMarker), findsOneWidget);
    });
  });

  group('HomeScreen — error and retry', () {
    testWidgets('controller throws -> error scaffold with Try Again', (
      tester,
    ) async {
      var buildCount = 0;
      await _pump(
        tester,
        overrides: _overrides(
          controllerFactory: () => _ThrowingHomeController(() => buildCount++),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(buildCount, 1);
    });

    testWidgets('tap Try Again re-runs the controller build', (tester) async {
      var buildCount = 0;
      await _pump(
        tester,
        overrides: _overrides(
          controllerFactory: () => _ThrowingHomeController(() => buildCount++),
        ),
      );

      expect(buildCount, 1);
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(buildCount, 2);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
