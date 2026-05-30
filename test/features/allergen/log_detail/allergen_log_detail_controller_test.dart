import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/log_detail/allergen_log_detail_controller.dart';

class _MockAllergenService extends Mock implements AllergenService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

const _babyId = 'baby-001';
const _allergenKey = 'peanut';
final _now = DateTime(2026, 3, 24);

const _peanut = Allergen(
  key: 'peanut',
  name: 'Peanut',
  sequenceOrder: 1,
  emoji: '🥜',
);

final _baby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

AllergenLog _makeLog({
  String id = 'log-1',
  String allergenKey = _allergenKey,
  bool hadReaction = false,
}) => AllergenLog(
  id: id,
  babyId: _babyId,
  allergenKey: allergenKey,
  hadReaction: hadReaction,
  emojiTaste: EmojiTaste.love,
  logDate: _now,
  createdAt: _now,
);

void main() {
  late _MockAllergenService mockService;
  late _MockBabyProfileService mockBabyService;
  late ProviderContainer container;

  setUp(() {
    mockService = _MockAllergenService();
    mockBabyService = _MockBabyProfileService();

    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _baby);

    container = ProviderContainer(
      overrides: [
        allergenServiceProvider.overrideWithValue(mockService),
        babyProfileServiceProvider.overrideWithValue(mockBabyService),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AllergenLogDetailController.build', () {
    test(
      'returns AllergenLogDetailState with the matching log + 1-based '
      'logNumber for the position in the oldest-first sequence',
      () async {
        final logs = [
          _makeLog(),
          _makeLog(id: 'log-2'),
          _makeLog(id: 'log-3'),
        ];
        when(
          () => mockService.getAllergens(),
        ).thenAnswer((_) async => const Result.success([_peanut]));
        when(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        ).thenAnswer((_) async => Result.success(logs));

        final state = await container.read(
          allergenLogDetailControllerProvider(_allergenKey, 'log-2').future,
        );

        expect(state.log.id, 'log-2');
        expect(state.allergen.key, 'peanut');
        expect(state.babyId, _babyId);
        // index 1 in oldest-first → 1-based logNumber == 2.
        expect(state.logNumber, 2);

        // Verifies the controller fetched logs filtered by allergenKey.
        verify(
          () => mockService.getLogs(_babyId, allergenKey: _allergenKey),
        ).called(1);
      },
    );

    test(
      'surfaces a Result.failure from getLogs as AsyncValue.error',
      () async {
        when(
          () => mockService.getAllergens(),
        ).thenAnswer((_) async => const Result.success([_peanut]));
        when(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        ).thenAnswer(
          (_) async => const Result.failure(ServerException('boom')),
        );

        // Drive the AsyncNotifier and assert it ends in `error`.
        final notifier = container.read(
          allergenLogDetailControllerProvider(_allergenKey, 'log-2').notifier,
        );
        await expectLater(notifier.future, throwsA(isA<Object>()));

        final async = container.read(
          allergenLogDetailControllerProvider(_allergenKey, 'log-2'),
        );
        expect(async.hasError, isTrue);
      },
    );

    test(
      'surfaces a Result.failure from getAllergens as AsyncValue.error',
      () async {
        when(
          () => mockService.getAllergens(),
        ).thenAnswer(
          (_) async => const Result.failure(ServerException('boom')),
        );
        when(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        ).thenAnswer((_) async => Result.success([_makeLog()]));

        final notifier = container.read(
          allergenLogDetailControllerProvider(_allergenKey, 'log-1').notifier,
        );
        await expectLater(notifier.future, throwsA(isA<Object>()));

        final async = container.read(
          allergenLogDetailControllerProvider(_allergenKey, 'log-1'),
        );
        expect(async.hasError, isTrue);
      },
    );

    test(
      'unknown logId throws and is surfaced as AsyncValue.error',
      () async {
        when(
          () => mockService.getAllergens(),
        ).thenAnswer((_) async => const Result.success([_peanut]));
        when(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        ).thenAnswer((_) async => Result.success([_makeLog()]));

        final notifier = container.read(
          allergenLogDetailControllerProvider(_allergenKey, 'unknown').notifier,
        );
        await expectLater(notifier.future, throwsA(isA<StateError>()));
      },
    );
  });
}
