// NIB-77 — Widget-level coverage for `TodaysMealsCard`.
//
// Asserts the audit-derived rules that the broader screen test cannot
// reach precisely:
//   - "Great job!" banner only renders at 100% coverage (count >= target).
//   - Recipe-title hydration: full title shows when a `Recipe` is supplied.
//   - Fallback: meal-time label when no recipe is hydrated.
//   - Inline "No meals today" placeholder when `todaysMeals` is empty.
//   - Tag chips bind to `category` + `nutritionTags` ONLY (allergen tags
//     are a CONTAINS-allergen safety signal — intentionally excluded).
//   - `+N` overflow chip appears when more than 2 tags exist.

// Firebase platform-interface packages are transitive deps; the public
// barrels do not re-export FirebaseAnalyticsPlatform / setupFirebaseCoreMocks.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/home/widgets/todays_meals_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

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

GoRouter _router(Widget child) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => Scaffold(body: child)),
    GoRoute(
      path: AppRoute.recipeDetail.path,
      name: AppRoute.recipeDetail.name,
      builder: (_, state) => Scaffold(
        body: Center(
          child: Text('RECIPE_STUB:${state.pathParameters['recipeId']}'),
        ),
      ),
    ),
  ],
);

Widget _wrap(Widget child) =>
    MaterialApp.router(routerConfig: _router(child));

MealPlanEntry _entry(String id, String recipeId, {String? mealTime}) =>
    MealPlanEntry(
      id: id,
      babyId: 'baby-1',
      recipeId: recipeId,
      planDate: DateTime.now(),
      mealTime: mealTime,
    );

Recipe _recipe({
  String id = 'r1',
  String title = 'Chicken Liver, Apple & Sweet Potato Purée',
  String? category,
  List<String> nutritionTags = const <String>[],
  List<String> allergenTags = const <String>[],
}) => Recipe(
  id: id,
  title: title,
  ageRange: '6+ months',
  allergenTags: allergenTags,
  ingredients: const [],
  steps: const [],
  howToServe: '',
  nutritionTags: nutritionTags,
  category: category,
);

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  group('TodaysMealsCard — coverage banner gate', () {
    testWidgets(
      'below target (1/2) -> "Great job!" banner is NOT rendered',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(
            TodaysMealsCard(
              todaysMeals: [_entry('m1', 'r-a', mealTime: 'breakfast')],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Great job! Everything important is covered'),
          findsNothing,
        );
        expect(find.text('1/2'), findsOneWidget);
      },
    );

    testWidgets(
      'at target (2/2) -> "Great job!" banner renders (verbatim)',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(
            TodaysMealsCard(
              todaysMeals: [
                _entry('m1', 'r-a', mealTime: 'breakfast'),
                _entry('m2', 'r-b', mealTime: 'lunch'),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Great job! Everything important is covered'),
          findsOneWidget,
        );
        expect(find.text('2/2'), findsOneWidget);
      },
    );
  });

  group('TodaysMealsCard — meal rows', () {
    testWidgets(
      'recipe hydrated -> renders recipe title (not meal-time fallback)',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Recipe title defaults to "Chicken Liver, Apple & Sweet Potato
        // Purée" — the verbatim audit title for the populated meal row.
        await tester.pumpWidget(
          _wrap(
            TodaysMealsCard(
              todaysMeals: [_entry('m1', 'r-a', mealTime: 'breakfast')],
              recipes: {'r-a': _recipe()},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Chicken Liver, Apple & Sweet Potato Purée'),
          findsOneWidget,
        );
        // Meal-time fallback should NOT be present alongside the title.
        expect(find.text('Breakfast'), findsNothing);
      },
    );

    testWidgets(
      'no recipe + mealTime -> renders capitalized meal-time fallback',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(
            TodaysMealsCard(
              todaysMeals: [_entry('m1', 'r-a', mealTime: 'lunch')],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Lunch'), findsOneWidget);
      },
    );

    testWidgets(
      'no recipe + no mealTime -> renders generic "Meal" fallback',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(
            TodaysMealsCard(
              todaysMeals: [_entry('m1', 'r-a')],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Meal'), findsOneWidget);
      },
    );

    testWidgets(
      'empty todaysMeals -> inline "No meals today" placeholder + 0/2 counter',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(const TodaysMealsCard(todaysMeals: [])),
        );
        await tester.pumpAndSettle();

        expect(find.text('No meals today'), findsOneWidget);
        expect(find.text('0/2'), findsOneWidget);
        expect(
          find.text('Great job! Everything important is covered'),
          findsNothing,
        );
      },
    );
  });

  group('TodaysMealsCard — tag chips', () {
    testWidgets(
      'category + nutritionTags render as chips; allergenTags are excluded',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(
            TodaysMealsCard(
              todaysMeals: [_entry('m1', 'r-a')],
              recipes: {
                'r-a': _recipe(
                  category: 'fruit',
                  nutritionTags: const ['Iron Rich'],
                  // `allergenTags` is the CONTAINS-allergen safety field —
                  // it must NOT render as a friendly chip.
                  allergenTags: const ['dairy'],
                ),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Fruit'), findsOneWidget);
        expect(find.text('Iron Rich'), findsOneWidget);
        // Allergen-tag must NOT appear as a benign chip.
        expect(find.text('Dairy'), findsNothing);
      },
    );

    testWidgets(
      'more than 2 visible tags -> "+N" overflow chip renders',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(
            TodaysMealsCard(
              todaysMeals: [_entry('m1', 'r-a')],
              recipes: {
                'r-a': _recipe(
                  category: 'fruit',
                  nutritionTags: const ['Iron Rich', 'Vitamin A', 'Fiber'],
                ),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Visible: category 'Fruit' + first nutritionTag 'Iron Rich'.
        expect(find.text('Fruit'), findsOneWidget);
        expect(find.text('Iron Rich'), findsOneWidget);
        // Overflow: 4 total - 2 visible = +2.
        expect(find.text('+2'), findsOneWidget);
      },
    );
  });

  group('TodaysMealsCard — guidance copy (verbatim audit strings)', () {
    testWidgets('"Today, {Month Day}" title is rendered above the card', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(const TodaysMealsCard(todaysMeals: [])),
      );
      await tester.pumpAndSettle();

      // Title starts with "Today, " — full format is verified by month/day
      // lookup against the live clock so we only assert the prefix.
      expect(find.textContaining('Today, '), findsOneWidget);
      expect(find.text("TODAY'S MEALS"), findsOneWidget);
    });
  });
}
