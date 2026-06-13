import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/allergen/complete/allergen_complete_controller.dart';

class _MockAllergenService extends Mock implements AllergenService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

const _babyId = 'baby-001';

final _baby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

const _peanut = Allergen(
  key: 'peanut',
  name: 'Peanut',
  sequenceOrder: 1,
  emoji: '🥜',
);

const _egg = Allergen(
  key: 'egg',
  name: 'Egg',
  sequenceOrder: 2,
  emoji: '🥚',
);

AllergenBoardItem _boardItem(Allergen allergen) => AllergenBoardItem(
  allergen: allergen,
  logs: const [],
  status: AllergenStatus.safe,
);

void main() {
  late _MockAllergenService allergenSvc;
  late _MockBabyProfileService babySvc;
  late _MockLocalFlagService localFlags;

  setUp(() {
    allergenSvc = _MockAllergenService();
    babySvc = _MockBabyProfileService();
    localFlags = _MockLocalFlagService();
    when(() => babySvc.getBaby()).thenAnswer((_) async => _baby);
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        allergenServiceProvider.overrideWithValue(allergenSvc),
        babyProfileServiceProvider.overrideWithValue(babySvc),
        localFlagServiceProvider.overrideWithValue(localFlags),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('build()', () {
    test('returns state with correct babyName and babyId', () async {
      when(
        () => allergenSvc.getAllergenBoardSummary(any()),
      ).thenAnswer(
        (_) async => Result.success([_boardItem(_peanut)]),
      );

      final state = await makeContainer()
          .read(allergenCompleteControllerProvider.future);

      expect(state.babyName, 'Lily');
      expect(state.babyId, _babyId);
      expect(state.allergens, [_peanut]);
    });

    test('sorts allergens by sequenceOrder ascending', () async {
      when(
        () => allergenSvc.getAllergenBoardSummary(any()),
      ).thenAnswer(
        (_) async =>
            Result.success([_boardItem(_egg), _boardItem(_peanut)]),
      );

      final state = await makeContainer()
          .read(allergenCompleteControllerProvider.future);

      expect(state.allergens.first.sequenceOrder, 1);
      expect(state.allergens.last.sequenceOrder, 2);
    });

    test('enters error state when baby is null', () async {
      when(() => babySvc.getBaby()).thenAnswer((_) async => null);

      final c = makeContainer();
      await expectLater(
        c.read(allergenCompleteControllerProvider.notifier).future,
        throwsA(isA<UnknownException>()),
      );

      expect(
        c.read(allergenCompleteControllerProvider).hasError,
        isTrue,
      );
    });

    test('enters error state on getAllergenBoardSummary failure', () async {
      const error = ServerException('service unavailable');
      when(
        () => allergenSvc.getAllergenBoardSummary(any()),
      ).thenAnswer(
        (_) async => const Result.failure(error),
      );

      final c = makeContainer();
      await expectLater(
        c.read(allergenCompleteControllerProvider.notifier).future,
        throwsA(isA<ServerException>()),
      );

      expect(
        c.read(allergenCompleteControllerProvider).hasError,
        isTrue,
      );
    });
  });

  group('markShown()', () {
    test('calls setProgramCompletionShown with babyId', () async {
      when(
        () => allergenSvc.getAllergenBoardSummary(any()),
      ).thenAnswer(
        (_) async => Result.success([_boardItem(_peanut)]),
      );
      when(
        () => localFlags.setProgramCompletionShown(any()),
      ).thenAnswer((_) {});

      final c = makeContainer();
      await c.read(allergenCompleteControllerProvider.future);
      c
          .read(allergenCompleteControllerProvider.notifier)
          .markShown();

      verify(
        () => localFlags.setProgramCompletionShown(_babyId),
      ).called(1);
    });

    test('is a no-op when build errored', () async {
      when(() => babySvc.getBaby()).thenAnswer((_) async => null);

      final c = makeContainer();
      await expectLater(
        c.read(allergenCompleteControllerProvider.notifier).future,
        throwsA(isA<Object>()),
      );

      c
          .read(allergenCompleteControllerProvider.notifier)
          .markShown();

      verifyNever(
        () => localFlags.setProgramCompletionShown(any()),
      );
    });
  });
}
