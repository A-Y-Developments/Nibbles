// Widget tests for the redesigned Home dashboard screen.
//
// NIB-111: net-new coverage for the four dashboard states (populated,
// empty-full, empty-short-equivalent, no-meals), navigation tap routing
// (ongoing card -> allergen tracker, meal row -> recipe detail, empty-state
// CTA -> meal plan tab), and the error/retry path.
//
// Strategy:
//   * Override `homeControllerProvider(babyId)` with a canned `HomeState`
//     (mirrors `recipe_library_screen_test.dart`'s controller-fake pattern)
//     and override `currentBabyIdProvider` so `_HomeBody` resolves to the
//     same id.
//   * Stub destination routes with identifiable text so navigation taps can
//     be asserted by routed marker text (no NavigatorObserver needed).
//   * Neutralise Firebase + analytics via `setupFirebaseCoreMocks()` +
//     a no-op `FirebaseAnalyticsPlatform` so the production code paths
//     that hit `Analytics.instance` directly do not throw.
//
// Branching notes (intentionally do NOT modify lib/**):
//   * `HomeScreen` has only two empty-state code paths today — both render
//     `HomeEmptyStateFull`. The "no baby" path and the "baby exists but no
//     activity" (`HomeState.hasNoActivity`) path are covered; a distinct
//     `HomeEmptyStateShort` branch is not surfaced by the screen.
//   * `HomeNoMealsState` is likewise not wired by the screen — empty
//     `todaysMeals` inside the populated dashboard surfaces the inline
//     "No meals today" placeholder rendered by `TodaysMealsCard`.
//   * `HomeHeader.onAvatarTap` is never wired by the screen, so the
//     avatar -> profile navigation has no production behaviour to assert.
//   * The screen's error scaffold CTA reads "Try Again", not "Retry".

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
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/home/home_controller.dart';
import 'package:nibbles/src/features/home/home_screen.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:nibbles/src/features/home/widgets/day_chip_row.dart';
import 'package:nibbles/src/features/home/widgets/greeting_card.dart';
import 'package:nibbles/src/features/home/widgets/helpful_guidance_card.dart';
import 'package:nibbles/src/features/home/widgets/home_empty_state_full.dart';
import 'package:nibbles/src/features/home/widgets/home_header.dart';
import 'package:nibbles/src/features/home/widgets/ongoing_introduced_card.dart';
import 'package:nibbles/src/features/home/widgets/stat_ring_card.dart';
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
  // Anchor DOB so age math is deterministic regardless of clock drift.
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

MealPlanEntry _meal(String id, String recipeId, {String? mealTime}) =>
    MealPlanEntry(
      id: id,
      babyId: _babyId,
      recipeId: recipeId,
      planDate: DateTime.now(),
      mealTime: mealTime,
    );

/// Populated state with a mix of statuses (peanut inProgress drives the
/// OngoingIntroducedCard) and two meals today.
HomeState _populatedState() => HomeState(
  baby: _fakeBaby,
  allergenStatuses: const {
    'peanut': AllergenStatus.inProgress,
    'egg': AllergenStatus.safe,
    'dairy': AllergenStatus.safe,
    'tree_nuts': AllergenStatus.flagged,
    'sesame': AllergenStatus.notStarted,
    'soy': AllergenStatus.notStarted,
    'wheat': AllergenStatus.notStarted,
    'fish': AllergenStatus.notStarted,
    'shellfish': AllergenStatus.notStarted,
  },
  todaysMeals: [
    _meal('mp-1', 'recipe-aaa', mealTime: 'breakfast'),
    _meal('mp-2', 'recipe-bbb', mealTime: 'lunch'),
  ],
);

/// Populated baby + statuses but ZERO meals today — exercises the
/// `TodaysMealsCard` inline "No meals today" placeholder while still
/// rendering the full dashboard chrome.
HomeState _populatedNoMealsState() => HomeState(
  baby: _fakeBaby,
  allergenStatuses: const {
    'peanut': AllergenStatus.inProgress,
    'egg': AllergenStatus.safe,
  },
);

/// Baby exists but every allergen is `notStarted` and no meals today —
/// `HomeState.hasNoActivity == true` so the screen renders the empty-state
/// full variant.
HomeState _emptyFullState() => HomeState(
  baby: _fakeBaby,
  allergenStatuses: const {
    'peanut': AllergenStatus.notStarted,
    'egg': AllergenStatus.notStarted,
  },
);

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
// Marker destination stubs — assert routed-to by their text.
// ---------------------------------------------------------------------------

const _allergenTrackerMarker = 'ALLERGEN_TRACKER_STUB';
const _mealPlanMarker = 'MEAL_PLAN_STUB';
const _profileMarker = 'PROFILE_STUB';

class _RecipeDetailStub extends StatelessWidget {
  const _RecipeDetailStub({required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('RECIPE_DETAIL_STUB:$recipeId')));
}

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
      builder: (_, state) =>
          _RecipeDetailStub(recipeId: state.pathParameters['recipeId'] ?? ''),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Fake controllers
// ---------------------------------------------------------------------------

class _FakeHomeController extends HomeController {
  _FakeHomeController(this._initialState);

  final HomeState _initialState;

  @override
  Future<HomeState> build(String babyId) async => _initialState;
}

/// Used by the error/retry test to assert
/// `ref.invalidate(homeControllerProvider)` recreates the notifier and
/// re-runs `build` (instance fields don't survive invalidation, so we
/// count via a closure).
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
// SUT builder
// ---------------------------------------------------------------------------

Widget _buildSut({
  required List<Override> overrides,
  GoRouter? router,
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(routerConfig: router ?? _testRouter()),
);

List<Override> _overridesFor({
  String? babyId,
  HomeState? state,
  HomeController Function()? controllerFactory,
}) {
  final ovs = <Override>[
    currentBabyIdProvider.overrideWith((ref) async => babyId),
  ];
  if (babyId != null) {
    final factory = controllerFactory ??
        () => _FakeHomeController(state ?? _populatedState());
    ovs.add(homeControllerProvider(babyId).overrideWith(factory));
  }
  return ovs;
}

Future<void> _pump(
  WidgetTester tester, {
  required List<Override> overrides,
  GoRouter? router,
}) async {
  // Tall viewport so the scrollable column lays out without overflow.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildSut(overrides: overrides, router: router));
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

  // -------------------------------------------------------------------------
  // NIB-86 render-smoke (kept from the existing slim file).
  // -------------------------------------------------------------------------
  group('HomeScreen — render smoke (NIB-86 baseline)', () {
    testWidgets('renders without errors when baby + state resolve', (
      tester,
    ) async {
      await _pump(
        tester,
        overrides: _overridesFor(babyId: _babyId, state: _populatedState()),
      );
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('renders empty state scaffold when no baby exists', (
      tester,
    ) async {
      await _pump(
        tester,
        overrides: _overridesFor(),
      );
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(HomeEmptyStateFull), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // 1. Dashboard states
  // -------------------------------------------------------------------------
  group('HomeScreen — populated state', () {
    testWidgets(
      'renders header + greeting + rings + ongoing + chips + meals + tips',
      (tester) async {
        await _pump(
          tester,
          overrides: _overridesFor(babyId: _babyId, state: _populatedState()),
        );

        expect(find.byType(HomeHeader), findsOneWidget);
        expect(find.byType(GreetingCard), findsOneWidget);
        expect(find.byType(StatRingCard), findsOneWidget);
        expect(find.byType(OngoingIntroducedCard), findsOneWidget);
        // OngoingIntroducedCard renders SizedBox.shrink unless inProgress
        // exists; the populated fixture has peanut inProgress, so the
        // ONGOING INTRODUCED label MUST render.
        expect(find.text('ONGOING INTRODUCED'), findsOneWidget);
        expect(find.byType(DayChipRow), findsOneWidget);
        expect(find.byType(TodaysMealsCard), findsOneWidget);
        expect(find.byType(HelpfulGuidanceCard), findsOneWidget);
      },
    );

    testWidgets("greeting shows baby name + 'months today' line", (
      tester,
    ) async {
      await _pump(
        tester,
        overrides: _overridesFor(babyId: _babyId, state: _populatedState()),
      );

      // GreetingCard renders text containing the baby name + age phrasing.
      expect(find.textContaining('Lily'), findsWidgets);
      expect(find.textContaining('months today!'), findsOneWidget);
    });

    testWidgets('meal rows render one Material row per todays meal entry', (
      tester,
    ) async {
      await _pump(
        tester,
        overrides: _overridesFor(babyId: _babyId, state: _populatedState()),
      );

      // Two meals -> two capitalised meal-time labels.
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
    });
  });

  group('HomeScreen — empty-full state (baby + no activity)', () {
    testWidgets(
      'baby present but `hasNoActivity` -> HomeEmptyStateFull renders',
      (tester) async {
        await _pump(
          tester,
          overrides: _overridesFor(babyId: _babyId, state: _emptyFullState()),
        );

        expect(find.byType(HomeEmptyStateFull), findsOneWidget);
        // Dashboard chrome is intentionally absent in empty-full.
        expect(find.byType(HomeHeader), findsNothing);
        expect(find.byType(StatRingCard), findsNothing);
        expect(find.byType(TodaysMealsCard), findsNothing);
        // Ready-to-start CTA copy.
        expect(find.text('Ready to start?'), findsOneWidget);
        expect(find.text('Create First Meal'), findsOneWidget);
      },
    );
  });

  group('HomeScreen — empty-full state (no baby)', () {
    // The screen has only two empty-state code paths; both render
    // HomeEmptyStateFull. There is no separate HomeEmptyStateShort branch
    // at the screen level (see widget-level test for the standalone
    // HomeEmptyStateShort). This test stands in for the "empty-short"
    // ticket bullet -- the screen's branching is documented above.
    testWidgets(
      'babyId resolves to null -> HomeEmptyStateFull (full empty branch)',
      (tester) async {
        await _pump(tester, overrides: _overridesFor());

        expect(find.byType(HomeEmptyStateFull), findsOneWidget);
        expect(find.byType(HomeHeader), findsNothing);
        // Getting Started Tips title is part of the full variant.
        expect(find.text('Getting Started Tips'), findsOneWidget);
      },
    );
  });

  group('HomeScreen — no-meals (populated dashboard, empty todays meals)', () {
    testWidgets(
      'empty todaysMeals -> TodaysMealsCard inline placeholder renders',
      (tester) async {
        await _pump(
          tester,
          overrides: _overridesFor(
            babyId: _babyId,
            state: _populatedNoMealsState(),
          ),
        );

        // Full dashboard chrome still renders (we are NOT in empty-full).
        expect(find.byType(HomeHeader), findsOneWidget);
        expect(find.byType(StatRingCard), findsOneWidget);
        expect(find.byType(TodaysMealsCard), findsOneWidget);
        // Inline empty-meals placeholder text.
        expect(find.text('No meals today'), findsOneWidget);
        // Counter shows 0/2.
        expect(find.text('0/2'), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // 2. Navigation taps
  // -------------------------------------------------------------------------
  group('HomeScreen — navigation taps', () {
    testWidgets(
      'tap ongoing card -> pushes /home/allergen/tracker',
      (tester) async {
        await _pump(
          tester,
          overrides: _overridesFor(babyId: _babyId, state: _populatedState()),
        );

        // OngoingIntroducedCard wraps an InkWell inside a Material; tap
        // by descendant from the card type so we hit the tappable region.
        final inkwell = find.descendant(
          of: find.byType(OngoingIntroducedCard),
          matching: find.byType(InkWell),
        );
        expect(inkwell, findsOneWidget);
        await tester.tap(inkwell);
        await tester.pumpAndSettle();

        expect(find.text(_allergenTrackerMarker), findsOneWidget);
      },
    );

    testWidgets(
      'tap a meal row -> pushes /home/recipes/:recipeId with the entry id',
      (tester) async {
        await _pump(
          tester,
          overrides: _overridesFor(babyId: _babyId, state: _populatedState()),
        );

        // First meal row -> recipe-aaa.
        await tester.tap(find.text('Breakfast'));
        await tester.pumpAndSettle();

        expect(
          find.text('RECIPE_DETAIL_STUB:recipe-aaa'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tap a different meal row -> pushes /home/recipes/:recipeId with that id',
      (tester) async {
        await _pump(
          tester,
          overrides: _overridesFor(babyId: _babyId, state: _populatedState()),
        );

        // Second meal row -> recipe-bbb.
        await tester.tap(find.text('Lunch'));
        await tester.pumpAndSettle();

        expect(
          find.text('RECIPE_DETAIL_STUB:recipe-bbb'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tap empty-state Create First Meal CTA -> switches to meal plan tab',
      (tester) async {
        await _pump(
          tester,
          overrides: _overridesFor(babyId: _babyId, state: _emptyFullState()),
        );

        expect(find.byType(HomeEmptyStateFull), findsOneWidget);
        await tester.tap(find.text('Create First Meal'));
        await tester.pumpAndSettle();

        expect(find.text(_mealPlanMarker), findsOneWidget);
      },
    );

    testWidgets(
      'tap empty-state CTA from no-baby branch -> switches to meal plan tab',
      (tester) async {
        await _pump(tester, overrides: _overridesFor());

        expect(find.byType(HomeEmptyStateFull), findsOneWidget);
        await tester.tap(find.text('Create First Meal'));
        await tester.pumpAndSettle();

        expect(find.text(_mealPlanMarker), findsOneWidget);
      },
    );

    // NOTE: avatar -> profile is INTENTIONALLY uncovered at the screen
    // level. `HomeHeader.onAvatarTap` is never wired by `HomeScreen`, so
    // there is no production behaviour to assert (and per project rules
    // we MUST NOT modify lib/**). A standalone HomeHeader unit test would
    // be tautological. Documented in the PR body.
  });

  // -------------------------------------------------------------------------
  // 3. Error / retry
  // -------------------------------------------------------------------------
  group('HomeScreen — error and retry', () {
    testWidgets(
      'controller throws -> error scaffold renders with Try Again CTA',
      (tester) async {
        var buildCount = 0;
        await _pump(
          tester,
          overrides: _overridesFor(
            babyId: _babyId,
            controllerFactory: () => _ThrowingHomeController(() {
              buildCount += 1;
            }),
          ),
        );

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
        expect(buildCount, 1);
      },
    );

    testWidgets(
      'tap Try Again -> controller rebuild (invalidate fires a new build)',
      (tester) async {
        var buildCount = 0;
        await _pump(
          tester,
          overrides: _overridesFor(
            babyId: _babyId,
            controllerFactory: () => _ThrowingHomeController(() {
              buildCount += 1;
            }),
          ),
        );

        expect(buildCount, 1);
        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        // Invalidate disposes + recreates the notifier -> build runs again.
        expect(buildCount, 2);
        // Error scaffold still up because the rebuild also throws.
        expect(find.text('Try Again'), findsOneWidget);
      },
    );
  });
}
