import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/repositories/consent_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/consent_type.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/consent_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/consent/onboarding_consent_screen.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

/// Hand-rolled no-op repo — avoids polluting the global mocktail matcher
/// queue with `any(named: 'babyId')` etc. The screen tests stub
/// `babyProfile.createBaby` with POSITIONAL `any()` matchers; mixing in a
/// Mock for ConsentService with NAMED matchers trips mocktail's matcher
/// accounting on the next real call. NIB-145's wiring behaviour is asserted
/// in the controller-level test
/// (`onboarding_controller_consent_persistence_test.dart`).
class _NoopConsentRepository implements ConsentRepository {
  const _NoopConsentRepository();

  @override
  Future<Result<void>> recordConsent({
    required String babyId,
    required ConsentType type,
  }) async => const Result.success(null);
}

Future<void> _noopCrashRecorder(
  Object error,
  StackTrace stack, {
  String? reason,
  List<String>? information,
}) async {}

final _fakeBaby = Baby(
  id: 'baby-001',
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.preferNotToSay,
  onboardingCompleted: false,
);

/// NIB-105 — widget tests for `OnboardingConsentScreen` (NIB-100).
///
/// Pins:
///   - 2 checkboxes when the captured DOB makes the baby >= 6 months old;
///     3 when < 6 months (early-solids variant).
///   - CTA `onboarding_consent_submit` is disabled until every checkbox is
///     ticked.
///   - On confirm the controller's `submit` runs and `setOnboardingDone()`
///     is invoked on the local flag service; navigation lands on /home.
///   - On failure: inline P1 error renders, CTA stays disabled WHILE the
///     submit is in flight (double-submit guard at the widget layer).
GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.onboardingConsent.path,
  routes: [
    GoRoute(
      path: AppRoute.onboardingConsent.path,
      name: AppRoute.onboardingConsent.name,
      builder: (_, __) => screen,
    ),
    // NIB-137 — consent now pushes through the post-consent loading
    // transition instead of going straight to /home. Stub it so the
    // success-path test can land on a deterministic route.
    GoRoute(
      path: AppRoute.onboardingBabySetupLoading.path,
      name: AppRoute.onboardingBabySetupLoading.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('LOADING_STUB'))),
    ),
    GoRoute(
      path: AppRoute.home.path,
      name: AppRoute.home.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('HOME_STUB'))),
    ),
  ],
);

ProviderContainer _makeContainer({
  required BabyProfileService babyProfile,
  required LocalFlagService flags,
  required DateTime? dob,
  String babyName = 'Lily',
}) {
  final container = ProviderContainer(
    overrides: [
      babyProfileServiceProvider.overrideWithValue(babyProfile),
      consentServiceProvider.overrideWithValue(
        const ConsentService(_NoopConsentRepository()),
      ),
      localFlagServiceProvider.overrideWithValue(flags),
      onboardingCrashRecorderProvider.overrideWithValue(_noopCrashRecorder),
    ],
  );
  addTearDown(container.dispose);
  container.read(onboardingControllerProvider.notifier).updateName(babyName);
  if (dob != null) {
    container.read(onboardingControllerProvider.notifier).updateDob(dob);
  }
  return container;
}

Future<void> _pumpConsent(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: _routerFor(const OnboardingConsentScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockBabyProfileService babyProfile;
  late _MockLocalFlagService flags;

  // Anchor `now` so the boundary computations in these tests are stable.
  // `ageInMonths` is well-covered elsewhere; here we just need DOBs that
  // unambiguously map to >= 6mo and < 6mo at the moment the widget reads
  // `DateTime.now()` (the consent screen does not let us inject a clock).
  setUp(() {
    babyProfile = _MockBabyProfileService();
    flags = _MockLocalFlagService();
  });

  testWidgets(
    '>= 6mo DOB renders the 2-checkbox variant; the 3rd ("full '
    'responsibility") label is absent',
    (tester) async {
      // 18 months ago — comfortably above the 6mo gate.
      final dob = DateTime.now().subtract(const Duration(days: 30 * 18));
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: dob,
      );
      await _pumpConsent(tester, container: container);

      expect(
        find.byKey(const Key('onboarding_consent_checkbox_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_consent_checkbox_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_consent_checkbox_2')),
        findsNothing,
      );

      // The 3rd-box copy (verbatim from `_labelFor`) must not be present.
      expect(
        find.textContaining('full responsibility'),
        findsNothing,
      );
    },
  );

  testWidgets(
    '< 6mo DOB renders the 3-checkbox variant including the "full '
    'responsibility" acknowledgement',
    (tester) async {
      // 2 months ago — clearly below the 6mo gate.
      final dob = DateTime.now().subtract(const Duration(days: 60));
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: dob,
      );
      await _pumpConsent(tester, container: container);

      expect(
        find.byKey(const Key('onboarding_consent_checkbox_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_consent_checkbox_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_consent_checkbox_2')),
        findsOneWidget,
      );

      // Verbatim copy from the Figma audit for the 3rd box (no trailing
      // period — matches baby-setup-lt6mo-1/report.md byte-for-byte).
      expect(
        find.text(
          'I accept full responsibility for my decision to start solids '
          'before 6 months',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'renders the verbatim Figma copy for boxes 0 and 1 (both age variants '
    'share these two strings — pinned to guard against future paraphrase)',
    (tester) async {
      final dob = DateTime.now().subtract(const Duration(days: 30 * 18));
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: dob,
      );
      await _pumpConsent(tester, container: container);

      expect(
        find.text(
          'I understand that Nibbles shares general educational '
          'information, not medical advice, and that parents make the '
          'final decisions for their baby',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'I confirm I have received medical clearance and understand '
          'the above',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'missing DOB falls back to the safer 2-checkbox variant (defensive '
    "default per the screen's `_defaultAgeMonths` constant)",
    (tester) async {
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: null,
      );
      await _pumpConsent(tester, container: container);

      expect(
        find.byKey(const Key('onboarding_consent_checkbox_2')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'CTA is disabled on first paint and enables only once all required '
    'checkboxes are ticked (2-checkbox variant)',
    (tester) async {
      final dob = DateTime.now().subtract(const Duration(days: 30 * 18));
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: dob,
      );
      await _pumpConsent(tester, container: container);

      AppPillButton submit() => tester.widget<AppPillButton>(
            find.byKey(const Key('onboarding_consent_submit')),
          );

      expect(submit().onPressed, isNull);
      expect(submit().label, 'Check confirmation');

      await tester.tap(find.byKey(const Key('onboarding_consent_checkbox_0')));
      await tester.pump();
      expect(submit().onPressed, isNull, reason: 'still 1 of 2');

      await tester.tap(find.byKey(const Key('onboarding_consent_checkbox_1')));
      await tester.pump();
      expect(submit().onPressed, isNotNull);
      expect(submit().label, 'Yes, I Understand');
    },
  );

  testWidgets(
    'on confirm: calls baby_profile_service.createBaby, flips '
    'onboarding_done, navigates to the post-consent loading transition',
    (tester) async {
      when(
        () => babyProfile.createBaby(any(), any()),
      ).thenAnswer((_) async => Result.success(_fakeBaby));
      when(flags.setOnboardingDone).thenAnswer((_) {});

      final dob = DateTime.now().subtract(const Duration(days: 30 * 18));
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: dob,
      );
      await _pumpConsent(tester, container: container);

      await tester.tap(find.byKey(const Key('onboarding_consent_checkbox_0')));
      await tester.tap(find.byKey(const Key('onboarding_consent_checkbox_1')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('onboarding_consent_submit')));
      await tester.pumpAndSettle();

      verify(() => babyProfile.createBaby('Lily', dob)).called(1);
      verify(flags.setOnboardingDone).called(1);
      // NIB-137 — consent now pushes through the loading transition; that
      // screen owns the auto-route to /home and is tested in isolation.
      expect(find.text('LOADING_STUB'), findsOneWidget);
      expect(find.text('HOME_STUB'), findsNothing);
    },
  );

  testWidgets(
    'on submit failure: inline P1 error renders verbatim; nav does NOT fire; '
    'onboarding_done is NOT flipped',
    (tester) async {
      when(() => babyProfile.createBaby(any(), any())).thenAnswer(
        (_) async => const Result.failure(ServerException('boom from server')),
      );
      when(flags.setOnboardingDone).thenAnswer((_) {});

      final dob = DateTime.now().subtract(const Duration(days: 30 * 18));
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: dob,
      );
      await _pumpConsent(tester, container: container);

      await tester.tap(find.byKey(const Key('onboarding_consent_checkbox_0')));
      await tester.tap(find.byKey(const Key('onboarding_consent_checkbox_1')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('onboarding_consent_submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('onboarding_consent_error')), findsOneWidget);
      expect(find.text('boom from server'), findsOneWidget);
      expect(find.text('HOME_STUB'), findsNothing);
      verifyNever(flags.setOnboardingDone);
    },
  );

  testWidgets(
    'CTA is disabled while the submit is in flight (widget-layer '
    'double-submit guard — see PR body: no controller-level guard)',
    (tester) async {
      final completer = Completer<Result<Baby>>();
      when(
        () => babyProfile.createBaby(any(), any()),
      ).thenAnswer((_) => completer.future);
      when(flags.setOnboardingDone).thenAnswer((_) {});

      final dob = DateTime.now().subtract(const Duration(days: 30 * 18));
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: dob,
      );
      await _pumpConsent(tester, container: container);

      await tester.tap(find.byKey(const Key('onboarding_consent_checkbox_0')));
      await tester.tap(find.byKey(const Key('onboarding_consent_checkbox_1')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('onboarding_consent_submit')));
      // Pump WITHOUT settling — completer is still pending; isSubmitting=true.
      await tester.pump();

      final submit = tester.widget<AppPillButton>(
        find.byKey(const Key('onboarding_consent_submit')),
      );
      expect(submit.onPressed, isNull);

      // Attempting a second tap is a no-op (disabled button) — verify the
      // service was called exactly once.
      await tester.tap(
        find.byKey(const Key('onboarding_consent_submit')),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(() => babyProfile.createBaby(any(), any())).called(1);

      // Release the future so teardown doesn't dangle a pending Completer.
      completer.complete(Result.success(_fakeBaby));
      await tester.pumpAndSettle();
    },
  );
}
