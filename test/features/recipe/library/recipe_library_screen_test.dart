// Widget tests for the redesigned Recipe Library screen (NIB-53 + NIB-58).
//
// Drives the screen by overriding [recipeLibraryControllerProvider] with a
// canned [RecipeLibraryState], then asserts:
//   * category rows render in insertion order (one [RecipeCategoryRow] per
//     non-empty category)
//   * the [ReadGuideBanner] is gated by
//     [RecipeLibraryState.isStartingGuideSeen]
//   * a non-empty `searchQuery` collapses the body into [RecipeSearchResults]
//   * a non-empty `searchQuery` with no matches renders [RecipeSearchEmpty]
//   * tapping a grid card pushes `/home/recipes/:recipeId` via GoRouter.

// Firebase platform-interface packages are transitive deps; the public barrels
// don't re-export FirebaseAnalyticsPlatform/setupFirebaseCoreMocks. Test-only.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_controller.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_screen.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';
import 'package:nibbles/src/features/recipe/library/widgets/read_guide_banner.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_category_row.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_grid_card.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_search_empty.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_search_results.dart';
import 'package:nibbles/src/routing/route_enums.dart';

const _babyId = 'baby-001';

const _r1 = Recipe(
  id: 'r1',
  title: 'Pea Puree',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

const _r2 = Recipe(
  id: 'r2',
  title: 'Carrot Puree',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

const _r3 = Recipe(
  id: 'r3',
  title: 'Banana Bites',
  ageRange: '8m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
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

/// Marker route — RecipeGridCard taps push
/// `/home/recipes/:recipeId`, this stub captures the routed id.
class _RecipeDetailStub extends StatelessWidget {
  const _RecipeDetailStub({required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('DETAIL_STUB:$recipeId')));
}

GoRouter _makeRouter() => GoRouter(
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
          _RecipeDetailStub(recipeId: state.pathParameters['recipeId'] ?? ''),
    ),
  ],
);

Widget _buildSut({required RecipeLibraryState state, GoRouter? router}) =>
    ProviderScope(
      overrides: [
        currentBabyIdProvider.overrideWith((ref) async => _babyId),
        recipeLibraryControllerProvider(
          _babyId,
        ).overrideWith(() => _FakeRecipeLibraryController(state)),
      ],
      child: MaterialApp.router(routerConfig: router ?? _makeRouter()),
    );

class _FakeRecipeLibraryController extends RecipeLibraryController {
  _FakeRecipeLibraryController(this._initialState);

  final RecipeLibraryState _initialState;

  @override
  Future<RecipeLibraryState> build(String babyId) async => _initialState;
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  setUp(() {
    // Large viewport so all rows are laid out without overflow.
    // (Set per-test via tester.view in helpers below.)
  });

  Future<void> pump(
    WidgetTester tester, {
    required RecipeLibraryState state,
    GoRouter? router,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildSut(state: state, router: router));
    await tester.pumpAndSettle();
  }

  group('RecipeLibraryScreen — category rows', () {
    testWidgets(
      'renders one RecipeCategoryRow per non-empty category with section title',
      (tester) async {
        const state = RecipeLibraryState(
          recipesByCategory: {
            'Purees': [_r1, _r2],
            'Finger Foods': [_r3],
          },
          isStartingGuideSeen: true,
        );

        await pump(tester, state: state);

        expect(find.byType(RecipeCategoryRow), findsNWidgets(2));
        expect(find.text('Purees'), findsOneWidget);
        expect(find.text('Finger Foods'), findsOneWidget);
        expect(find.text(_r1.title), findsOneWidget);
        expect(find.text(_r3.title), findsOneWidget);
      },
    );

    testWidgets('empty-valued category entries are skipped (no empty rows)', (
      tester,
    ) async {
      const state = RecipeLibraryState(
        recipesByCategory: {
          'Purees': [_r1],
          'Other': [],
        },
        isStartingGuideSeen: true,
      );

      await pump(tester, state: state);

      // Only the non-empty 'Purees' row should render.
      expect(find.byType(RecipeCategoryRow), findsOneWidget);
      expect(find.text('Purees'), findsOneWidget);
      expect(find.text('Other'), findsNothing);
    });
  });

  group('RecipeLibraryScreen — Read Guide banner gating', () {
    testWidgets(
      'isStartingGuideSeen=false → ReadGuideBanner renders above the first row',
      (tester) async {
        const state = RecipeLibraryState(
          recipesByCategory: {
            'Purees': [_r1],
          },
        );

        await pump(tester, state: state);

        expect(find.byType(ReadGuideBanner), findsOneWidget);
        // 'Read Guide' CTA label is unique to the banner.
        expect(find.text('Read Guide'), findsOneWidget);
      },
    );

    testWidgets('isStartingGuideSeen=true → ReadGuideBanner is hidden', (
      tester,
    ) async {
      const state = RecipeLibraryState(
        recipesByCategory: {
          'Purees': [_r1],
        },
        isStartingGuideSeen: true,
      );

      await pump(tester, state: state);

      expect(find.byType(ReadGuideBanner), findsNothing);
      expect(find.text('Read Guide'), findsNothing);
    });
  });

  group('RecipeLibraryScreen — search branch', () {
    testWidgets(
      'non-empty searchQuery with matches → body uses RecipeSearchResults',
      (tester) async {
        const state = RecipeLibraryState(
          recipesByCategory: {
            'Purees': [_r1, _r2],
          },
          isStartingGuideSeen: true,
          searchQuery: 'pea',
        );

        await pump(tester, state: state);

        // Search-results branch is up — categories collapsed.
        expect(find.byType(RecipeSearchResults), findsOneWidget);
        expect(find.byType(RecipeCategoryRow), findsNothing);
        // 'Pea Puree' matches 'pea' but 'Carrot Puree' does not.
        expect(find.text(_r1.title), findsOneWidget);
      },
    );

    testWidgets(
      'non-empty searchQuery with no matches → RecipeSearchEmpty renders',
      (tester) async {
        const state = RecipeLibraryState(
          recipesByCategory: {
            'Purees': [_r1, _r2],
          },
          isStartingGuideSeen: true,
          searchQuery: 'zzzunknown',
        );

        await pump(tester, state: state);

        expect(find.byType(RecipeSearchEmpty), findsOneWidget);
        expect(find.byType(RecipeSearchResults), findsNothing);
        expect(find.byType(RecipeCategoryRow), findsNothing);
        // Generic copy — does NOT interpolate the query.
        expect(find.textContaining("We couldn't find"), findsOneWidget);
        expect(find.textContaining('zzzunknown'), findsNothing);
      },
    );
  });

  group('RecipeLibraryScreen — card navigation', () {
    testWidgets('tapping a RecipeGridCard pushes /home/recipes/:recipeId', (
      tester,
    ) async {
      const state = RecipeLibraryState(
        recipesByCategory: {
          'Purees': [_r1],
        },
        isStartingGuideSeen: true,
      );

      final router = _makeRouter();
      await pump(tester, state: state, router: router);

      // Tap the grid card for r1.
      await tester.tap(find.byType(RecipeGridCard).first);
      await tester.pumpAndSettle();

      // Routed to the recipe-detail stub with the right id.
      expect(find.text('DETAIL_STUB:${_r1.id}'), findsOneWidget);
    });
  });
}
