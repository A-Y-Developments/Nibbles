import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nibbles/src/app/constants/hive_box_names.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/features/onboarding/readiness/onboarding_readiness_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-105 — widget tests for `OnboardingReadinessScreen` (NIB-83).
///
/// Pins:
///   - the 5-step stepper renders "1 of 5 Questions" through "5 of 5
///     Questions" verbatim.
///   - back-nav inside the stepper preserves answers captured at earlier
///     steps via the hoisted controller (keepAlive).
///
/// The screen calls `localFlagServiceProvider.setOnboardingReadinessDone()`
/// in `_finish` (after step 5). We don't tap step 5 in these tests — both
/// scenarios stay within step 4 — so the local flag service isn't reached.
/// Hive box init guards the test in case any future helper does flip the
/// flag during back-nav (currently doesn't).
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

  testWidgets(
    'renders the "1 of 5 Questions" counter on first paint',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Seed a baby name so the question copy doesn't interpolate to the
      // "your baby" fallback.
      container.read(onboardingControllerProvider.notifier).updateName('Lily');

      await pumpReadiness(tester, container: container);

      expect(find.text('1 of 5 Questions'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a card advances the counter 1/5 -> 2/5 -> 3/5 -> 4/5 -> 5/5',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(onboardingControllerProvider.notifier).updateName('Lily');

      await pumpReadiness(tester, container: container);

      for (var i = 1; i <= 5; i++) {
        expect(find.text('$i of 5 Questions'), findsOneWidget);
        if (i == 5) break;
        await tester.tap(find.byKey(const Key('readiness_choice_yes')));
        await tester.pumpAndSettle();
      }
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

      // Step 1: tap Yes -> advances to step 2.
      await tester.tap(find.byKey(const Key('readiness_choice_yes')));
      await tester.pumpAndSettle();
      expect(find.text('2 of 5 Questions'), findsOneWidget);

      // Step 2: tap "Still figuring it out" -> advances to step 3.
      await tester.tap(find.byKey(const Key('readiness_choice_unsure')));
      await tester.pumpAndSettle();
      expect(find.text('3 of 5 Questions'), findsOneWidget);

      // Back twice -> we're at step 1, and the controller still holds
      // both earlier answers.
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 5 Questions'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 5 Questions'), findsOneWidget);

      // Controller-level: answers list reflects both step taps, all later
      // indices remain null.
      final answers =
          container.read(onboardingControllerProvider).readinessAnswers;
      expect(answers[0], isTrue);
      expect(answers[1], isFalse);
      expect(answers[2], isNull);
      expect(answers[3], isNull);
      expect(answers[4], isNull);
    },
  );
}
