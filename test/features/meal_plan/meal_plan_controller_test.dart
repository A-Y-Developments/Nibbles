import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
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
import 'package:nibbles/src/features/meal_plan/meal_plan_controller.dart';
import 'package:nibbles/src/logging/analytics.dart';

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
  howToServe: 'Serve mashed.',
);

AllergenProgramState _makeProgramState({
  AllergenProgramStatus status = AllergenProgramStatus.inProgress,
  String currentKey = 'peanut',
}) {
  final now = DateTime(2026, 5, 30);
  return AllergenProgramState(
    id: 'ps-1',
    babyId: _babyId,
    currentAllergenKey: currentKey,
    currentSequenceOrder: 1,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

MealPlanEntry _makeEntry({
  String id = 'mp-1',
  String recipeId = 'recipe-001',
  DateTime? planDate,
}) => MealPlanEntry(
  id: id,
  babyId: _babyId,
  recipeId: recipeId,
  planDate: planDate ?? DateTime(2026, 5, 30),
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

  tearDown(() {
    MealPlanController.nowBuilder = DateTime.now;
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        babyProfileServiceProvider.overrideWithValue(mockBabyService),
        mealPlanServiceProvider.overrideWithValue(mockMealPlanService),
        recipeServiceProvider.overrideWithValue(mockRecipeService),
        allergenServiceProvider.overrideWithValue(mockAllergenService),
        analyticsProvider.overrideWithValue(fakeAnalytics),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  void stubHappy({
    List<MealPlanEntry> entries = const [],
    AllergenProgramState? programState,
  }) {
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(
      () => mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
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

  group('MealPlanController.build', () {
    test('NIB-159: windowStart is today (date-only), windowEnd is today + 6, '
        'populates entries + baby, expanded starts empty', () async {
      final entry = _makeEntry();
      stubHappy(entries: [entry]);

      final container = buildContainer();
      final state = await container.read(
        mealPlanControllerProvider(_babyId).future,
      );

      final today = DateTime.now();
      final expectedStart = DateTime(today.year, today.month, today.day);
      final expectedEnd = expectedStart.add(const Duration(days: 6));

      expect(state.windowStart, expectedStart);
      expect(state.windowEnd, expectedEnd);
      expect(state.windowEnd.difference(state.windowStart).inDays, 6);
      expect(state.entries, hasLength(1));
      expect(state.entries.single.id, 'mp-1');
      expect(state.baby?.id, _babyId);
      expect(state.expanded, isEmpty);
      expect(state.recipes['recipe-001']?.title, 'Peanut Butter Toast');
    });

    test('NIB-159: getRolling7 is invoked with today as windowStart, '
        'not the Monday-snapped week start', () async {
      stubHappy();
      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final today = DateTime.now();
      final expectedStart = DateTime(today.year, today.month, today.day);

      verify(
        () => mockMealPlanService.getRolling7(_babyId, today: expectedStart),
      ).called(1);
    });

    test(
      'NIB-159 regression: a plan starting Thu 11 Jun renders exactly '
      '11..17, not the Mon 8–Sun 14 calendar week',
      () async {
        // Fix "now" to Thu 11 Jun 2026 — the exact repro from the ticket.
        MealPlanController.nowBuilder = () => DateTime(2026, 6, 11, 9, 30);
        expect(DateTime(2026, 6, 11).weekday, DateTime.thursday);

        // Entry on the last selected day (17th) — invisible under Monday-snap.
        stubHappy(entries: [_makeEntry(planDate: DateTime(2026, 6, 17))]);

        final container = buildContainer();
        final state = await container.read(
          mealPlanControllerProvider(_babyId).future,
        );

        expect(state.windowStart, DateTime(2026, 6, 11));
        expect(state.windowEnd, DateTime(2026, 6, 17));

        // The rendered day list (screen derives it from windowStart..windowEnd)
        // must be exactly 11..17 inclusive.
        final start = DateTime(
          state.windowStart.year,
          state.windowStart.month,
          state.windowStart.day,
        );
        final count = state.windowEnd.difference(start).inDays + 1;
        final days = [
          for (var i = 0; i < count; i++) start.add(Duration(days: i)),
        ];
        expect(days, [
          DateTime(2026, 6, 11),
          DateTime(2026, 6, 12),
          DateTime(2026, 6, 13),
          DateTime(2026, 6, 14),
          DateTime(2026, 6, 15),
          DateTime(2026, 6, 16),
          DateTime(2026, 6, 17),
        ]);
        // Monday-snap bug days must NOT appear; selected tail days must.
        expect(days.contains(DateTime(2026, 6, 8)), isFalse);
        expect(days.contains(DateTime(2026, 6, 9)), isFalse);
        expect(days.contains(DateTime(2026, 6, 10)), isFalse);
        expect(days.contains(DateTime(2026, 6, 15)), isTrue);
        expect(days.contains(DateTime(2026, 6, 16)), isTrue);
        expect(days.contains(DateTime(2026, 6, 17)), isTrue);
      },
    );

    test('build() with getRolling7 failure surfaces AsyncError', () async {
      when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
      when(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).thenAnswer(
        (_) async => const Result.failure(ServerException('db down')),
      );
      when(
        () => mockRecipeService.getFlaggedAllergenKeys(any()),
      ).thenAnswer((_) async => const Result.success(<String>{}));
      when(
        () => mockAllergenService.getProgramState(any()),
      ).thenAnswer((_) async => Result.success(_makeProgramState()));

      final container = buildContainer();
      await expectLater(
        container.read(mealPlanControllerProvider(_babyId).future),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('MealPlanController.toggleExpanded', () {
    test('flips a day key WITHOUT re-fetching from the service', () async {
      stubHappy();
      final container = buildContainer();
      // Initial build
      await container.read(mealPlanControllerProvider(_babyId).future);

      final notifier = container.read(
        mealPlanControllerProvider(_babyId).notifier,
      );

      final day = DateTime(2026, 5, 30);
      final key = DateTime.utc(2026, 5, 30);

      notifier.toggleExpanded(day);
      var state = container
          .read(mealPlanControllerProvider(_babyId))
          .valueOrNull!;
      expect(state.expanded[key], isTrue);

      notifier.toggleExpanded(day);
      state = container.read(mealPlanControllerProvider(_babyId)).valueOrNull!;
      expect(state.expanded[key], isFalse);

      // Toggle does not refetch.
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(1);
    });
  });

  group('MealPlanController.appendBulkPrep', () {
    test('returns true on success and invalidates self (refetches)', () async {
      stubHappy();
      when(
        () => mockMealPlanService.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          assignments: any(named: 'assignments'),
        ),
      ).thenAnswer((_) async => const Result.success([]));

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final notifier = container.read(
        mealPlanControllerProvider(_babyId).notifier,
      );

      final ok = await notifier.appendBulkPrep(
        startDate: DateTime(2026, 5, 30),
        endDate: DateTime(2026, 5, 30),
        assignments: const [
          RecipeAssignment(recipeId: 'recipe-001', dayOffset: 0),
        ],
      );

      // Re-await the future so the invalidate-driven rebuild settles.
      await container.read(mealPlanControllerProvider(_babyId).future);

      expect(ok, isTrue);
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(2);
    });

    test('returns false on failure and does NOT invalidate self', () async {
      stubHappy();
      when(
        () => mockMealPlanService.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          assignments: any(named: 'assignments'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(ServerException('db down')),
      );

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final notifier = container.read(
        mealPlanControllerProvider(_babyId).notifier,
      );
      final ok = await notifier.appendBulkPrep(
        startDate: DateTime(2026, 5, 30),
        endDate: DateTime(2026, 5, 30),
        assignments: const [
          RecipeAssignment(recipeId: 'recipe-001', dayOffset: 0),
        ],
      );

      expect(ok, isFalse);
      // Only the initial build call — no invalidation.
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(1);
    });
  });

  group('MealPlanController.clearRange', () {
    test('returns true on success and invalidates self (refetches)', () async {
      stubHappy();
      when(
        () => mockMealPlanService.clearRange(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success(null));

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final notifier = container.read(
        mealPlanControllerProvider(_babyId).notifier,
      );
      final ok = await notifier.clearRange(
        DateTime(2026, 5, 30),
        DateTime(2026, 6, 5),
      );
      await container.read(mealPlanControllerProvider(_babyId).future);

      expect(ok, isTrue);
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(2);
    });

    test('returns false on failure and does NOT invalidate self', () async {
      stubHappy();
      when(
        () => mockMealPlanService.clearRange(any(), any(), any()),
      ).thenAnswer(
        (_) async => const Result.failure(ServerException('db down')),
      );

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final notifier = container.read(
        mealPlanControllerProvider(_babyId).notifier,
      );
      final ok = await notifier.clearRange(
        DateTime(2026, 5, 30),
        DateTime(2026, 6, 5),
      );

      expect(ok, isFalse);
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(1);
    });
  });

  group('MealPlanController.assignRecipe', () {
    test('returns true on success and invalidates self', () async {
      stubHappy();
      when(
        () => mockMealPlanService.assignRecipe(any(), any(), any()),
      ).thenAnswer((_) async => Result.success(_makeEntry()));

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .assignRecipe(DateTime(2026, 5, 30), 'recipe-001');
      await container.read(mealPlanControllerProvider(_babyId).future);

      expect(ok, isTrue);
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(2);
    });

    test('returns false on failure, does NOT invalidate self', () async {
      stubHappy();
      when(
        () => mockMealPlanService.assignRecipe(any(), any(), any()),
      ).thenAnswer(
        (_) async => const Result.failure(ServerException('assign failed')),
      );

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .assignRecipe(DateTime(2026, 5, 30), 'recipe-001');

      expect(ok, isFalse);
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(1);
    });
  });

  group('MealPlanController.removeEntry', () {
    test('returns true on success and invalidates self', () async {
      stubHappy();
      when(
        () => mockMealPlanService.removeEntry(any()),
      ).thenAnswer((_) async => const Result<void>.success(null));

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .removeEntry('mp-1');
      await container.read(mealPlanControllerProvider(_babyId).future);

      expect(ok, isTrue);
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(2);
    });

    test('returns false on failure, does NOT invalidate self', () async {
      stubHappy();
      when(() => mockMealPlanService.removeEntry(any())).thenAnswer(
        (_) async =>
            const Result<void>.failure(ServerException('delete failed')),
      );

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .removeEntry('mp-1');

      expect(ok, isFalse);
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(1);
    });
  });

  group('MealPlanController.clearDay', () {
    test('returns true on success and invalidates self', () async {
      stubHappy();
      when(
        () => mockMealPlanService.clearDay(any(), any()),
      ).thenAnswer((_) async => const Result<void>.success(null));

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .clearDay(DateTime(2026, 5, 30));
      await container.read(mealPlanControllerProvider(_babyId).future);

      expect(ok, isTrue);
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(2);
    });

    test('returns false on failure, does NOT invalidate self', () async {
      stubHappy();
      when(() => mockMealPlanService.clearDay(any(), any())).thenAnswer(
        (_) async =>
            const Result<void>.failure(ServerException('clear failed')),
      );

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .clearDay(DateTime(2026, 5, 30));

      expect(ok, isFalse);
      verify(
        () =>
            mockMealPlanService.getRolling7(any(), today: any(named: 'today')),
      ).called(1);
    });
  });
}
