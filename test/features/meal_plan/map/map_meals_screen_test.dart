import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_controller.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_screen.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_state.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/day_chip_row.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/picked_recipe_row.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../../support/fake_analytics.dart';

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockMealPlanService extends Mock implements MealPlanService {}

const _babyId = 'baby-001';

final _fakeBaby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

const _recipeA = Recipe(
  id: 'r-A',
  title: 'Avocado Mash',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

const _recipeB = Recipe(
  id: 'r-B',
  title: 'Banana Porridge',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

MapMealsArgs _makeArgs() => MapMealsArgs(
      pickedRecipes: const [_recipeA, _recipeB],
      startDate: DateTime(2026, 5, 30),
      endDate: DateTime(2026, 6, 5),
    );

void main() {
  late _MockBabyProfileService mockBabyService;
  late _MockMealPlanService mockMealPlanService;
  late FakeAnalytics fakeAnalytics;
  late List<_RecorderCall> recorderCalls;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    mockBabyService = _MockBabyProfileService();
    mockMealPlanService = _MockMealPlanService();
    fakeAnalytics = FakeAnalytics();
    recorderCalls = <_RecorderCall>[];
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
  });

  Future<void> fakeRecorder(
    Object error,
    StackTrace stack, {
    String? reason,
    List<String>? information,
  }) async {
    recorderCalls.add(
      _RecorderCall(
        error: error,
        stack: stack,
        reason: reason,
        information: information,
      ),
    );
  }

  Future<void> pumpMap(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final args = _makeArgs();
    final router = GoRouter(
      initialLocation: '/map',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/map',
          builder: (_, __) => MapMealsScreen(args: args),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          babyProfileServiceProvider.overrideWithValue(mockBabyService),
          mealPlanServiceProvider.overrideWithValue(mockMealPlanService),
          analyticsProvider.overrideWithValue(fakeAnalytics),
          mealPrepCrashRecorderProvider.overrideWithValue(fakeRecorder),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('MapMealsScreen', () {
    testWidgets(
      'renders day chips, picked recipe list and the "X of Y slots filled" '
      'progress badge',
      (tester) async {
        await pumpMap(tester);

        expect(find.byType(DayChipRow), findsOneWidget);
        expect(find.byType(PickedRecipeRow), findsNWidgets(2));
        expect(find.text('0 of 2 slots filled'), findsOneWidget);
      },
    );

    testWidgets('tapping a picked recipe assigns it to the selected day',
        (tester) async {
      await pumpMap(tester);

      // Tap the first picked recipe to assign it to the (currently) selected
      // start day.
      await tester.tap(find.text(_recipeA.title));
      await tester.pumpAndSettle();

      expect(find.text('1 of 2 slots filled'), findsOneWidget);
    });

    testWidgets(
      'floating CTA is absent with 0 assignments, says "Add (N)" while '
      'partial, and "Complete Mapping" once every picked recipe is assigned',
      (tester) async {
        await pumpMap(tester);

        // 0 assignments → no CTA rendered at all.
        expect(find.byType(FilledButton), findsNothing);

        // 1 of 2 assigned → "Add (1)".
        await tester.tap(find.text(_recipeA.title));
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(FilledButton, 'Add (1)'),
          findsOneWidget,
        );

        // 2 of 2 assigned → "Complete Mapping".
        await tester.tap(find.text(_recipeB.title));
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(FilledButton, 'Complete Mapping'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'empty selected-day shows "No Meals Mapped Yet" + drag-drop helper text',
      (tester) async {
        await pumpMap(tester);

        expect(find.text('No Meals Mapped Yet'), findsOneWidget);
        expect(
          find.text('Drag & drop or click meals below to add them'),
          findsOneWidget,
        );
      },
    );

    testWidgets('commit success pops the route with true', (tester) async {
      when(
        () => mockMealPlanService.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          assignments: any(named: 'assignments'),
        ),
      ).thenAnswer((_) async => const Result.success([]));

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // GoRouter so the screen's `context.pop(true)` resolves the pushed
      // future on the previous route.
      final args = _makeArgs();
      Object? popResult;
      late GoRouter router;
      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    popResult =
                        await router.push<dynamic>('/map');
                  },
                  child: const Text('Push'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/map',
            builder: (_, __) => MapMealsScreen(args: args),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            babyProfileServiceProvider.overrideWithValue(mockBabyService),
            mealPlanServiceProvider.overrideWithValue(mockMealPlanService),
            analyticsProvider.overrideWithValue(fakeAnalytics),
            mealPrepCrashRecorderProvider.overrideWithValue(fakeRecorder),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      // Assign both recipes (so the CTA says "Complete Mapping") + commit.
      await tester.tap(find.text(_recipeA.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_recipeB.title));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Complete Mapping'),
      );
      await tester.pumpAndSettle();

      expect(popResult, isTrue);
    });

    testWidgets(
      'commit failure shows a blocking AlertDialog with Retry that '
      're-calls commit',
      (tester) async {
        var callCount = 0;
        when(
          () => mockMealPlanService.appendMealsToRange(
            babyId: any(named: 'babyId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            assignments: any(named: 'assignments'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          return const Result.failure(ServerException('boom'));
        });

        await pumpMap(tester);

        await tester.tap(find.text(_recipeA.title));
        await tester.pumpAndSettle();
        await tester.tap(find.text(_recipeB.title));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, 'Complete Mapping'),
        );
        await tester.pumpAndSettle();

        // Blocking AlertDialog with Retry button.
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text("Couldn't save your plan"), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
        expect(callCount, 1);

        await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
        await tester.pumpAndSettle();

        // Retry re-invokes commit (which fires the service again).
        expect(callCount, 2);
      },
    );
  });
}

class _RecorderCall {
  _RecorderCall({
    required this.error,
    required this.stack,
    required this.reason,
    required this.information,
  });

  final Object error;
  final StackTrace stack;
  final String? reason;
  final List<String>? information;
}
