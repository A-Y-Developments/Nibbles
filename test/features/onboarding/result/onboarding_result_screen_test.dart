import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/features/onboarding/result/onboarding_result_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-91 — widget tests for `OnboardingResultScreen`.
///
/// Pins the soft-warn UX (Next routes forward to `/onboarding/consent` in
/// BOTH variants) and the Figma-aligned visuals. The result reflects all six
/// questions (pediatrician gate + Q2-Q6) and is "ready" only when every sign
/// is met:
///   - ready variant (all 6 met): "New Journey Unlock!" eyebrow + ready
///     headline + all 6 rows positive + X/6 chip reflects actual score.
///   - not-ready variant (<6 met): no eyebrow, not-ready headline, per-answer
///     check/cross icons on each row.
GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.onboardingResult.path,
  routes: [
    GoRoute(
      path: AppRoute.onboardingResult.path,
      name: AppRoute.onboardingResult.name,
      builder: (_, __) => screen,
    ),
    GoRoute(
      path: AppRoute.onboardingConsent.path,
      name: AppRoute.onboardingConsent.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('CONSENT_STUB'))),
    ),
  ],
);

Future<void> _pumpResult(
  WidgetTester tester, {
  required List<bool?> answers,
  bool? pediatricianApproved,
  String babyName = 'Lily',
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final notifier = container.read(onboardingControllerProvider.notifier)
    ..updateName(babyName)
    ..setReadinessAnswers(answers);
  if (pediatricianApproved != null) {
    notifier.setPediatricianApproved(approved: pediatricianApproved);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: _routerFor(const OnboardingResultScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'ready variant (all 6 met) shows the "New Journey Unlock!" eyebrow, the '
    'ready headline and the 6/6 score chip',
    (tester) async {
      await _pumpResult(
        tester,
        pediatricianApproved: true,
        answers: const <bool?>[true, true, true, true, true],
      );

      expect(find.text('New Journey Unlock!'), findsOneWidget);
      expect(
        find.text('Lily is ready for solids at this time'),
        findsOneWidget,
      );
      expect(find.text('Readiness Signs'), findsOneWidget);
      expect(find.text('6/6'), findsOneWidget);
      // Ready variant renders all rows positive — 6 checks, 0 crosses.
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(6));
      expect(find.byIcon(Icons.cancel_outlined), findsNothing);
    },
  );

  testWidgets(
    'not-ready variant (1 of 6) drops the eyebrow, shows the not-ready '
    'headline, the 1/6 chip and per-answer check/cross icons',
    (tester) async {
      await _pumpResult(
        tester,
        pediatricianApproved: false,
        answers: const <bool?>[true, false, false, false, false],
      );

      // Not-ready variant carries no eyebrow per Figma 1029:8508.
      expect(find.text('New Journey Unlock!'), findsNothing);
      expect(
        find.text('Lily is not ready for solids at this time'),
        findsOneWidget,
      );
      expect(find.text('1/6'), findsOneWidget);

      // 5 not-met (pediatrician + 4 signs) -> 5 crosses; 1 met -> 1 check.
      expect(find.byIcon(Icons.cancel_outlined), findsNWidgets(5));
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    },
  );

  testWidgets('all-required gate: 5 of 6 (pediatrician missing) is NOT ready', (
    tester,
  ) async {
    await _pumpResult(
      tester,
      pediatricianApproved: false,
      answers: const <bool?>[true, true, true, true, true],
    );

    expect(find.text('New Journey Unlock!'), findsNothing);
    expect(
      find.text('Lily is not ready for solids at this time'),
      findsOneWidget,
    );
    expect(find.text('5/6'), findsOneWidget);
    // 5 developmental signs met -> 5 checks; pediatrician missing -> 1 cross.
    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(5));
    expect(find.byIcon(Icons.cancel_outlined), findsNWidgets(1));
  });

  testWidgets('Next routes to /onboarding/consent in the READY variant', (
    tester,
  ) async {
    await _pumpResult(
      tester,
      pediatricianApproved: true,
      answers: const <bool?>[true, true, true, true, true],
    );
    await tester.tap(find.byKey(const Key('onboarding_result_next')));
    await tester.pumpAndSettle();
    expect(find.text('CONSENT_STUB'), findsOneWidget);
  });

  testWidgets('Next routes to /onboarding/consent in the NOT-READY variant too '
      '(soft-warn UX)', (tester) async {
    await _pumpResult(
      tester,
      answers: const <bool?>[false, false, false, false, false],
    );
    await tester.tap(find.byKey(const Key('onboarding_result_next')));
    await tester.pumpAndSettle();
    expect(find.text('CONSENT_STUB'), findsOneWidget);
  });

  testWidgets('baby name not captured -> headline falls back to "your baby"', (
    tester,
  ) async {
    await _pumpResult(
      tester,
      pediatricianApproved: true,
      answers: const <bool?>[true, true, true, true, true],
      babyName: '',
    );
    expect(
      find.text('your baby is ready for solids at this time'),
      findsOneWidget,
    );
  });
}
