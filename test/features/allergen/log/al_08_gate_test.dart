// AL-08 reachability gate (NIB-128) widget tests. Drives the
// `ref.listen<AllergenLogState>` hook in [AllergenLogScreen] by flipping the
// overridden controller from `isSaved=false` → `true`. Asserts the three
// branches: route to AL-08, pop without route, fall through on status-read
// failure.
//
// Firebase platform-interface packages are transitive deps; the public barrels
// don't re-export FirebaseAnalyticsPlatform/setupFirebaseCoreMocks. Test-only.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_screen.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class _MockAllergenService extends Mock implements AllergenService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

/// No-op Firebase Analytics platform so the controller's unawaited
/// `Analytics.instance.logAllergenLog*` doesn't throw in test.
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

/// Test double for the controller — exposes a public `flipSaved()` mutation
/// so widget tests can drive the `ref.listen<AllergenLogState>` hook without
/// touching real services.
class _FakeAllergenLogController extends AllergenLogController {
  @override
  AllergenLogState build() => const AllergenLogState(hydrated: true);

  /// Force a state-change to `isSaved: true` so the gate fires.
  void flipSaved() => state = state.copyWith(isSaved: true);
}

const _babyId = 'baby-001';
const _allergenKey = 'peanut';

final _baby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

Map<String, AllergenStatus> _allSafe() => {
  for (final key in kAllergenKeys) key: AllergenStatus.safe,
};

Map<String, AllergenStatus> _mixed() => {
  for (final key in kAllergenKeys) key: AllergenStatus.notStarted,
}..['peanut'] = AllergenStatus.inProgress;

/// Records the most-recent named go/push so tests can assert the gate routed.
class _NavRecorder {
  String? lastName;
  String? lastPath;
}

void main() {
  late _MockAllergenService mockService;
  late _MockBabyProfileService mockBabyService;
  late _MockLocalFlagService mockFlags;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  setUp(() {
    mockService = _MockAllergenService();
    mockBabyService = _MockBabyProfileService();
    mockFlags = _MockLocalFlagService();
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _baby);
  });

  /// Builds a router with a 'sentinel' previous page so `context.pop(true)`
  /// has a stack to fall back to (and is detectable via the recorder).
  Widget buildSubject(_NavRecorder recorder) {
    final router = GoRouter(
      initialLocation: '/sentinel',
      routes: [
        GoRoute(
          path: '/sentinel',
          builder: (ctx, _) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => ctx.pushNamed(
                  AppRoute.allergenLogCreate.name,
                  pathParameters: const {'allergenKey': _allergenKey},
                ),
                child: const Text('GO_LOG'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoute.allergenLogCreate.path,
          name: AppRoute.allergenLogCreate.name,
          builder: (_, __) => const AllergenLogScreen(
            allergenKey: _allergenKey,
          ),
        ),
        GoRoute(
          path: AppRoute.allergenComplete.path,
          name: AppRoute.allergenComplete.name,
          builder: (ctx, _) {
            recorder
              ..lastName = AppRoute.allergenComplete.name
              ..lastPath = AppRoute.allergenComplete.path;
            return const Scaffold(body: Text('AL08_STUB'));
          },
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        allergenServiceProvider.overrideWithValue(mockService),
        babyProfileServiceProvider.overrideWithValue(mockBabyService),
        localFlagServiceProvider.overrideWithValue(mockFlags),
        allergenLogControllerProvider.overrideWith(
          _FakeAllergenLogController.new,
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<_FakeAllergenLogController> mountAndPushToLog(
    WidgetTester tester,
    _NavRecorder recorder,
  ) async {
    await tester.pumpWidget(buildSubject(recorder));
    await tester.pumpAndSettle();
    // Push to the log screen so the `ref.listen` is attached.
    await tester.tap(find.text('GO_LOG'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AllergenLogScreen)),
    );
    return container.read(allergenLogControllerProvider.notifier)
        as _FakeAllergenLogController;
  }

  group('AL-08 reachability gate (NIB-128)', () {
    testWidgets(
      'all-safe + flag unset → markProgramCompletionShown + '
      'goNamed(allergenComplete)',
      (tester) async {
        when(
          () => mockFlags.isProgramCompletionShown(any()),
        ).thenReturn(false);
        when(
          () => mockFlags.markProgramCompletionShown(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockService.getAllergenStatuses(any()),
        ).thenAnswer((_) async => Result.success(_allSafe()));

        final recorder = _NavRecorder();
        final controller = await mountAndPushToLog(tester, recorder);

        controller.flipSaved();
        await tester.pumpAndSettle();

        // Routed to AL-08.
        expect(find.text('AL08_STUB'), findsOneWidget);
        expect(recorder.lastName, AppRoute.allergenComplete.name);
        verify(() => mockFlags.markProgramCompletionShown(_babyId)).called(1);
      },
    );

    testWidgets(
      'all-safe + flag ALREADY set → context.pop(true), NO route to AL-08, '
      'NO second markProgramCompletionShown call',
      (tester) async {
        when(
          () => mockFlags.isProgramCompletionShown(any()),
        ).thenReturn(true);
        when(
          () => mockService.getAllergenStatuses(any()),
        ).thenAnswer((_) async => Result.success(_allSafe()));

        final recorder = _NavRecorder();
        final controller = await mountAndPushToLog(tester, recorder);

        controller.flipSaved();
        await tester.pumpAndSettle();

        expect(find.text('AL08_STUB'), findsNothing);
        // Pop returned us to the sentinel.
        expect(find.text('GO_LOG'), findsOneWidget);
        verifyNever(() => mockFlags.markProgramCompletionShown(any()));
        // Statuses are NOT fetched when the flag is already set — the gate
        // short-circuits on isProgramCompletionShown.
        verifyNever(() => mockService.getAllergenStatuses(any()));
      },
    );

    testWidgets(
      'getAllergenStatuses fails → fall-through to context.pop(true), '
      'no AL-08 navigation, no flag flip',
      (tester) async {
        when(
          () => mockFlags.isProgramCompletionShown(any()),
        ).thenReturn(false);
        when(() => mockService.getAllergenStatuses(any())).thenAnswer(
          (_) async => const Result.failure(ServerException('boom')),
        );

        final recorder = _NavRecorder();
        final controller = await mountAndPushToLog(tester, recorder);

        controller.flipSaved();
        await tester.pumpAndSettle();

        expect(find.text('AL08_STUB'), findsNothing);
        expect(find.text('GO_LOG'), findsOneWidget);
        verifyNever(() => mockFlags.markProgramCompletionShown(any()));
      },
    );

    testWidgets(
      'mixed statuses (not all safe) → context.pop(true), no AL-08',
      (tester) async {
        when(
          () => mockFlags.isProgramCompletionShown(any()),
        ).thenReturn(false);
        when(
          () => mockService.getAllergenStatuses(any()),
        ).thenAnswer((_) async => Result.success(_mixed()));

        final recorder = _NavRecorder();
        final controller = await mountAndPushToLog(tester, recorder);

        controller.flipSaved();
        await tester.pumpAndSettle();

        expect(find.text('AL08_STUB'), findsNothing);
        expect(find.text('GO_LOG'), findsOneWidget);
        verifyNever(() => mockFlags.markProgramCompletionShown(any()));
      },
    );
  });
}
