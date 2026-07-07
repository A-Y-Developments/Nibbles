import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
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

final _defaultPlan = MealPlan(
  id: 'plan-1',
  babyId: _babyId,
  startDate: DateTime(2026, 5, 30),
  endDate: DateTime(2026, 6, 5),
  createdAt: DateTime(2026, 5, 29),
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
    MealPlan? plan,
    bool hasPlan = true,
  }) {
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(() => mockMealPlanService.getActivePlan(any())).thenAnswer(
      (_) async => Result.success(hasPlan ? (plan ?? _defaultPlan) : null),
    );
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

  group('MealPlanController.build', () {
    test('active plan → window is the plan range, populates entries + '
        'baby + plan, expanded starts empty', () async {
      final entry = _makeEntry();
      stubHappy(entries: [entry]);

      final container = buildContainer();
      final state = await container.read(
        mealPlanControllerProvider(_babyId).future,
      );

      expect(state.plan?.id, 'plan-1');
      expect(state.windowStart, DateTime(2026, 5, 30));
      expect(state.windowEnd, DateTime(2026, 6, 5));
      expect(state.entries, hasLength(1));
      expect(state.entries.single.id, 'mp-1');
      expect(state.baby?.id, _babyId);
      expect(state.expanded, isEmpty);
      expect(state.recipes['recipe-001']?.title, 'Peanut Butter Toast');
    });

    test('no active plan → plan null, entries empty', () async {
      stubHappy(hasPlan: false);

      final container = buildContainer();
      final state = await container.read(
        mealPlanControllerProvider(_babyId).future,
      );

      expect(state.plan, isNull);
      expect(state.entries, isEmpty);
      // getEntriesForPlan is not called when there is no plan.
      verifyNever(() => mockMealPlanService.getEntriesForPlan(any()));
    });

    test('getEntriesForPlan is invoked with the active plan id', () async {
      stubHappy();
      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      verify(() => mockMealPlanService.getEntriesForPlan('plan-1')).called(1);
    });

    test('window end extends to cover an entry past the plan end', () async {
      stubHappy(
        plan: MealPlan(
          id: 'plan-2',
          babyId: _babyId,
          startDate: DateTime(2026, 6, 11),
          endDate: DateTime(2026, 6, 13),
          createdAt: DateTime(2026, 6, 10),
        ),
        entries: [_makeEntry(planDate: DateTime(2026, 6, 17))],
      );

      final container = buildContainer();
      final state = await container.read(
        mealPlanControllerProvider(_babyId).future,
      );

      expect(state.windowStart, DateTime(2026, 6, 11));
      expect(state.windowEnd, DateTime(2026, 6, 17));
    });

    test('build() with getActivePlan failure surfaces AsyncError', () async {
      when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
      when(() => mockMealPlanService.getActivePlan(any())).thenAnswer(
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

    test('getEntriesForPlan failure surfaces AsyncError', () async {
      stubHappy();
      when(() => mockMealPlanService.getEntriesForPlan(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('db down')),
      );

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

      verify(() => mockMealPlanService.getActivePlan(any())).called(1);
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
          mealPlanId: any(named: 'mealPlanId'),
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

      await container.read(mealPlanControllerProvider(_babyId).future);

      expect(ok, isTrue);
      // Passes the active plan id through to the append.
      verify(
        () => mockMealPlanService.appendMealsToRange(
          babyId: _babyId,
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          assignments: any(named: 'assignments'),
          mealPlanId: 'plan-1',
        ),
      ).called(1);
      verify(() => mockMealPlanService.getActivePlan(any())).called(2);
    });

    test('returns false on failure and does NOT invalidate self', () async {
      stubHappy();
      when(
        () => mockMealPlanService.appendMealsToRange(
          babyId: any(named: 'babyId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          assignments: any(named: 'assignments'),
          mealPlanId: any(named: 'mealPlanId'),
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
      verify(() => mockMealPlanService.getActivePlan(any())).called(1);
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
      verify(() => mockMealPlanService.getActivePlan(any())).called(2);
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
      verify(() => mockMealPlanService.getActivePlan(any())).called(1);
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
      verify(() => mockMealPlanService.getActivePlan(any())).called(2);
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
      verify(() => mockMealPlanService.getActivePlan(any())).called(1);
    });
  });

  group('MealPlanController.createPlan', () {
    test('returns true on success and invalidates self', () async {
      stubHappy(hasPlan: false);
      when(
        () => mockMealPlanService.createPlan(any(), any(), any()),
      ).thenAnswer((_) async => Result.success(_defaultPlan));

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .createPlan(DateTime(2026, 5, 30), DateTime(2026, 6, 5));
      await container.read(mealPlanControllerProvider(_babyId).future);

      expect(ok, isTrue);
      verify(
        () => mockMealPlanService.createPlan(
          _babyId,
          DateTime(2026, 5, 30),
          DateTime(2026, 6, 5),
        ),
      ).called(1);
      verify(() => mockMealPlanService.getActivePlan(any())).called(2);
    });

    test('returns false on failure and does NOT invalidate self', () async {
      stubHappy(hasPlan: false);
      when(
        () => mockMealPlanService.createPlan(any(), any(), any()),
      ).thenAnswer(
        (_) async => const Result.failure(ServerException('db down')),
      );

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .createPlan(DateTime(2026, 5, 30), DateTime(2026, 6, 5));

      expect(ok, isFalse);
      verify(() => mockMealPlanService.getActivePlan(any())).called(1);
    });
  });

  group('MealPlanController.deleteActivePlan', () {
    test('returns true on success and invalidates self', () async {
      stubHappy();
      when(
        () => mockMealPlanService.deletePlan(any()),
      ).thenAnswer((_) async => const Result<void>.success(null));

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .deleteActivePlan();
      await container.read(mealPlanControllerProvider(_babyId).future);

      expect(ok, isTrue);
      verify(() => mockMealPlanService.deletePlan('plan-1')).called(1);
      verify(() => mockMealPlanService.getActivePlan(any())).called(2);
    });

    test('returns false when there is no active plan', () async {
      stubHappy(hasPlan: false);

      final container = buildContainer();
      await container.read(mealPlanControllerProvider(_babyId).future);

      final ok = await container
          .read(mealPlanControllerProvider(_babyId).notifier)
          .deleteActivePlan();

      expect(ok, isFalse);
      verifyNever(() => mockMealPlanService.deletePlan(any()));
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
      verify(() => mockMealPlanService.getActivePlan(any())).called(2);
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
      verify(() => mockMealPlanService.getActivePlan(any())).called(1);
    });
  });
}
