import 'dart:async';

import 'package:flutter/gestures.dart';
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
///   - 3 checkboxes for every user; the screen is no longer age-gated after
///     the Figma rework (section 1255:11883).
///   - Verbatim Figma copy for the title, subtitle and all three labels.
///   - The third label carries a tappable "Medical & Safety Disclaimer" link
///     that navigates instead of toggling the checkbox.
///   - CTA `onboarding_consent_submit` is disabled until every checkbox is
///     ticked.
///   - On confirm the controller's `submit` runs and `setOnboardingDone()`
///     is invoked on the local flag service; navigation lands on the
///     post-consent loading transition.
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
    GoRoute(
      path: AppRoute.legalDocument.path,
      name: AppRoute.legalDocument.name,
      builder: (_, state) => Scaffold(
        body: Center(child: Text('LEGAL_STUB:${state.pathParameters['slug']}')),
      ),
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

/// Pumps on the canonical device viewport (iPhone 17 — 402x874 logical) rather
/// than the 800x600 test default. The screen pins its CTA to the bottom of a
/// full-height column, so a short surface pushes it out of the hit-test area.
Future<void> _pumpConsent(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  tester.view
    ..physicalSize = const Size(402 * 3, 874 * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

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

/// Taps the checkbox control itself rather than the row.
///
/// Row 3's label is rich text whose centre lands on the "Medical & Safety
/// Disclaimer" link — a row-centre tap there opens the document instead of
/// toggling, which is the intended behaviour and is asserted separately.
Future<void> _tick(WidgetTester tester, int index) async {
  final checkbox = find.descendant(
    of: find.byKey(Key('onboarding_consent_checkbox_$index')),
    matching: find.byType(AppCheckbox),
  );
  // The checklist lives in a scroll region; the test font is wider than
  // Figtree so rows that fit on a device can sit below the fold here.
  await tester.ensureVisible(checkbox);
  await tester.pumpAndSettle();
  await tester.tap(checkbox);
  await tester.pump();
}

Future<void> _tickAll(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await _tick(tester, i);
  }
}

/// Collects every span in [span] that carries a tap recognizer, keyed by text.
Map<String, TapGestureRecognizer> _linkSpans(InlineSpan span) {
  final found = <String, TapGestureRecognizer>{};
  span.visitChildren((child) {
    if (child is TextSpan && child.recognizer is TapGestureRecognizer) {
      found[child.text ?? ''] = child.recognizer! as TapGestureRecognizer;
    }
    return true;
  });
  return found;
}

Map<String, TapGestureRecognizer> _consentLinks(WidgetTester tester) {
  final richText = tester.widget<RichText>(
    find.descendant(
      of: find.byType(AppLinkedText),
      matching: find.byType(RichText),
    ),
  );
  return _linkSpans(richText.text);
}

void main() {
  setUpAll(() {
    registerFallbackValue(Gender.preferNotToSay);
    registerFallbackValue(<bool>[]);
  });

  late _MockBabyProfileService babyProfile;
  late _MockLocalFlagService flags;

  // 18 months ago — the screen ignores age now, but the controller still needs
  // a DOB to submit, and using a realistic one keeps createBaby verifiable.
  final dob = DateTime.now().subtract(const Duration(days: 30 * 18));

  setUp(() {
    babyProfile = _MockBabyProfileService();
    flags = _MockLocalFlagService();
  });

  testWidgets('renders three checkboxes regardless of the baby age', (
    tester,
  ) async {
    for (final testDob in <DateTime?>[
      DateTime.now().subtract(const Duration(days: 30 * 18)),
      DateTime.now().subtract(const Duration(days: 60)),
      null,
    ]) {
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: testDob,
      );
      await _pumpConsent(tester, container: container);

      for (var i = 0; i < 3; i++) {
        expect(
          find.byKey(Key('onboarding_consent_checkbox_$i')),
          findsOneWidget,
          reason: 'checkbox $i missing for dob $testDob',
        );
      }
      expect(
        find.byKey(const Key('onboarding_consent_checkbox_3')),
        findsNothing,
      );

      // The retired early-solids clause must be gone from every variant.
      expect(find.textContaining('full responsibility'), findsNothing);
    }
  });

  testWidgets('renders the verbatim Figma title, subtitle and label copy', (
    tester,
  ) async {
    final container = _makeContainer(
      babyProfile: babyProfile,
      flags: flags,
      dob: dob,
    );
    await _pumpConsent(tester, container: container);

    expect(find.text('Let’s start safely'), findsOneWidget);
    expect(
      find.text(
        'A few important things to know before your Nibbles journey begins.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'I understand that Nibbles is a general guide and that I remain '
        'responsible for making feeding decisions based on my child’s '
        'individual needs.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'I will actively supervise my child while eating, follow the safety '
        'guidance, check ingredients and allergens, and seek professional or '
        'emergency help when needed.',
      ),
      findsOneWidget,
    );
    // Box 3 is rendered as rich text, so assert on the widget's flat source.
    expect(
      tester.widget<AppLinkedText>(find.byType(AppLinkedText)).text,
      'I have read and agree to the Terms of Use, including the Medical & '
      'Safety Disclaimer, and acknowledge the Privacy Policy.',
    );
  });

  testWidgets(
    'box 3 links the disclaimer only — "Terms of Use" has no document yet and '
    'the Privacy Policy page is gated',
    (tester) async {
      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: dob,
      );
      await _pumpConsent(tester, container: container);

      expect(_consentLinks(tester).keys, ['Medical & Safety Disclaimer']);
    },
  );

  testWidgets('tapping the disclaimer link navigates without ticking the box', (
    tester,
  ) async {
    final container = _makeContainer(
      babyProfile: babyProfile,
      flags: flags,
      dob: dob,
    );
    await _pumpConsent(tester, container: container);

    _consentLinks(tester)['Medical & Safety Disclaimer']!.onTap!();
    await tester.pumpAndSettle();

    expect(find.text('LEGAL_STUB:medical-safety-disclaimer'), findsOneWidget);

    // Pop back and confirm the checkbox was never toggled.
    GoRouter.of(tester.element(find.byType(Scaffold).first)).pop();
    await tester.pumpAndSettle();

    final submit = tester.widget<AppPillButton>(
      find.byKey(const Key('onboarding_consent_submit')),
    );
    expect(submit.onPressed, isNull);
  });

  testWidgets('CTA is disabled on first paint and enables only once all three '
      'checkboxes are ticked', (tester) async {
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

    await _tick(tester, 0);
    expect(submit().onPressed, isNull, reason: 'still 1 of 3');

    await _tick(tester, 1);
    expect(submit().onPressed, isNull, reason: 'still 2 of 3');

    await _tick(tester, 2);
    expect(submit().onPressed, isNotNull);
    expect(submit().label, 'Yes, I Understand');
  });

  testWidgets('on confirm: calls baby_profile_service.createBaby, flips '
      'onboarding_done, navigates to the post-consent loading transition', (
    tester,
  ) async {
    when(
      () => babyProfile.createBaby(any(), any(), any(), any()),
    ).thenAnswer((_) async => Result.success(_fakeBaby));
    when(flags.setOnboardingDone).thenAnswer((_) {});

    final container = _makeContainer(
      babyProfile: babyProfile,
      flags: flags,
      dob: dob,
    );
    await _pumpConsent(tester, container: container);

    await _tickAll(tester);
    await tester.tap(find.byKey(const Key('onboarding_consent_submit')));
    await tester.pumpAndSettle();

    verify(() => babyProfile.createBaby('Lily', dob, any(), any())).called(1);
    verify(flags.setOnboardingDone).called(1);
    // NIB-137 — consent now pushes through the loading transition; that
    // screen owns the auto-route to /home and is tested in isolation.
    expect(find.text('LOADING_STUB'), findsOneWidget);
    expect(find.text('HOME_STUB'), findsNothing);
  });

  testWidgets(
    'on submit failure: inline P1 error renders verbatim; nav does NOT fire; '
    'onboarding_done is NOT flipped',
    (tester) async {
      when(() => babyProfile.createBaby(any(), any(), any(), any())).thenAnswer(
        (_) async => const Result.failure(ServerException('boom from server')),
      );
      when(flags.setOnboardingDone).thenAnswer((_) {});

      final container = _makeContainer(
        babyProfile: babyProfile,
        flags: flags,
        dob: dob,
      );
      await _pumpConsent(tester, container: container);

      await _tickAll(tester);
      await tester.tap(find.byKey(const Key('onboarding_consent_submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('onboarding_consent_error')), findsOneWidget);
      expect(find.text('boom from server'), findsOneWidget);
      expect(find.text('HOME_STUB'), findsNothing);
      verifyNever(flags.setOnboardingDone);
    },
  );

  testWidgets('CTA is disabled while the submit is in flight (widget-layer '
      'double-submit guard — see PR body: no controller-level guard)', (
    tester,
  ) async {
    final completer = Completer<Result<Baby>>();
    when(
      () => babyProfile.createBaby(any(), any(), any(), any()),
    ).thenAnswer((_) => completer.future);
    when(flags.setOnboardingDone).thenAnswer((_) {});

    final container = _makeContainer(
      babyProfile: babyProfile,
      flags: flags,
      dob: dob,
    );
    await _pumpConsent(tester, container: container);

    await _tickAll(tester);
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

    verify(() => babyProfile.createBaby(any(), any(), any(), any())).called(1);

    // Release the future so teardown doesn't dangle a pending Completer.
    completer.complete(Result.success(_fakeBaby));
    await tester.pumpAndSettle();
  });
}
