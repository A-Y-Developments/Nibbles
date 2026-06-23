import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nibbles/src/app/constants/hive_box_names.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/features/onboarding/readiness/onboarding_readiness_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-83 — widget tests for `OnboardingReadinessScreen`.
///
/// Pins:
///   - the 6-step questionnaire renders "1 of 6 Questions" through
///     "6 of 6 Questions" verbatim.
///   - tapping a card stores the answer but does NOT auto-advance; Next
///     does.
///   - Q1 (pediatrician gate) writes to a separate state field; Q2-Q6
///     write to `readinessAnswers[0..4]` so downstream signs_met math
///     keeps its length-5 contract.
///   - back-nav inside the stepper preserves answers captured at earlier
///     steps via the hoisted controller (keepAlive).
///
/// The screen calls `localFlagServiceProvider.setOnboardingReadinessDone()`
/// in `_finish` (after step 6). We don't tap step 6 in these tests so the
/// local flag service isn't reached. Hive box init guards the test in case
/// any future helper does flip the flag during back-nav.
GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.onboardingReadiness.path,
  routes: [
    GoRoute(
      path: AppRoute.onboardingReadiness.path,
      name: AppRoute.onboardingReadiness.name,
      builder: (_, __) => screen,
    ),
    GoRoute(
      path: AppRoute.onboardingResult.path,
      name: AppRoute.onboardingResult.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('RESULT_STUB'))),
    ),
  ],
);

Future<void> _initHiveLocalFlags() async {
  Hive.init('.dart_tool/test_hive_readiness');
  if (!Hive.isBoxOpen(HiveBoxNames.localFlags)) {
    await Hive.openBox<dynamic>(HiveBoxNames.localFlags);
  }
}

void main() {
  setUpAll(_initHiveLocalFlags);

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  Future<void> pumpReadiness(
    WidgetTester tester, {
    required ProviderContainer container,
  }) async {
    // Bump test surface so the AspectRatio choice cards + Spacer fit. The
    // default 800x600 (with toolbar + safe area paddings) overflows the
    // Column. A phone-portrait-ish viewport keeps the layout stable.
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: _routerFor(const OnboardingReadinessScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapYesAndAdvance(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('readiness_choice_yes')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_readiness_next')));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the "1 of 6 Questions" counter on first paint', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Seed a baby name so question copy doesn't interpolate to the
    // "your baby" fallback.
    container.read(onboardingControllerProvider.notifier).updateName('Lily');

    await pumpReadiness(tester, container: container);

    expect(find.text('1 of 6 Questions'), findsOneWidget);
    // Q1 is the pediatrician-approval gate (Figma 971:10293).
    expect(find.text('Is Lily ready for solids?'), findsOneWidget);
    expect(find.text('Yes, our pediatrician approved it.'), findsOneWidget);
  });

  testWidgets(
    'tapping a card alone does NOT advance; Next CTA advances 1/6 -> 2/6',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(onboardingControllerProvider.notifier).updateName('Lily');

      await pumpReadiness(tester, container: container);

      // Tap the Yes card — selection is captured but counter stays put.
      await tester.tap(find.byKey(const Key('readiness_choice_yes')));
      await tester.pumpAndSettle();
      expect(find.text('1 of 6 Questions'), findsOneWidget);

      // Next CTA advances.
      await tester.tap(find.byKey(const Key('onboarding_readiness_next')));
      await tester.pumpAndSettle();
      expect(find.text('2 of 6 Questions'), findsOneWidget);
    },
  );

  testWidgets(
    'Next is disabled until the user picks an answer on the active step',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(onboardingControllerProvider.notifier).updateName('Lily');

      await pumpReadiness(tester, container: container);

      // Tap Next without selecting — counter must stay at 1/6.
      await tester.tap(find.byKey(const Key('onboarding_readiness_next')));
      await tester.pumpAndSettle();
      expect(find.text('1 of 6 Questions'), findsOneWidget);

      // Now select + Next — counter advances.
      await tester.tap(find.byKey(const Key('readiness_choice_yes')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding_readiness_next')));
      await tester.pumpAndSettle();
      expect(find.text('2 of 6 Questions'), findsOneWidget);
    },
  );

  testWidgets(
    'Yes on Q1 writes to pediatricianApproved; Yes on Q2 writes to '
    'readinessAnswers[0] (length-5 sign list preserved for NIB-91 downstream)',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(onboardingControllerProvider.notifier).updateName('Lily');

      await pumpReadiness(tester, container: container);

      // Q1 -> Yes.
      await tapYesAndAdvance(tester);

      var state = container.read(onboardingControllerProvider);
      expect(state.pediatricianApproved, isTrue);
      // Sign list untouched.
      expect(state.readinessAnswers, [null, null, null, null, null]);

      // Q2 -> Yes (writes to readinessAnswers[0]).
      await tapYesAndAdvance(tester);

      state = container.read(onboardingControllerProvider);
      expect(state.readinessAnswers[0], isTrue);
      expect(state.readinessAnswers[1], isNull);
    },
  );

  testWidgets(
    'back-nav inside the stepper preserves answers captured at earlier steps '
    '(keepAlive contract via the hoisted controller)',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(onboardingControllerProvider.notifier).updateName('Lily');

      await pumpReadiness(tester, container: container);

      // Q1 (pediatrician): Yes -> Next.
      await tapYesAndAdvance(tester);
      expect(find.text('2 of 6 Questions'), findsOneWidget);

      // Q2 (head): "Still figuring it out" -> Next.
      await tester.tap(find.byKey(const Key('readiness_choice_unsure')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding_readiness_next')));
      await tester.pumpAndSettle();
      expect(find.text('3 of 6 Questions'), findsOneWidget);

      // Back twice -> back at Q1; both earlier answers still on state.
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 6 Questions'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 6 Questions'), findsOneWidget);

      final state = container.read(onboardingControllerProvider);
      expect(state.pediatricianApproved, isTrue);
      expect(state.readinessAnswers[0], isFalse);
      expect(state.readinessAnswers[1], isNull);
      expect(state.readinessAnswers[2], isNull);
      expect(state.readinessAnswers[3], isNull);
      expect(state.readinessAnswers[4], isNull);
    },
  );

  testWidgets(
    'question content scrolls on a short viewport — no RenderFlex overflow, '
    'Next footer still present',
    (tester) async {
      // A short viewport that overflowed the old rigid Column + Spacer layout
      // (the other tests bump to 420x900 precisely to avoid that overflow).
      await tester.binding.setSurfaceSize(const Size(360, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(onboardingControllerProvider.notifier).updateName('Lily');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _routerFor(const OnboardingReadinessScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pre-fix this threw a "RenderFlex overflowed" error at this height.
      expect(tester.takeException(), isNull);
      // The question content now lives in a scroll view; the footer CTA stays
      // pinned (rendered outside the scroll view).
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(
        find.byKey(const Key('onboarding_readiness_next')),
        findsOneWidget,
      );
      expect(find.text('1 of 6 Questions'), findsOneWidget);
    },
  );
}
