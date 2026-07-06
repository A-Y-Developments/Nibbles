// Widget coverage for the redesigned `TodaysMealsCard`.
//
// The card now takes an explicit `mealCount` / `mealTarget` and renders an
// inline "Add" pill whenever the day is under target (the empty-state body
// moved out to `HomeNoMealsState`). Asserts:
//   - "Add" pill gating + "Great job!" banner gating on coverage.
//   - Recipe-title hydration + meal-time / generic fallbacks.
//   - Tag chips bind to `category` + `nutritionTags` only (+N overflow).
//   - Meal rows expose a labelled button that routes to recipe detail.

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

Widget _wrap(Widget child) => MaterialApp.router(routerConfig: _router(child));

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

TodaysMealsCard _card({
  required List<MealPlanEntry> meals,
  Map<String, Recipe> recipes = const {},
  int? mealCount,
  int mealTarget = 2,
}) => TodaysMealsCard(
  meals: meals,
  recipes: recipes,
  mealCount: mealCount ?? meals.length,
  mealTarget: mealTarget,
  onAdd: () {},
);

void _bigViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  group('TodaysMealsCard — Add pill + coverage banner gating', () {
    testWidgets('below target (1/2) -> "Add" pill shows, no banner', (
      tester,
    ) async {
      _bigViewport(tester);

      await tester.pumpWidget(
        _wrap(
          _card(meals: [_entry('m1', 'r-a', mealTime: 'breakfast')]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(
        find.text('Great job! Everything important is covered'),
        findsNothing,
      );
    });

    testWidgets('at target (2/2) -> banner shows, "Add" pill hidden', (
      tester,
    ) async {
      _bigViewport(tester);

      await tester.pumpWidget(
        _wrap(
          _card(
            meals: [
              _entry('m1', 'r-a', mealTime: 'breakfast'),
              _entry('m2', 'r-b', mealTime: 'lunch'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
      expect(find.text('Add'), findsNothing);
      expect(
        find.text('Great job! Everything important is covered'),
        findsOneWidget,
      );
    });
  });

  group('TodaysMealsCard — meal rows', () {
    testWidgets('recipe hydrated -> renders recipe title', (tester) async {
      _bigViewport(tester);

      await tester.pumpWidget(
        _wrap(
          _card(
            meals: [_entry('m1', 'r-a', mealTime: 'breakfast')],
            recipes: {'r-a': _recipe()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Chicken Liver, Apple & Sweet Potato Purée'),
        findsOneWidget,
      );
      expect(find.text('Breakfast'), findsNothing);
    });

    testWidgets('no recipe + mealTime -> capitalized meal-time fallback', (
      tester,
    ) async {
      _bigViewport(tester);

      await tester.pumpWidget(
        _wrap(_card(meals: [_entry('m1', 'r-a', mealTime: 'lunch')])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lunch'), findsOneWidget);
    });

    testWidgets('no recipe + no mealTime -> generic "Meal" fallback', (
      tester,
    ) async {
      _bigViewport(tester);

      await tester.pumpWidget(_wrap(_card(meals: [_entry('m1', 'r-a')])));
      await tester.pumpAndSettle();

      expect(find.text('Meal'), findsOneWidget);
    });
  });

  group('TodaysMealsCard — tag chips', () {
    testWidgets('category + nutritionTags render; allergenTags excluded', (
      tester,
    ) async {
      _bigViewport(tester);

      await tester.pumpWidget(
        _wrap(
          _card(
            meals: [_entry('m1', 'r-a')],
            recipes: {
              'r-a': _recipe(
                category: 'fruit',
                nutritionTags: const ['Iron Rich'],
                allergenTags: const ['dairy'],
              ),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fruit'), findsOneWidget);
      expect(find.text('Iron Rich'), findsOneWidget);
      expect(find.text('Dairy'), findsNothing);
    });

    testWidgets('more than 2 tags -> "+N" overflow chip', (tester) async {
      _bigViewport(tester);

      await tester.pumpWidget(
        _wrap(
          _card(
            meals: [_entry('m1', 'r-a')],
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

      expect(find.text('Fruit'), findsOneWidget);
      expect(find.text('Iron Rich'), findsOneWidget);
      expect(find.text('+2'), findsOneWidget);
    });
  });

  group('TodaysMealsCard — meal row a11y + navigation', () {
    testWidgets('meal row exposes a labelled button that routes to detail', (
      tester,
    ) async {
      _bigViewport(tester);
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrap(
          _card(
            meals: [_entry('m1', 'r1')],
            recipes: {'r1': _recipe()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      const label = 'Meal, Chicken Liver, Apple & Sweet Potato Purée';
      expect(find.bySemanticsLabel(label), findsOneWidget);

      await tester.tap(find.bySemanticsLabel(label));
      await tester.pumpAndSettle();
      expect(find.text('RECIPE_STUB:r1'), findsOneWidget);

      handle.dispose();
    });
  });
}
