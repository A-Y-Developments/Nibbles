import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/data/repositories/account_repository.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/profile/delete/delete_account_controller.dart';
import 'package:nibbles/src/features/profile/delete/delete_account_overlay.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../../../support/fake_analytics.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

/// Test seam — bypasses the real `AuthService.signOut`'s `Purchases.logOut()`
/// call, which never resolves in the widget-test ticker (the method channel
/// has no platform handler so the awaited Future hangs `pumpAndSettle`).
class _FakeAuthService extends AuthService {
  int signOutCalls = 0;

  @override
  bool build() => true;

  @override
  Stream<AuthState> get authStateStream => const Stream<AuthState>.empty();

  @override
  Future<Result<void>> signOut() async {
    signOutCalls += 1;
    state = false;
    return const Result.success(null);
  }
}

/// The first reason in the hardcoded `_kReasons` list inside the overlay —
/// used here so taps on `delete_reason_0` map back to a predictable
/// `submit(reason)` arg. Verbatim from Figma 1216:11954 (NIB-78).
const _firstReasonLabel = 'I achieved my goal already';

/// Verbatim heading from Figma 1216:11963.
const _headingText = 'Tell us why you want to delete your account';

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const Key('open_sheet'),
              onPressed: () => showDeleteAccountOverlay(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open_sheet')));
  await tester.pumpAndSettle();
}

/// Defaults to 800x600 in widget tests — too short for the 92% bottom sheet
/// to fit the Continue / Cancel pills, which then land off-screen and fail
/// hit-test on `tester.tap`. Bump to a tall portrait window large enough
/// for every reason row + both pills + the 8% headroom to fit inside the
/// viewport. Reset on tearDown.
Future<void> _setTallSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// 30s test budget — keeps the debug loop tight if a future change reintroduces
// a settle-hang in any of these flows.
const _testTimeout = Timeout(Duration(seconds: 30));

void main() {
  late _MockAccountRepository mockAccountRepo;
  late _MockAuthRepository mockAuthRepo;
  late _MockLocalFlagService mockFlags;
  late _FakeAuthService fakeAuthService;
  late FakeAnalytics fakeAnalytics;

  setUp(() {
    mockAccountRepo = _MockAccountRepository();
    mockAuthRepo = _MockAuthRepository();
    mockFlags = _MockLocalFlagService();
    fakeAuthService = _FakeAuthService();
    fakeAnalytics = FakeAnalytics();

    when(() => mockAuthRepo.isLoggedIn).thenReturn(true);
    when(
      () => mockAuthRepo.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockAuthRepo.signOut(),
    ).thenAnswer((_) async => const Result.success(null));
    when(mockFlags.clearAll).thenAnswer((_) async {});
  });

  List<Override> overrides() => [
    accountRepositoryProvider.overrideWithValue(mockAccountRepo),
    authRepositoryProvider.overrideWithValue(mockAuthRepo),
    authServiceProvider.overrideWith(() => fakeAuthService),
    localFlagServiceProvider.overrideWithValue(mockFlags),
    analyticsProvider.overrideWithValue(fakeAnalytics),
    deleteAccountCrashRecorderProvider.overrideWithValue(
      (_, __, {String? reason, List<String>? information}) async {},
    ),
  ];

  testWidgets('Continue is disabled when no reason is selected', (
    tester,
  ) async {
    await _setTallSurface(tester);
    await tester.pumpWidget(_wrap(overrides()));
    await _openSheet(tester);

    // Sheet content rendered.
    expect(find.text(_headingText), findsOneWidget);

    final continueBtn = tester.widget<AppPillButton>(
      find.byKey(const Key('delete_account_continue_button')),
    );
    expect(continueBtn.onPressed, isNull);
  }, timeout: _testTimeout);

  testWidgets('tapping a reason row enables Continue', (tester) async {
    await _setTallSurface(tester);
    await tester.pumpWidget(_wrap(overrides()));
    await _openSheet(tester);

    await tester.tap(find.byKey(const Key('delete_reason_0')));
    await tester.pumpAndSettle();

    final continueBtn = tester.widget<AppPillButton>(
      find.byKey(const Key('delete_account_continue_button')),
    );
    expect(continueBtn.onPressed, isNotNull);
  }, timeout: _testTimeout);

  testWidgets(
    'tapping Continue fires logAccountDeletionStarted(reason) and calls '
    'controller.submit(reason)',
    (tester) async {
      // Park the destructive call on a never-completing Future so submit()
      // never reaches the post-success `Navigator.pop()` — `pumpAndSettle`
      // after that pop is what causes the test to hang. The unit-level
      // success path is already covered by delete_account_controller_test.
      final pending = Completer<Result<void>>();
      when(
        () => mockAccountRepo.requestAccountDeletion(any()),
      ).thenAnswer((_) => pending.future);

      await _setTallSurface(tester);
      await tester.pumpWidget(_wrap(overrides()));
      await _openSheet(tester);

      await tester.tap(find.byKey(const Key('delete_reason_0')));
      await tester.pump();

      // Continue is anchored to the bottom of the sheet — ensure it's
      // on-screen before tapping (the SingleChildScrollView inside the
      // sheet is the only Scrollable that hosts it).
      await tester.ensureVisible(
        find.byKey(const Key('delete_account_continue_button')),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('delete_account_continue_button')));
      await tester.pumpAndSettle();

      // Continue now opens a confirm dialog first — nothing fires until the
      // user confirms. Confirm to reach the destructive call.
      expect(
        find.byKey(const Key('delete_account_confirm_dialog')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('delete_account_confirm_button')));
      // Single pump — no `pumpAndSettle`. `_onContinue` fires
      // `logAccountDeletionStarted` synchronously after the confirm, then
      // hits the parked future on `requestAccountDeletion`, so the modal
      // never tries to pop and nothing settles forever.
      await tester.pump();

      // Intent event fires only after confirm, BEFORE the destructive call
      // (controller is verified via the repository mock).
      expect(fakeAnalytics.eventNames, contains('account_deletion_started'));
      final startedEvt = fakeAnalytics.calls.firstWhere(
        (c) => c.name == 'account_deletion_started',
      );
      expect(startedEvt.parameters['reason'], _firstReasonLabel);

      // submit(reason) -> AccountRepository.requestAccountDeletion(reason).
      verify(
        () => mockAccountRepo.requestAccountDeletion(_firstReasonLabel),
      ).called(1);
    },
    timeout: _testTimeout,
  );

  testWidgets(
    'cancelling the confirm dialog aborts — no delete, no analytics',
    (tester) async {
      await _setTallSurface(tester);
      await tester.pumpWidget(_wrap(overrides()));
      await _openSheet(tester);

      await tester.tap(find.byKey(const Key('delete_reason_0')));
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('delete_account_continue_button')),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('delete_account_continue_button')));
      await tester.pumpAndSettle();

      // Confirm dialog is up — dismiss it via Cancel.
      expect(
        find.byKey(const Key('delete_account_confirm_dialog')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('delete_account_confirm_cancel')));
      await tester.pumpAndSettle();

      // Dialog gone, sheet still up, nothing destructive ran.
      expect(
        find.byKey(const Key('delete_account_confirm_dialog')),
        findsNothing,
      );
      expect(find.text(_headingText), findsOneWidget);
      verifyNever(() => mockAccountRepo.requestAccountDeletion(any()));
      expect(
        fakeAnalytics.eventNames,
        isNot(contains('account_deletion_started')),
      );
    },
    timeout: _testTimeout,
  );

  testWidgets('tapping Cancel pops the sheet', (tester) async {
    await _setTallSurface(tester);
    await tester.pumpWidget(_wrap(overrides()));
    await _openSheet(tester);

    expect(find.text(_headingText), findsOneWidget);

    // Cancel sits at the bottom of the sheet's SingleChildScrollView and
    // can land off-screen on a 800x600 surface.
    await tester.ensureVisible(
      find.byKey(const Key('delete_account_cancel_button')),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('delete_account_cancel_button')));
    await tester.pumpAndSettle();

    expect(find.text(_headingText), findsNothing);
    // Cancel must NOT have run any destructive plumbing.
    verifyNever(() => mockAccountRepo.requestAccountDeletion(any()));
    verifyNever(mockFlags.clearAll);
    verifyNever(() => mockAuthRepo.signOut());
  }, timeout: _testTimeout);

  testWidgets('close (X) also pops the sheet', (tester) async {
    await _setTallSurface(tester);
    await tester.pumpWidget(_wrap(overrides()));
    await _openSheet(tester);

    expect(find.text(_headingText), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete_account_close_button')));
    await tester.pumpAndSettle();

    expect(find.text(_headingText), findsNothing);
  }, timeout: _testTimeout);
}
