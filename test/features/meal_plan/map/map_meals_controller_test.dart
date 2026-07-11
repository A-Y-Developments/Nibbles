import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_controller.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_state.dart';
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
  title: 'Recipe A',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

const _recipeB = Recipe(
  id: 'r-B',
  title: 'Recipe B',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

final _fakePlan = MealPlan(
  id: 'plan-001',
  babyId: _babyId,
  startDate: DateTime(2026, 5, 30),
  endDate: DateTime(2026, 6, 5),
  createdAt: DateTime(2026, 5, 30),
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

  ProviderContainer buildContainer() {
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    final container = ProviderContainer(
      overrides: [
        babyProfileServiceProvider.overrideWithValue(mockBabyService),
        mealPlanServiceProvider.overrideWithValue(mockMealPlanService),
        analyticsProvider.overrideWithValue(fakeAnalytics),
        mealPrepCrashRecorderProvider.overrideWithValue(fakeRecorder),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  MapMealsArgs makeArgs({
    List<Recipe> picked = const [_recipeA, _recipeB],
    DateTime? start,
    DateTime? end,
  }) {
    final s = start ?? DateTime(2026, 5, 30);
    final e = end ?? s.add(const Duration(days: 6));
    return MapMealsArgs(pickedRecipes: picked, startDate: s, endDate: e);
  }

  group('MapMealsController.build', () {
    test('initializes selectedDay = startDate (date-only), '
        'empty assignments, isCommitting=false', () {
      final container = buildContainer();
      final args = makeArgs(
        start: DateTime(2026, 5, 30, 14, 32),
        end: DateTime(2026, 6, 5),
      );

      final state = container.read(mapMealsControllerProvider(args));

      expect(state.selectedDay, DateTime(2026, 5, 30));
      expect(state.startDate, DateTime(2026, 5, 30));
      expect(state.endDate, DateTime(2026, 6, 5));
      expect(state.assignments, isEmpty);
      expect(state.isCommitting, isFalse);
      expect(state.errorMessage, isNull);
    });
  });

  group('MapMealsController.selectDay', () {
    test('updates selectedDay (date-only normalized)', () {
      final container = buildContainer();
      final args = makeArgs();
      container
          .read(mapMealsControllerProvider(args).notifier)
          .selectDay(DateTime(2026, 6, 2, 11, 22));

      final state = container.read(mapMealsControllerProvider(args));
      expect(state.selectedDay, DateTime(2026, 6, 2));
    });
  });

  group('MapMealsController.assignToSelectedDay', () {
    test('COPIES recipe onto selectedDay — palette is reusable, so the same '
        'recipe can land on multiple days', () {
      final container = buildContainer();
      final args = makeArgs();
      final notifier = container.read(mapMealsControllerProvider(args).notifier)
        ..selectDay(DateTime(2026, 5, 31))
        ..assignToSelectedDay('r-A', 99);

      var state = container.read(mapMealsControllerProvider(args));
      expect(state.assignments[DateTime(2026, 5, 31)], ['r-A']);

      notifier
        ..selectDay(DateTime(2026, 6, 3))
        ..assignToSelectedDay('r-A', 99);

      state = container.read(mapMealsControllerProvider(args));
      expect(
        state.assignments[DateTime(2026, 5, 31)],
        ['r-A'],
        reason: 'The original day keeps its copy — assign never moves it.',
      );
      expect(
        state.assignments[DateTime(2026, 6, 3)],
        ['r-A'],
        reason: 'A second copy lands on the newly selected day.',
      );
      expect(state.filledCount, 2);
    });

    test('appends multiple copies of the same recipe to one day', () {
      final container = buildContainer();
      final args = makeArgs();
      container.read(mapMealsControllerProvider(args).notifier)
        ..selectDay(DateTime(2026, 5, 31))
        ..assignToSelectedDay('r-A', 3)
        ..assignToSelectedDay('r-A', 3);

      final state = container.read(mapMealsControllerProvider(args));
      expect(state.assignments[DateTime(2026, 5, 31)], ['r-A', 'r-A']);
    });
  });

  group('MapMealsController auto-advance', () {
    test(
      'filling the selected day advances to the next day (mealsPerDay=1)',
      () {
        final container = buildContainer();
        final args = makeArgs(start: DateTime(2026, 5, 30));
        container
            .read(mapMealsControllerProvider(args).notifier)
            .assignToSelectedDay('r-A', 1);

        final state = container.read(mapMealsControllerProvider(args));
        expect(state.selectedDay, DateTime(2026, 5, 31));
        expect(state.assignments[DateTime(2026, 5, 30)], ['r-A']);
      },
    );

    test('advance skips days that are already full', () {
      final container = buildContainer();
      final args = makeArgs(start: DateTime(2026, 5, 30));
      container.read(mapMealsControllerProvider(args).notifier)
        // Fill 5/31 first so it must be skipped.
        ..selectDay(DateTime(2026, 5, 31))
        ..assignToSelectedDay('r-B', 1)
        // Back to 5/30 and fill it → should skip full 5/31 → land on 6/1.
        ..selectDay(DateTime(2026, 5, 30))
        ..assignToSelectedDay('r-A', 1);

      final state = container.read(mapMealsControllerProvider(args));
      expect(state.selectedDay, DateTime(2026, 6));
    });

    test('mealsPerDay=2 advances only once the day is truly full', () {
      final container = buildContainer();
      final args = makeArgs(start: DateTime(2026, 5, 30));
      final notifier = container.read(mapMealsControllerProvider(args).notifier)
        ..assignToSelectedDay('r-A', 2);

      var state = container.read(mapMealsControllerProvider(args));
      expect(state.selectedDay, DateTime(2026, 5, 30), reason: '1/2 → stay');

      notifier.assignToSelectedDay('r-B', 2);
      state = container.read(mapMealsControllerProvider(args));
      expect(state.selectedDay, DateTime(2026, 5, 31), reason: '2/2 → advance');
    });

    test('no advance when the selected day is the last one in the window', () {
      final container = buildContainer();
      final args = makeArgs(start: DateTime(2026, 5, 30));
      container.read(mapMealsControllerProvider(args).notifier)
        ..selectDay(DateTime(2026, 6, 5))
        ..assignToSelectedDay('r-A', 1);

      final state = container.read(mapMealsControllerProvider(args));
      expect(state.selectedDay, DateTime(2026, 6, 5));
    });
  });

  group('MapMealsController.unassignFromSelectedDayAt', () {
    test('removes a single instance by index; empties the day when last '
        'instance goes', () {
      final container = buildContainer();
      final args = makeArgs();
      final notifier = container.read(mapMealsControllerProvider(args).notifier)
        ..selectDay(DateTime(2026, 5, 31))
        ..assignToSelectedDay('r-A', 99)
        ..assignToSelectedDay('r-B', 99)
        ..unassignFromSelectedDayAt(0);

      var state = container.read(mapMealsControllerProvider(args));
      expect(state.assignments[DateTime(2026, 5, 31)], ['r-B']);

      notifier.unassignFromSelectedDayAt(0);
      state = container.read(mapMealsControllerProvider(args));
      expect(
        state.assignments,
        isEmpty,
        reason: 'Removing the last instance drops the day key entirely.',
      );
    });
  });

  void stubCreatePlanSuccess() {
    when(
      () => mockMealPlanService.createPlan(any(), any(), any()),
    ).thenAnswer((_) async => Result.success(_fakePlan));
  }

  group('MapMealsController.commit', () {
    test(
      'success: creates the plan, then appends assignments →'
      ' RecipeAssignment(dayOffset) carrying mealPlanId, and returns true',
      () async {
        final args = makeArgs();
        stubCreatePlanSuccess();
        when(
          () => mockMealPlanService.appendMealsToRange(
            babyId: any(named: 'babyId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            mealPlanId: any(named: 'mealPlanId'),
            assignments: any(named: 'assignments'),
          ),
        ).thenAnswer((_) async => const Result.success([]));

        final container = buildContainer();
        final notifier =
            container.read(mapMealsControllerProvider(args).notifier)
              // r-A → start (offset 0)
              ..assignToSelectedDay('r-A', 99)
              // r-B → start + 3 days (offset 3)
              ..selectDay(DateTime(2026, 6, 2))
              ..assignToSelectedDay('r-B', 99);

        final ok = await notifier.commit();

        expect(ok, isTrue);
        verify(
          () => mockMealPlanService.createPlan(
            _babyId,
            DateTime(2026, 5, 30),
            DateTime(2026, 6, 5),
          ),
        ).called(1);
        final captured =
            verify(
                  () => mockMealPlanService.appendMealsToRange(
                    babyId: _babyId,
                    startDate: DateTime(2026, 5, 30),
                    endDate: DateTime(2026, 6, 5),
                    mealPlanId: 'plan-001',
                    assignments: captureAny(named: 'assignments'),
                  ),
                ).captured.single
                as List<RecipeAssignment>;
        expect(captured, hasLength(2));
        final byId = {for (final a in captured) a.recipeId: a.dayOffset};
        expect(byId['r-A'], 0);
        expect(byId['r-B'], 3);
        expect(recorderCalls, isEmpty);
      },
    );

    test('failure: sets errorMessage, returns false, records non-fatal via '
        'injected MealPrepCrashRecorderFn', () async {
      final args = makeArgs();
      stubCreatePlanSuccess();
      when(
        () => mockMealPlanService.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          mealPlanId: any(named: 'mealPlanId'),
          assignments: any(named: 'assignments'),
        ),
      ).thenAnswer((_) async => const Result.failure(ServerException('boom')));

      final container = buildContainer();
      final notifier = container.read(mapMealsControllerProvider(args).notifier)
        ..assignToSelectedDay('r-A', 99);

      final ok = await notifier.commit();

      expect(ok, isFalse);
      final state = container.read(mapMealsControllerProvider(args));
      expect(state.errorMessage, 'boom');
      expect(state.isCommitting, isFalse);

      expect(recorderCalls, hasLength(1));
      expect(recorderCalls.single.reason, 'meal_prep_commit_failure');
      expect(
        recorderCalls.single.information,
        containsAll(<String>['recipe_count=1', 'day_count=7']),
      );
    });

    test(
      'createPlan failure short-circuits before append, records non-fatal',
      () async {
        final args = makeArgs();
        when(
          () => mockMealPlanService.createPlan(any(), any(), any()),
        ).thenAnswer(
          (_) async => const Result.failure(ServerException('nope')),
        );

        final container = buildContainer();
        final notifier = container.read(
          mapMealsControllerProvider(args).notifier,
        )..assignToSelectedDay('r-A', 99);

        final ok = await notifier.commit();

        expect(ok, isFalse);
        expect(
          container.read(mapMealsControllerProvider(args)).errorMessage,
          'nope',
        );
        verifyNever(
          () => mockMealPlanService.appendMealsToRange(
            babyId: any(named: 'babyId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            mealPlanId: any(named: 'mealPlanId'),
            assignments: any(named: 'assignments'),
          ),
        );
        expect(recorderCalls, hasLength(1));
      },
    );

    test('empty assignments still creates the plan and returns true '
        '(partial/empty mapping allowed)', () async {
      final args = makeArgs();
      stubCreatePlanSuccess();
      when(
        () => mockMealPlanService.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          mealPlanId: any(named: 'mealPlanId'),
          assignments: any(named: 'assignments'),
        ),
      ).thenAnswer((_) async => const Result.success([]));

      final container = buildContainer();
      final notifier = container.read(
        mapMealsControllerProvider(args).notifier,
      );

      final ok = await notifier.commit();

      expect(ok, isTrue);
      verify(
        () => mockMealPlanService.createPlan(any(), any(), any()),
      ).called(1);
      final captured =
          verify(
                () => mockMealPlanService.appendMealsToRange(
                  babyId: any(named: 'babyId'),
                  startDate: any(named: 'startDate'),
                  endDate: any(named: 'endDate'),
                  mealPlanId: 'plan-001',
                  assignments: captureAny(named: 'assignments'),
                ),
              ).captured.single
              as List<RecipeAssignment>;
      expect(captured, isEmpty);
    });
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
