import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/allergen_repository.dart';
import 'package:nibbles/src/common/data/repositories/storage_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';

class MockAllergenRepository extends Mock implements AllergenRepository {}

class MockStorageRepository extends Mock implements StorageRepository {}

const _babyId = 'baby-001';
const _peanutKey = 'peanut';
final _now = DateTime(2026, 3, 24);

final _allergens = [
  const Allergen(key: 'peanut', name: 'Peanut', sequenceOrder: 1, emoji: '🥜'),
  const Allergen(key: 'egg', name: 'Egg', sequenceOrder: 2, emoji: '🥚'),
  const Allergen(key: 'dairy', name: 'Dairy', sequenceOrder: 3, emoji: '🥛'),
  const Allergen(
    key: 'tree_nuts',
    name: 'Tree Nuts',
    sequenceOrder: 4,
    emoji: '🌰',
  ),
  const Allergen(key: 'sesame', name: 'Sesame', sequenceOrder: 5, emoji: '🫘'),
  const Allergen(key: 'soy', name: 'Soy', sequenceOrder: 6, emoji: '🫘'),
  const Allergen(key: 'wheat', name: 'Wheat', sequenceOrder: 7, emoji: '🌾'),
  const Allergen(key: 'fish', name: 'Fish', sequenceOrder: 8, emoji: '🐟'),
  const Allergen(
    key: 'shellfish',
    name: 'Shellfish',
    sequenceOrder: 9,
    emoji: '🦐',
  ),
];

AllergenLog _makeLog({
  String id = 'log-1',
  String allergenKey = _peanutKey,
  bool hadReaction = false,
}) => AllergenLog(
  id: id,
  babyId: _babyId,
  allergenKey: allergenKey,
  emojiTaste: EmojiTaste.love,
  hadReaction: hadReaction,
  logDate: _now,
  createdAt: _now,
);

AllergenProgramState _makeProgramState({
  String currentAllergenKey = _peanutKey,
  int currentSequenceOrder = 1,
}) => AllergenProgramState(
  id: 'ps-1',
  babyId: _babyId,
  currentAllergenKey: currentAllergenKey,
  currentSequenceOrder: currentSequenceOrder,
  status: AllergenProgramStatus.inProgress,
  createdAt: _now,
  updatedAt: _now,
);

void main() {
  late MockAllergenRepository mockRepo;
  late MockStorageRepository mockStorage;
  late AllergenService sut;

  setUpAll(() {
    registerFallbackValue(_makeLog());
    registerFallbackValue(
      ReactionDetail(
        id: '',
        logId: 'log-1',
        severity: ReactionSeverity.mild,
        symptoms: const [],
        createdAt: _now,
      ),
    );
    registerFallbackValue(_now);
  });

  setUp(() {
    mockRepo = MockAllergenRepository();
    mockStorage = MockStorageRepository();
    sut = AllergenService(mockRepo, mockStorage);
  });

  // ---------------------------------------------------------------------------
  // saveAllergenLog
  // ---------------------------------------------------------------------------

  group('AllergenService.saveAllergenLog', () {
    test('success path: log inserted, returns AllergenLog', () async {
      final saved = _makeLog(id: 'log-saved');
      when(
        () => mockRepo.saveLog(any()),
      ).thenAnswer((_) async => Result.success(saved));

      final result = await sut.saveAllergenLog(
        babyId: _babyId,
        allergenKey: _peanutKey,
        emojiTaste: EmojiTaste.love,
        hadReaction: false,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, saved);
      verify(() => mockRepo.saveLog(any())).called(1);
      verifyNever(() => mockRepo.saveReactionDetail(any()));
    });

    test(
      'hadReaction=true without reactionDetail: saves log, no detail insert',
      () async {
        final saved = _makeLog(id: 'log-react', hadReaction: true);
        when(
          () => mockRepo.saveLog(any()),
        ).thenAnswer((_) async => Result.success(saved));

        final result = await sut.saveAllergenLog(
          babyId: _babyId,
          allergenKey: _peanutKey,
          emojiTaste: EmojiTaste.neutral,
          hadReaction: true,
          // reactionDetail deliberately omitted — optional at service level
        );

        expect(result.isSuccess, isTrue);
        verify(() => mockRepo.saveLog(any())).called(1);
        verifyNever(() => mockRepo.saveReactionDetail(any()));
      },
    );

    test(
      'hadReaction=true with reactionDetail: saves log AND reaction detail',
      () async {
        final savedLog = _makeLog(id: 'log-react', hadReaction: true);
        final detail = ReactionDetail(
          id: '',
          logId: '',
          severity: ReactionSeverity.mild,
          symptoms: const ['Rash'],
          createdAt: _now,
        );
        final savedDetail = detail.copyWith(id: 'det-1', logId: 'log-react');
        when(
          () => mockRepo.saveLog(any()),
        ).thenAnswer((_) async => Result.success(savedLog));
        when(
          () => mockRepo.saveReactionDetail(any()),
        ).thenAnswer((_) async => Result.success(savedDetail));

        final result = await sut.saveAllergenLog(
          babyId: _babyId,
          allergenKey: _peanutKey,
          emojiTaste: EmojiTaste.neutral,
          hadReaction: true,
          reactionDetail: detail,
        );

        expect(result.isSuccess, isTrue);
        verify(() => mockRepo.saveReactionDetail(any())).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // deriveStatus
  // ---------------------------------------------------------------------------

  group('AllergenService.deriveStatus', () {
    test('0 logs → notStarted', () {
      expect(sut.deriveStatus([]), AllergenStatus.notStarted);
    });

    test('1 log, no reaction → inProgress', () {
      expect(sut.deriveStatus([_makeLog()]), AllergenStatus.inProgress);
    });

    test('2 logs, no reaction → inProgress', () {
      expect(
        sut.deriveStatus([_makeLog(id: 'l1'), _makeLog(id: 'l2')]),
        AllergenStatus.inProgress,
      );
    });

    test('3 logs, all no reaction → safe (never completed)', () {
      final logs = [_makeLog(id: 'l1'), _makeLog(id: 'l2'), _makeLog(id: 'l3')];
      final status = sut.deriveStatus(logs);
      expect(status, AllergenStatus.safe);
      // Canonical rule: passed allergens are `safe`, NEVER `completed`.
      expect(
        AllergenStatus.values.map((e) => e.name),
        isNot(contains('completed')),
      );
    });

    test('any log with hadReaction=true → flagged', () {
      final logs = [_makeLog(id: 'l1'), _makeLog(id: 'l2', hadReaction: true)];
      expect(sut.deriveStatus(logs), AllergenStatus.flagged);
    });

    test('first-day reaction (1 log, hadReaction=true) → flagged', () {
      expect(
        sut.deriveStatus([_makeLog(hadReaction: true)]),
        AllergenStatus.flagged,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getAllergenBoardSummary
  // ---------------------------------------------------------------------------

  group('AllergenService.getAllergenBoardSummary', () {
    test('returns 9 items in sequence order', () async {
      when(
        () => mockRepo.getAllergens(),
      ).thenAnswer((_) async => Result.success(_allergens));
      when(
        () => mockRepo.getLogs(any()),
      ).thenAnswer((_) async => const Result.success([]));

      final result = await sut.getAllergenBoardSummary(_babyId);

      expect(result.isSuccess, isTrue);
      final items = result.dataOrNull!;
      expect(items.length, 9);
      expect(items.first.allergen.key, 'peanut');
      expect(items.last.allergen.key, 'shellfish');
    });

    test('logs are correctly bucketed per allergen', () async {
      final peanutLog = _makeLog(id: 'log-p1');
      final eggLog = _makeLog(id: 'log-e1', allergenKey: 'egg');

      when(
        () => mockRepo.getAllergens(),
      ).thenAnswer((_) async => Result.success(_allergens));
      when(
        () => mockRepo.getLogs(any()),
      ).thenAnswer((_) async => Result.success([peanutLog, eggLog]));

      final result = await sut.getAllergenBoardSummary(_babyId);

      final items = result.dataOrNull!;
      final peanutItem = items.firstWhere((i) => i.allergen.key == 'peanut');
      final eggItem = items.firstWhere((i) => i.allergen.key == 'egg');
      final dairyItem = items.firstWhere((i) => i.allergen.key == 'dairy');

      expect(peanutItem.logs, hasLength(1));
      expect(eggItem.logs, hasLength(1));
      expect(dairyItem.logs, isEmpty);
    });

    test('returns Failure when allergens fetch fails', () async {
      when(() => mockRepo.getAllergens()).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.getAllergenBoardSummary(_babyId);

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // advanceToNextAllergen
  // ---------------------------------------------------------------------------

  group('AllergenService.advanceToNextAllergen', () {
    test(
      'advances currentAllergenKey to next in sequence (peanut → egg)',
      () async {
        when(
          () => mockRepo.getProgramState(any()),
        ).thenAnswer((_) async => Result.success(_makeProgramState()));
        when(
          () => mockRepo.getAllergens(),
        ).thenAnswer((_) async => Result.success(_allergens));
        when(
          () => mockRepo.advanceProgramState(any(), any(), any()),
        ).thenAnswer((_) async => const Result.success(null));

        final result = await sut.advanceToNextAllergen(_babyId);

        expect(result.isSuccess, isTrue);
        verify(() => mockRepo.advanceProgramState(_babyId, 'egg', 2)).called(1);
        verifyNever(() => mockRepo.completeProgramState(any()));
      },
    );

    test(
      'after Shellfish (last allergen) → calls completeProgramState',
      () async {
        when(() => mockRepo.getProgramState(any())).thenAnswer(
          (_) async => Result.success(
            _makeProgramState(
              currentAllergenKey: 'shellfish',
              currentSequenceOrder: 9,
            ),
          ),
        );
        when(
          () => mockRepo.getAllergens(),
        ).thenAnswer((_) async => Result.success(_allergens));
        when(
          () => mockRepo.completeProgramState(any()),
        ).thenAnswer((_) async => const Result.success(null));

        final result = await sut.advanceToNextAllergen(_babyId);

        expect(result.isSuccess, isTrue);
        verify(() => mockRepo.completeProgramState(_babyId)).called(1);
        verifyNever(() => mockRepo.advanceProgramState(any(), any(), any()));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // completeProgram
  // ---------------------------------------------------------------------------

  group('AllergenService.completeProgram', () {
    test('delegates to completeProgramState on repository', () async {
      when(
        () => mockRepo.completeProgramState(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.completeProgram(_babyId);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.completeProgramState(_babyId)).called(1);
    });

    test('propagates repository failure', () async {
      when(() => mockRepo.completeProgramState(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('DB write failed')),
      );

      final result = await sut.completeProgram(_babyId);

      expect(result.isFailure, isTrue);
    });
  });
}
