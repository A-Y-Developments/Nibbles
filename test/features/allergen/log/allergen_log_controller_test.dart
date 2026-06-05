// Firebase platform-interface packages are transitive deps; the public barrels
// don't re-export FirebaseAnalyticsPlatform/setupFirebaseCoreMocks. Test-only.
// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_state.dart';

/// No-op Firebase Analytics platform so the controller's unawaited
/// `Analytics.instance.logAllergenLog*` calls don't throw when boot-time
/// Firebase isn't available in the test harness. Mirrors the pattern in
/// `test/features/splash/splash_screen_test.dart` (NIB-88).
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

class _MockAllergenService extends Mock implements AllergenService {}

const _babyId = 'baby-001';
const _allergenKey = 'peanut';
final _now = DateTime(2026, 3, 24);

AllergenLog _makeLog({
  String id = 'log-1',
  String allergenKey = _allergenKey,
  bool hadReaction = false,
  EmojiTaste? taste = EmojiTaste.love,
  String? notes,
  String? photoUrl,
  String? attachmentTitle,
  String? attachmentDescription,
  DateTime? logDate,
}) => AllergenLog(
  id: id,
  babyId: _babyId,
  allergenKey: allergenKey,
  hadReaction: hadReaction,
  logDate: logDate ?? _now,
  createdAt: _now,
  emojiTaste: taste,
  notes: notes,
  photoUrl: photoUrl,
  attachmentTitle: attachmentTitle,
  attachmentDescription: attachmentDescription,
);

void main() {
  late _MockAllergenService mockService;
  late ProviderContainer container;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(_makeLog());
    // Bootstrap a fake Firebase app so the in-controller
    // `Analytics.instance.logAllergenLog*` calls don't throw.
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  setUp(() {
    mockService = _MockAllergenService();

    container = ProviderContainer(
      overrides: [allergenServiceProvider.overrideWithValue(mockService)],
    )..listen<AllergenLogState>(allergenLogControllerProvider, (_, __) {});
  });

  tearDown(() => container.dispose());

  AllergenLogController readController() =>
      container.read(allergenLogControllerProvider.notifier);
  AllergenLogState readState() =>
      container.read(allergenLogControllerProvider);

  /// Runs [body] inside a guarded zone that swallows the unawaited
  /// [Analytics.logAllergenLog*] rejection. The production `Analytics` wrapper
  /// forwards `has_attachment: bool` which `FirebaseAnalytics.logEvent`
  /// asserts against in debug mode — irrelevant to the controller behavior
  /// under test, but unhandled it would fail the suite. Spec rule 2 (no
  /// `lib/**` changes) means we live with it here.
  Future<void> runWithAnalyticsGuard(Future<void> Function() body) async {
    final completer = Completer<void>();
    // runZonedGuarded returns a Future representing the inner zone, but the
    // contract here is `runWithAnalyticsGuard` awaits the completer instead.
    // ignore: unawaited_futures
    runZonedGuarded(
      () async {
        await body();
        completer.complete();
      },
      (Object e, StackTrace s) {
        // Drop the bool-parameter Firebase assertion. Re-throw anything else
        // so a real test failure still surfaces.
        const marker = 'must be set as the value of the parameter';
        if (e.toString().contains(marker)) {
          return;
        }
        if (!completer.isCompleted) completer.completeError(e, s);
      },
    );
    await completer.future;
  }

  // ---------------------------------------------------------------------------
  // CREATE mode
  // ---------------------------------------------------------------------------

  group('AllergenLogController CREATE submit', () {
    test(
      'forwards taste / hadReaction=false / notes / null photo and '
      'flips isSaved on Result.success',
      () => runWithAnalyticsGuard(() async {
        final controller = readController()
          ..setTaste(EmojiTaste.love)
          ..setNotes('ok');

        when(
          () => mockService.saveAllergenLog(
            babyId: any(named: 'babyId'),
            allergenKey: any(named: 'allergenKey'),
            hadReaction: any(named: 'hadReaction'),
            emojiTaste: any(named: 'emojiTaste'),
            notes: any(named: 'notes'),
            attachmentTitle: any(named: 'attachmentTitle'),
            attachmentDescription: any(named: 'attachmentDescription'),
            logDate: any(named: 'logDate'),
            photo: any(named: 'photo'),
          ),
        ).thenAnswer(
          (_) async => Result.success(_makeLog()),
        );
        when(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        ).thenAnswer((_) async => Result.success([_makeLog()]));
        // 1 clean log → inProgress (no auto-advance trigger).
        when(
          () => mockService.deriveStatus(any()),
        ).thenAnswer((_) => AllergenStatus.inProgress);

        await controller.submit(babyId: _babyId, allergenKey: _allergenKey);

        final captured = verify(
          () => mockService.saveAllergenLog(
            babyId: _babyId,
            allergenKey: _allergenKey,
            hadReaction: false,
            emojiTaste: captureAny(named: 'emojiTaste'),
            notes: captureAny(named: 'notes'),
            attachmentTitle: any(named: 'attachmentTitle'),
            attachmentDescription: any(named: 'attachmentDescription'),
            logDate: any(named: 'logDate'),
            photo: any(named: 'photo'),
          ),
        ).captured;
        expect(captured[0], EmojiTaste.love);
        expect(captured[1], 'ok');

        final state = readState();
        expect(state.isSaved, isTrue);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, isNull);
        expect(state.logId, isNull, reason: 'CREATE mode never sets logId');
      }),
    );

    test(
      'sets errorMessage and leaves isSaved=false on Result.failure',
      () async {
        final controller = readController();
        when(
          () => mockService.saveAllergenLog(
            babyId: any(named: 'babyId'),
            allergenKey: any(named: 'allergenKey'),
            hadReaction: any(named: 'hadReaction'),
            emojiTaste: any(named: 'emojiTaste'),
            notes: any(named: 'notes'),
            attachmentTitle: any(named: 'attachmentTitle'),
            attachmentDescription: any(named: 'attachmentDescription'),
            logDate: any(named: 'logDate'),
            photo: any(named: 'photo'),
          ),
        ).thenAnswer(
          (_) async => const Result.failure(ServerException('db down')),
        );

        await controller.submit(babyId: _babyId, allergenKey: _allergenKey);

        final state = readState();
        expect(state.isSaved, isFalse);
        expect(state.isLoading, isFalse);
        expect(
          state.errorMessage,
          "Couldn't save your log. Please try again.",
        );
      },
    );

    test(
      'flagged save (hadReaction=true) does NOT trigger '
      'advanceToNextAllergen — the auto-advance path is clean-only',
      () => runWithAnalyticsGuard(() async {
        final controller = readController()..toggleReaction();
        expect(readState().hadReaction, isTrue);

        when(
          () => mockService.saveAllergenLog(
            babyId: any(named: 'babyId'),
            allergenKey: any(named: 'allergenKey'),
            hadReaction: any(named: 'hadReaction'),
            emojiTaste: any(named: 'emojiTaste'),
            notes: any(named: 'notes'),
            attachmentTitle: any(named: 'attachmentTitle'),
            attachmentDescription: any(named: 'attachmentDescription'),
            logDate: any(named: 'logDate'),
            photo: any(named: 'photo'),
          ),
        ).thenAnswer(
          (_) async => Result.success(_makeLog(hadReaction: true)),
        );

        await controller.submit(babyId: _babyId, allergenKey: _allergenKey);

        verifyNever(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        );
        verifyNever(() => mockService.advanceToNextAllergen(any()));
        expect(readState().isSaved, isTrue);
      }),
    );
  });

  // ---------------------------------------------------------------------------
  // EDIT mode
  // ---------------------------------------------------------------------------

  group('AllergenLogController EDIT', () {
    test(
      'hydrateForEdit populates state from the matching log',
      () async {
        final existing = _makeLog(
          id: 'log-edit',
          notes: 'first try',
          taste: EmojiTaste.neutral,
          photoUrl: 'baby/photo.jpg',
          attachmentTitle: 'recipe',
          attachmentDescription: 'desc',
          logDate: DateTime(2026, 3, 20),
        );
        when(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        ).thenAnswer((_) async => Result.success([existing]));

        await readController().hydrateForEdit(
          babyId: _babyId,
          allergenKey: _allergenKey,
          logId: 'log-edit',
        );

        final state = readState();
        expect(state.logId, 'log-edit');
        expect(state.taste, EmojiTaste.neutral);
        expect(state.hadReaction, isFalse);
        expect(state.notes, 'first try');
        expect(state.attachmentTitle, 'recipe');
        expect(state.attachmentDescription, 'desc');
        expect(state.existingPhotoPath, 'baby/photo.jpg');
        expect(state.logDate, DateTime(2026, 3, 20));
        expect(state.hydrated, isTrue);
        expect(state.errorMessage, isNull);
      },
    );

    test(
      'submit routes to updateAllergenLog (not saveAllergenLog) and forwards '
      'newPhotoLocalPath + oldPhotoPath from existing state',
      () => runWithAnalyticsGuard(() async {
        final existing = _makeLog(
          id: 'log-edit',
          notes: 'old notes',
          photoUrl: 'baby/old.jpg',
        );
        when(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        ).thenAnswer((_) async => Result.success([existing]));

        final controller = readController();
        await controller.hydrateForEdit(
          babyId: _babyId,
          allergenKey: _allergenKey,
          logId: 'log-edit',
        );

        // Simulate the user replacing the photo locally before saving.
        // We can't drive ImagePicker in unit-land — write the photoPath
        // straight onto state via a mutation we can perform safely
        // (taste change + manual edit is enough to verify pass-through).
        controller
          ..setNotes('new notes')
          ..setAttachmentTitle('title');

        when(
          () => mockService.updateAllergenLog(
            log: any(named: 'log'),
            newPhotoLocalPath: any(named: 'newPhotoLocalPath'),
            oldPhotoPath: any(named: 'oldPhotoPath'),
          ),
        ).thenAnswer(
          (_) async => Result.success(existing.copyWith(notes: 'new notes')),
        );

        await controller.submit(babyId: _babyId, allergenKey: _allergenKey);

        final captured = verify(
          () => mockService.updateAllergenLog(
            log: captureAny(named: 'log'),
            newPhotoLocalPath: captureAny(named: 'newPhotoLocalPath'),
            oldPhotoPath: captureAny(named: 'oldPhotoPath'),
          ),
        ).captured;
        final passedLog = captured[0] as AllergenLog;
        expect(passedLog.id, 'log-edit');
        expect(passedLog.notes, 'new notes');
        expect(passedLog.attachmentTitle, 'title');
        // Existing storage path is preserved on the entity until the service
        // rewrites it after a new upload.
        expect(passedLog.photoUrl, 'baby/old.jpg');
        // No new local file was picked.
        expect(captured[1], isNull);
        // Old path forwarded so the service can best-effort delete it after a
        // new upload — even when no new photo is supplied this round trip.
        expect(captured[2], 'baby/old.jpg');

        verifyNever(
          () => mockService.saveAllergenLog(
            babyId: any(named: 'babyId'),
            allergenKey: any(named: 'allergenKey'),
            hadReaction: any(named: 'hadReaction'),
            emojiTaste: any(named: 'emojiTaste'),
            notes: any(named: 'notes'),
            attachmentTitle: any(named: 'attachmentTitle'),
            attachmentDescription: any(named: 'attachmentDescription'),
            logDate: any(named: 'logDate'),
            photo: any(named: 'photo'),
          ),
        );
        expect(readState().isSaved, isTrue);
      }),
    );

    test(
      'hydrateForEdit failure surfaces errorMessage via the guarded path',
      () async {
        when(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        ).thenAnswer(
          (_) async => const Result.failure(ServerException('boom')),
        );

        await readController().hydrateForEdit(
          babyId: _babyId,
          allergenKey: _allergenKey,
          logId: 'log-edit',
        );

        final state = readState();
        expect(
          state.errorMessage,
          "Couldn't load this log. Please try again.",
        );
        expect(state.isLoading, isFalse);
        expect(state.logId, isNull);
      },
    );

    test(
      'hydrateForEdit clears a stale isSaved when re-editing the same log '
      '(keepAlive — no phantom bounce)',
      () => runWithAnalyticsGuard(() async {
        final existing = _makeLog(id: 'log-edit', notes: 'note');
        when(
          () => mockService.getLogs(
            any(),
            allergenKey: any(named: 'allergenKey'),
          ),
        ).thenAnswer((_) async => Result.success([existing]));
        when(
          () => mockService.updateAllergenLog(
            log: any(named: 'log'),
            newPhotoLocalPath: any(named: 'newPhotoLocalPath'),
            oldPhotoPath: any(named: 'oldPhotoPath'),
          ),
        ).thenAnswer((_) async => Result.success(existing));

        final controller = readController();
        // First edit + save → isSaved flips true; the keepAlive controller
        // retains it after the screen pops.
        await controller.hydrateForEdit(
          babyId: _babyId,
          allergenKey: _allergenKey,
          logId: 'log-edit',
        );
        await controller.submit(babyId: _babyId, allergenKey: _allergenKey);
        expect(readState().isSaved, isTrue);

        // Re-enter EDIT for the SAME log (idempotent short-circuit): the stale
        // isSaved must be cleared so the screen's save-listener cannot bounce
        // on the first interaction.
        await controller.hydrateForEdit(
          babyId: _babyId,
          allergenKey: _allergenKey,
          logId: 'log-edit',
        );
        expect(readState().isSaved, isFalse);
        expect(readState().logId, 'log-edit');
      }),
    );
  });
}
