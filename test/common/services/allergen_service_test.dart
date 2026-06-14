import 'dart:io';

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
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';

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
    registerFallbackValue(File('test-fallback.jpg'));
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
  // getAllergenStatuses (NIB-126: derived from logs, not program state)
  // ---------------------------------------------------------------------------

  group('AllergenService.getAllergenStatuses', () {
    test(
      'returns every canonical allergen key with the correct derived status '
      'and defaults absent allergens to notStarted',
      () async {
        final eggReaction = _makeLog(
          id: 'log-e1',
          allergenKey: 'egg',
          hadReaction: true,
        );
        final dairyClean1 = _makeLog(id: 'log-d1', allergenKey: 'dairy');
        final dairyClean2 = _makeLog(id: 'log-d2', allergenKey: 'dairy');
        final dairyClean3 = _makeLog(id: 'log-d3', allergenKey: 'dairy');
        final peanutClean = _makeLog(id: 'log-p1');

        when(() => mockRepo.getLogs(any())).thenAnswer(
          (_) async => Result.success([
            eggReaction,
            dairyClean1,
            dairyClean2,
            dairyClean3,
            peanutClean,
          ]),
        );

        final result = await sut.getAllergenStatuses(_babyId);

        expect(result.isSuccess, isTrue);
        final statuses = result.dataOrNull!;
        // Every canonical key is present.
        for (final key in kAllergenKeys) {
          expect(statuses.containsKey(key), isTrue, reason: 'missing $key');
        }
        // 3 clean dairy logs → safe.
        expect(statuses['dairy'], AllergenStatus.safe);
        // 1 reaction-flagged egg log → flagged.
        expect(statuses['egg'], AllergenStatus.flagged);
        // 1 clean peanut log → inProgress.
        expect(statuses['peanut'], AllergenStatus.inProgress);
        // Untouched allergens default to notStarted.
        expect(statuses['shellfish'], AllergenStatus.notStarted);
        expect(statuses['fish'], AllergenStatus.notStarted);
        // Only the bare-minimum repo call is used (no Supabase, no state read).
        verify(() => mockRepo.getLogs(_babyId)).called(1);
        verifyNever(() => mockRepo.getProgramState(any()));
      },
    );

    test('propagates repository failure', () async {
      when(() => mockRepo.getLogs(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.getAllergenStatuses(_babyId);

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

    test('returns failure when getProgramState fails', () async {
      when(
        () => mockRepo.getProgramState(any()),
      ).thenAnswer(
        (_) async => const Result.failure(NetworkException('offline')),
      );

      final result = await sut.advanceToNextAllergen(_babyId);

      expect(result.isFailure, isTrue);
      verifyNever(() => mockRepo.getAllergens());
    });

    test('returns failure when getAllergens fails', () async {
      when(
        () => mockRepo.getProgramState(any()),
      ).thenAnswer((_) async => Result.success(_makeProgramState()));
      when(
        () => mockRepo.getAllergens(),
      ).thenAnswer(
        (_) async => const Result.failure(NetworkException('offline')),
      );

      final result = await sut.advanceToNextAllergen(_babyId);

      expect(result.isFailure, isTrue);
      verifyNever(() => mockRepo.advanceProgramState(any(), any(), any()));
    });
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

  // ---------------------------------------------------------------------------
  // updateAllergenLog
  // ---------------------------------------------------------------------------

  group('AllergenService.updateAllergenLog', () {
    test(
      'no new photo: skips storage, calls repo.updateLog with input log',
      () async {
        final log = _makeLog();
        when(
          () => mockRepo.updateLog(any()),
        ).thenAnswer((_) async => Result.success(log));

        final result = await sut.updateAllergenLog(log: log);

        expect(result.isSuccess, isTrue);
        verify(() => mockRepo.updateLog(log)).called(1);
        verifyNever(() => mockStorage.uploadFile(any(), any(), any()));
        verifyNever(() => mockStorage.deleteFile(any(), any()));
      },
    );

    test(
      'new photo path: uploads new, deletes old non-fatal, '
      'calls updateLog with new photoUrl',
      () async {
        final log = _makeLog().copyWith(photoUrl: 'old/path.jpg');
        when(
          () => mockStorage.uploadFile(any(), any(), any()),
        ).thenAnswer((_) async => const Result.success('ignored'));
        when(
          () => mockStorage.deleteFile(any(), any()),
        ).thenAnswer((_) async => const Result.success(null));
        when(
          () => mockRepo.updateLog(any()),
        ).thenAnswer((_) async => Result.success(log));

        final result = await sut.updateAllergenLog(
          log: log,
          newPhotoLocalPath: '/tmp/new.jpg',
          oldPhotoPath: 'old/path.jpg',
        );

        expect(result.isSuccess, isTrue);
        verify(() => mockStorage.uploadFile(any(), any(), any())).called(1);
        verify(
          () => mockStorage.deleteFile('allergen-photos', 'old/path.jpg'),
        ).called(1);

        final captured = verify(() => mockRepo.updateLog(captureAny())).captured
            .single as AllergenLog;
        // photoUrl now points at the freshly uploaded path
        // (not the old path passed in).
        expect(captured.photoUrl, isNot('old/path.jpg'));
        expect(captured.photoUrl, isNotNull);
      },
    );

    test('upload failure propagates and skips repo.updateLog', () async {
      final log = _makeLog();
      when(() => mockStorage.uploadFile(any(), any(), any())).thenAnswer(
        (_) async => const Result.failure(ServerException('upload bad')),
      );

      final result = await sut.updateAllergenLog(
        log: log,
        newPhotoLocalPath: '/tmp/new.jpg',
        oldPhotoPath: 'old/path.jpg',
      );

      expect(result.isFailure, isTrue);
      verifyNever(() => mockRepo.updateLog(any()));
      verifyNever(() => mockStorage.deleteFile(any(), any()));
    });

    test(
      'old-photo delete failure is non-fatal: '
      'crash recorder called + updateLog still runs',
      () async {
        final log = _makeLog();
        var recorded = 0;
        sut = AllergenService(
          mockRepo,
          mockStorage,
          crashRecorder:
              (Object error, StackTrace stack, {String? reason}) async {
                recorded++;
              },
        );

        when(
          () => mockStorage.uploadFile(any(), any(), any()),
        ).thenAnswer((_) async => const Result.success('ignored'));
        when(() => mockStorage.deleteFile(any(), any())).thenAnswer(
          (_) async => const Result.failure(ServerException('not found')),
        );
        when(
          () => mockRepo.updateLog(any()),
        ).thenAnswer((_) async => Result.success(log));

        final result = await sut.updateAllergenLog(
          log: log,
          newPhotoLocalPath: '/tmp/new.jpg',
          oldPhotoPath: 'old/path.jpg',
        );

        expect(result.isSuccess, isTrue);
        expect(recorded, 1);
        verify(() => mockRepo.updateLog(any())).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // deleteAllergenLog
  // ---------------------------------------------------------------------------

  group('AllergenService.deleteAllergenLog', () {
    test('no photoPath: skips storage, calls repo.deleteLog', () async {
      when(
        () => mockRepo.deleteLog(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.deleteAllergenLog(logId: 'log-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.deleteLog('log-1')).called(1);
      verifyNever(() => mockStorage.deleteFile(any(), any()));
    });

    test(
      'with photoPath: deletes photo then deletes log row',
      () async {
        when(
          () => mockStorage.deleteFile(any(), any()),
        ).thenAnswer((_) async => const Result.success(null));
        when(
          () => mockRepo.deleteLog(any()),
        ).thenAnswer((_) async => const Result.success(null));

        final result = await sut.deleteAllergenLog(
          logId: 'log-1',
          photoPath: 'old/path.jpg',
        );

        expect(result.isSuccess, isTrue);
        verify(
          () => mockStorage.deleteFile('allergen-photos', 'old/path.jpg'),
        ).called(1);
        verify(() => mockRepo.deleteLog('log-1')).called(1);
      },
    );

    test(
      'storage delete failure is non-fatal: '
      'crash recorder called + repo.deleteLog still runs',
      () async {
        var recorded = 0;
        sut = AllergenService(
          mockRepo,
          mockStorage,
          crashRecorder:
              (Object error, StackTrace stack, {String? reason}) async {
                recorded++;
              },
        );

        when(() => mockStorage.deleteFile(any(), any())).thenAnswer(
          (_) async => const Result.failure(ServerException('not found')),
        );
        when(
          () => mockRepo.deleteLog(any()),
        ).thenAnswer((_) async => const Result.success(null));

        final result = await sut.deleteAllergenLog(
          logId: 'log-1',
          photoPath: 'old/path.jpg',
        );

        expect(result.isSuccess, isTrue);
        expect(recorded, 1);
        verify(() => mockRepo.deleteLog('log-1')).called(1);
      },
    );

    test('propagates repo.deleteLog failure', () async {
      when(() => mockRepo.deleteLog(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('row missing')),
      );

      final result = await sut.deleteAllergenLog(logId: 'log-1');

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getCurrentAllergen
  // ---------------------------------------------------------------------------

  group('AllergenService.getCurrentAllergen', () {
    test('returns Failure when getProgramState fails', () async {
      when(() => mockRepo.getProgramState(any())).thenAnswer(
        (_) async =>
            const Result.failure(ServerException('state fetch failed')),
      );

      final result = await sut.getCurrentAllergen(_babyId);

      expect(result.isFailure, isTrue);
      verifyNever(() => mockRepo.getAllergens());
    });

    test('returns Failure when getAllergens fails', () async {
      when(
        () => mockRepo.getProgramState(any()),
      ).thenAnswer((_) async => Result.success(_makeProgramState()));
      when(() => mockRepo.getAllergens()).thenAnswer(
        (_) async =>
            const Result.failure(ServerException('allergens fetch failed')),
      );

      final result = await sut.getCurrentAllergen(_babyId);

      expect(result.isFailure, isTrue);
    });

    test('returns allergen matching currentAllergenKey', () async {
      when(
        () => mockRepo.getProgramState(any()),
      ).thenAnswer(
        (_) async => Result.success(
          _makeProgramState(currentAllergenKey: 'egg', currentSequenceOrder: 2),
        ),
      );
      when(
        () => mockRepo.getAllergens(),
      ).thenAnswer((_) async => Result.success(_allergens));

      final result = await sut.getCurrentAllergen(_babyId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.key, 'egg');
    });

    test('falls back to first allergen when key not found', () async {
      when(() => mockRepo.getProgramState(any())).thenAnswer(
        (_) async => Result.success(
          _makeProgramState(currentAllergenKey: 'unknown_key'),
        ),
      );
      when(
        () => mockRepo.getAllergens(),
      ).thenAnswer((_) async => Result.success(_allergens));

      final result = await sut.getCurrentAllergen(_babyId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.key, _allergens.first.key);
    });
  });

  // ---------------------------------------------------------------------------
  // getAllergenBoardSummary — getLogs failure path
  // ---------------------------------------------------------------------------

  group('AllergenService.getAllergenBoardSummary — getLogs failure', () {
    test('returns Failure when getLogs fails', () async {
      when(
        () => mockRepo.getAllergens(),
      ).thenAnswer((_) async => Result.success(_allergens));
      when(() => mockRepo.getLogs(any())).thenAnswer(
        (_) async =>
            const Result.failure(ServerException('logs fetch failed')),
      );

      final result = await sut.getAllergenBoardSummary(_babyId);

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // saveAllergenLog — photo paths and failure paths
  // ---------------------------------------------------------------------------

  group('AllergenService.saveAllergenLog — photo and failure paths', () {
    test(
      'photo upload success: log is saved with non-null photoUrl',
      () async {
        const uploadedPath = 'baby-001/123_peanut.jpg';
        final saved = _makeLog(id: 'log-with-photo')
            .copyWith(photoUrl: uploadedPath);
        when(
          () => mockStorage.uploadFile(any(), any(), any()),
        ).thenAnswer((_) async => const Result.success(uploadedPath));
        when(
          () => mockRepo.saveLog(any()),
        ).thenAnswer((_) async => Result.success(saved));

        final result = await sut.saveAllergenLog(
          babyId: _babyId,
          allergenKey: _peanutKey,
          hadReaction: false,
          photo: File('/tmp/photo.jpg'),
        );

        expect(result.isSuccess, isTrue);
        final captured =
            verify(() => mockRepo.saveLog(captureAny())).captured.single
                as AllergenLog;
        expect(captured.photoUrl, isNotNull);
      },
    );

    test(
      'photo upload failure: log is still saved with null photoUrl',
      () async {
        final saved = _makeLog(id: 'log-no-photo');
        when(() => mockStorage.uploadFile(any(), any(), any())).thenAnswer(
          (_) async => const Result.failure(ServerException('upload failed')),
        );
        when(
          () => mockRepo.saveLog(any()),
        ).thenAnswer((_) async => Result.success(saved));

        final result = await sut.saveAllergenLog(
          babyId: _babyId,
          allergenKey: _peanutKey,
          hadReaction: false,
          photo: File('/tmp/photo.jpg'),
        );

        expect(result.isSuccess, isTrue);
        final captured =
            verify(() => mockRepo.saveLog(captureAny())).captured.single
                as AllergenLog;
        expect(captured.photoUrl, isNull);
      },
    );

    test('repo saveLog failure propagates', () async {
      when(() => mockRepo.saveLog(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('insert failed')),
      );

      final result = await sut.saveAllergenLog(
        babyId: _babyId,
        allergenKey: _peanutKey,
        hadReaction: false,
      );

      expect(result.isFailure, isTrue);
      verifyNever(() => mockRepo.saveReactionDetail(any()));
    });

    test(
      'reactionDetail save failure propagates after log is saved',
      () async {
        final savedLog = _makeLog(id: 'log-react', hadReaction: true);
        final detail = ReactionDetail(
          id: '',
          logId: '',
          severity: ReactionSeverity.mild,
          symptoms: const ['Hives'],
          createdAt: _now,
        );
        when(
          () => mockRepo.saveLog(any()),
        ).thenAnswer((_) async => Result.success(savedLog));
        when(() => mockRepo.saveReactionDetail(any())).thenAnswer(
          (_) async =>
              const Result.failure(ServerException('detail insert failed')),
        );

        final result = await sut.saveAllergenLog(
          babyId: _babyId,
          allergenKey: _peanutKey,
          hadReaction: true,
          reactionDetail: detail,
        );

        expect(result.isFailure, isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Delegation methods
  // ---------------------------------------------------------------------------

  group('AllergenService.getProgramState', () {
    test('delegates to repo and returns success', () async {
      final state = _makeProgramState();
      when(
        () => mockRepo.getProgramState(any()),
      ).thenAnswer((_) async => Result.success(state));

      final result = await sut.getProgramState(_babyId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, state);
      verify(() => mockRepo.getProgramState(_babyId)).called(1);
    });

    test('propagates repo failure', () async {
      when(() => mockRepo.getProgramState(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.getProgramState(_babyId);

      expect(result.isFailure, isTrue);
    });
  });

  group('AllergenService.getReactionDetail', () {
    const logId = 'log-1';

    test('delegates to repo and returns success', () async {
      final detail = ReactionDetail(
        id: 'det-1',
        logId: logId,
        severity: ReactionSeverity.mild,
        symptoms: const [],
        createdAt: _now,
      );
      when(
        () => mockRepo.getReactionDetail(any()),
      ).thenAnswer((_) async => Result.success(detail));

      final result = await sut.getReactionDetail(logId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, detail);
      verify(() => mockRepo.getReactionDetail(logId)).called(1);
    });

    test('returns null when no detail exists', () async {
      when(
        () => mockRepo.getReactionDetail(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.getReactionDetail(logId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNull);
    });

    test('propagates repo failure', () async {
      when(() => mockRepo.getReactionDetail(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.getReactionDetail(logId);

      expect(result.isFailure, isTrue);
    });
  });

  group('AllergenService.getSignedPhotoUrl', () {
    const photoPath = 'baby-001/photo.jpg';
    const signedUrl = 'https://cdn.example.com/signed';

    test('delegates to storage and returns signed URL', () async {
      when(
        () => mockStorage.getSignedUrl(any(), any()),
      ).thenAnswer((_) async => const Result.success(signedUrl));

      final result = await sut.getSignedPhotoUrl(photoPath);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, signedUrl);
      verify(
        () => mockStorage.getSignedUrl('allergen-photos', photoPath),
      ).called(1);
    });

    test('propagates storage failure', () async {
      when(() => mockStorage.getSignedUrl(any(), any())).thenAnswer(
        (_) async => const Result.failure(ServerException('storage error')),
      );

      final result = await sut.getSignedPhotoUrl(photoPath);

      expect(result.isFailure, isTrue);
    });
  });

  group('AllergenService.getAllergens', () {
    test('delegates to repo (default refresh=false)', () async {
      when(
        () => mockRepo.getAllergens(),
      ).thenAnswer((_) async => Result.success(_allergens));

      final result = await sut.getAllergens();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, _allergens);
      verify(() => mockRepo.getAllergens()).called(1);
    });

    test('passes refresh=true to repo', () async {
      when(
        () => mockRepo.getAllergens(refresh: true),
      ).thenAnswer((_) async => Result.success(_allergens));

      final result = await sut.getAllergens(refresh: true);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.getAllergens(refresh: true)).called(1);
    });

    test('propagates repo failure', () async {
      when(() => mockRepo.getAllergens()).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.getAllergens();

      expect(result.isFailure, isTrue);
    });
  });

  group('AllergenService.getLogs', () {
    test('fetches all logs for baby when no allergenKey filter', () async {
      final logs = [_makeLog(), _makeLog(id: 'log-2', allergenKey: 'egg')];
      when(
        () => mockRepo.getLogs(any()),
      ).thenAnswer((_) async => Result.success(logs));

      final result = await sut.getLogs(_babyId);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, logs);
      verify(() => mockRepo.getLogs(_babyId)).called(1);
    });

    test('passes allergenKey filter to repo', () async {
      final peanutLogs = [_makeLog()];
      when(
        () => mockRepo.getLogs(any(), allergenKey: any(named: 'allergenKey')),
      ).thenAnswer((_) async => Result.success(peanutLogs));

      final result = await sut.getLogs(_babyId, allergenKey: _peanutKey);

      expect(result.isSuccess, isTrue);
      verify(
        () => mockRepo.getLogs(_babyId, allergenKey: _peanutKey),
      ).called(1);
    });

    test('propagates repo failure', () async {
      when(() => mockRepo.getLogs(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.getLogs(_babyId);

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Post-edit / post-delete recompute regression (NIB-110)
  //
  // Proves the per-allergen status is RE-DERIVED from the current set of logs
  // on every read — never cached. After updateLog flips one egg log to a
  // reaction, the status flips from safe → flagged. After deleteLog removes
  // one of three clean logs, the status falls back from safe → inProgress.
  // ---------------------------------------------------------------------------

  group('AllergenService post-edit/delete recompute', () {
    test(
      'flipping one of three clean egg logs to hadReaction=true via '
      'updateAllergenLog re-derives egg status as flagged on the next read',
      () async {
        // Mock repo: in-memory log store that updateLog mutates in place so
        // the next getLogs call returns the post-update set.
        final store = <AllergenLog>[
          _makeLog(id: 'e1', allergenKey: 'egg'),
          _makeLog(id: 'e2', allergenKey: 'egg'),
          _makeLog(id: 'e3', allergenKey: 'egg'),
        ];
        when(
          () => mockRepo.getLogs(any()),
        ).thenAnswer((_) async => Result.success(List.of(store)));
        when(() => mockRepo.updateLog(any())).thenAnswer((invocation) async {
          final updated = invocation.positionalArguments.first as AllergenLog;
          final idx = store.indexWhere((l) => l.id == updated.id);
          if (idx >= 0) store[idx] = updated;
          return Result.success(updated);
        });

        final beforeResult = await sut.getAllergenStatuses(_babyId);
        expect(beforeResult.dataOrNull!['egg'], AllergenStatus.safe);

        final updateResult = await sut.updateAllergenLog(
          log: store.first.copyWith(hadReaction: true),
        );
        expect(updateResult.isSuccess, isTrue);

        final afterResult = await sut.getAllergenStatuses(_babyId);
        expect(afterResult.dataOrNull!['egg'], AllergenStatus.flagged);
        verify(() => mockRepo.updateLog(any())).called(1);
      },
    );

    test(
      'deleting one of three clean egg logs via deleteAllergenLog '
      're-derives egg status as inProgress on the next read',
      () async {
        final store = <AllergenLog>[
          _makeLog(id: 'e1', allergenKey: 'egg'),
          _makeLog(id: 'e2', allergenKey: 'egg'),
          _makeLog(id: 'e3', allergenKey: 'egg'),
        ];
        when(
          () => mockRepo.getLogs(any()),
        ).thenAnswer((_) async => Result.success(List.of(store)));
        when(() => mockRepo.deleteLog(any())).thenAnswer((invocation) async {
          final id = invocation.positionalArguments.first as String;
          store.removeWhere((l) => l.id == id);
          return const Result.success(null);
        });

        final beforeResult = await sut.getAllergenStatuses(_babyId);
        expect(beforeResult.dataOrNull!['egg'], AllergenStatus.safe);

        final deleteResult = await sut.deleteAllergenLog(logId: 'e1');
        expect(deleteResult.isSuccess, isTrue);

        final afterResult = await sut.getAllergenStatuses(_babyId);
        expect(afterResult.dataOrNull!['egg'], AllergenStatus.inProgress);
        verify(() => mockRepo.deleteLog('e1')).called(1);
      },
    );
  });
}
