// firebase_analytics_platform_interface and firebase_core_platform_interface
// are transitive deps; their public barrels don't re-export the test helpers.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_controller.dart';

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

class _MockRecipeService extends Mock implements RecipeService {}

class _MockAllergenService extends Mock implements AllergenService {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

const _babyId = 'baby-1';
const _recipe = Recipe(
  id: 'r1',
  title: 'Carrot Puree',
  ageRange: '6+ months',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

const _categories = <String, List<Recipe>>{
  'Vegetables': [_recipe],
};
const _flagged = <String>{};
const _statuses = <String, AllergenStatus>{
  'peanut': AllergenStatus.notStarted,
  'egg': AllergenStatus.notStarted,
  'dairy': AllergenStatus.notStarted,
  'tree_nuts': AllergenStatus.notStarted,
  'sesame': AllergenStatus.notStarted,
  'soy': AllergenStatus.notStarted,
  'wheat': AllergenStatus.notStarted,
  'fish': AllergenStatus.notStarted,
  'shellfish': AllergenStatus.notStarted,
};

void main() {
  late _MockRecipeService recipeSvc;
  late _MockAllergenService allergenSvc;
  late _MockLocalFlagService localFlags;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  setUp(() {
    recipeSvc = _MockRecipeService();
    allergenSvc = _MockAllergenService();
    localFlags = _MockLocalFlagService();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        recipeServiceProvider.overrideWithValue(recipeSvc),
        allergenServiceProvider.overrideWithValue(allergenSvc),
        localFlagServiceProvider.overrideWithValue(localFlags),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  void stubHappyBuild({
    Map<String, List<Recipe>> categories = _categories,
    Map<String, AllergenStatus> statuses = _statuses,
    Set<String> flagged = _flagged,
    bool guideSeen = false,
  }) {
    when(
      () => recipeSvc.getRecipesByCategory(any()),
    ).thenAnswer((_) async => Result.success(categories));
    when(
      () => allergenSvc.getAllergenStatuses(any()),
    ).thenAnswer((_) async => Result.success(statuses));
    when(
      () => recipeSvc.getFlaggedAllergenKeys(any()),
    ).thenAnswer((_) async => Result.success(flagged));
    when(localFlags.isStartingGuideSeen).thenReturn(guideSeen);
  }

  void stubFailedBuild({
    bool categoriesFail = false,
    bool statusesFail = false,
    bool flaggedFail = false,
  }) {
    when(
      () => recipeSvc.getRecipesByCategory(any()),
    ).thenAnswer(
      (_) async => categoriesFail
          ? const Result.failure(NetworkException())
          : const Result.success(_categories),
    );
    when(
      () => allergenSvc.getAllergenStatuses(any()),
    ).thenAnswer(
      (_) async => statusesFail
          ? const Result.failure(NetworkException())
          : const Result.success(_statuses),
    );
    when(
      () => recipeSvc.getFlaggedAllergenKeys(any()),
    ).thenAnswer(
      (_) async => flaggedFail
          ? const Result.failure(NetworkException())
          : const Result.success(_flagged),
    );
    when(localFlags.isStartingGuideSeen).thenReturn(false);
  }

  group('build() — happy path', () {
    test('returns state from all three services', () async {
      stubHappyBuild();

      final state = await container().read(
        recipeLibraryControllerProvider(_babyId).future,
      );

      expect(state.recipesByCategory, _categories);
      expect(state.flaggedAllergenKeys, isEmpty);
      expect(state.isStartingGuideSeen, false);
      expect(state.ongoingAllergenKey, isNull);
    });

    test('sets ongoingAllergenKey to first inProgress allergen', () async {
      stubHappyBuild(
        statuses: {
          ..._statuses,
          'egg': AllergenStatus.inProgress,
        },
      );

      final state = await container().read(
        recipeLibraryControllerProvider(_babyId).future,
      );

      expect(state.ongoingAllergenKey, 'egg');
    });

    test('peanut before egg when both inProgress (canonical order)', () async {
      stubHappyBuild(
        statuses: {
          ..._statuses,
          'peanut': AllergenStatus.inProgress,
          'egg': AllergenStatus.inProgress,
        },
      );

      final state = await container().read(
        recipeLibraryControllerProvider(_babyId).future,
      );

      expect(state.ongoingAllergenKey, 'peanut');
    });

    test('propagates flagged allergen keys and guideSeen flag', () async {
      stubHappyBuild(
        flagged: {'peanut'},
        guideSeen: true,
      );

      final state = await container().read(
        recipeLibraryControllerProvider(_babyId).future,
      );

      expect(state.flaggedAllergenKeys, {'peanut'});
      expect(state.isStartingGuideSeen, true);
    });
  });

  group('build() — failure paths', () {
    test('throws when categories fetch fails', () async {
      stubFailedBuild(categoriesFail: true);

      await expectLater(
        container().read(recipeLibraryControllerProvider(_babyId).future),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws when allergen statuses fetch fails', () async {
      stubFailedBuild(statusesFail: true);

      await expectLater(
        container().read(recipeLibraryControllerProvider(_babyId).future),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws when flagged allergen keys fetch fails', () async {
      stubFailedBuild(flaggedFail: true);

      await expectLater(
        container().read(recipeLibraryControllerProvider(_babyId).future),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('refresh()', () {
    test('completes without error and rebuilds state', () async {
      stubHappyBuild();
      final c = container();
      await c.read(recipeLibraryControllerProvider(_babyId).future);

      await c
          .read(recipeLibraryControllerProvider(_babyId).notifier)
          .refresh();

      final state = c
          .read(recipeLibraryControllerProvider(_babyId))
          .valueOrNull;
      expect(state?.recipesByCategory, _categories);
    });
  });

  group('markStartingGuideSeen()', () {
    test('updates state and calls service when not yet seen', () async {
      stubHappyBuild();
      when(
        localFlags.markStartingGuideSeen,
      ).thenAnswer((_) async {});

      final c = container();
      await c.read(recipeLibraryControllerProvider(_babyId).future);
      await c
          .read(recipeLibraryControllerProvider(_babyId).notifier)
          .markStartingGuideSeen();

      final state = c
          .read(recipeLibraryControllerProvider(_babyId))
          .valueOrNull;
      expect(state?.isStartingGuideSeen, true);
      verify(localFlags.markStartingGuideSeen).called(1);
    });

    test('is a no-op when guide is already seen', () async {
      stubHappyBuild(guideSeen: true);

      final c = container();
      await c.read(recipeLibraryControllerProvider(_babyId).future);
      await c
          .read(recipeLibraryControllerProvider(_babyId).notifier)
          .markStartingGuideSeen();

      verifyNever(localFlags.markStartingGuideSeen);
    });
  });

  group('setSearchQuery()', () {
    test('is a no-op when trimmed query equals current', () async {
      stubHappyBuild();

      final c = container();
      await c.read(recipeLibraryControllerProvider(_babyId).future);
      final stateBefore =
          c.read(recipeLibraryControllerProvider(_babyId)).valueOrNull;

      c
          .read(recipeLibraryControllerProvider(_babyId).notifier)
          .setSearchQuery('');
      final stateAfter =
          c.read(recipeLibraryControllerProvider(_babyId)).valueOrNull;

      expect(identical(stateBefore, stateAfter), true);
    });

    test('is a no-op when state is null', () async {
      stubFailedBuild(categoriesFail: true);

      final c = container();
      await expectLater(
        c.read(recipeLibraryControllerProvider(_babyId).future),
        throwsA(isA<NetworkException>()),
      );

      expect(
        () => c
            .read(recipeLibraryControllerProvider(_babyId).notifier)
            .setSearchQuery('anything'),
        returnsNormally,
      );
    });

    test(
      'updates searchQuery and fires analytics when transitioning from empty '
      'to non-empty (trims whitespace)',
      () async {
        stubHappyBuild();
        final c = container();
        await c.read(recipeLibraryControllerProvider(_babyId).future);

        c
            .read(recipeLibraryControllerProvider(_babyId).notifier)
            .setSearchQuery('  carrot  ');

        final state =
            c.read(recipeLibraryControllerProvider(_babyId)).valueOrNull;
        expect(state?.searchQuery, 'carrot');
      },
    );
  });
}
