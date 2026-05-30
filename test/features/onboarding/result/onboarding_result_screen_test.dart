import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/features/onboarding/result/onboarding_result_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-105 — widget tests for `OnboardingResultScreen` (NIB-91).
///
/// Pins the soft-warn UX: Next routes forward to `/onboarding/consent` in
/// BOTH the ready and not-ready variants. Visual variant pins:
///   - ready (signsMet=5):     "New Journey Unlock!" eyebrow + score "5 / 5
///     signs".
///   - not-ready (signsMet=1): "Almost there" eyebrow + cross marks on each
///     not-met sign row + score "1 / 5 signs".
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
  String babyName = 'Lily',
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(onboardingControllerProvider.notifier)
    ..updateName(babyName)
    ..setReadinessAnswers(answers);

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
    'ready variant (signsMet=5) shows "New Journey Unlock!" eyebrow and the '
    '5 / 5 score badge',
    (tester) async {
      await _pumpResult(
        tester,
        answers: const <bool?>[true, true, true, true, true],
      );

      // Eyebrow is uppercased via .toUpperCase() before render.
      expect(find.text('NEW JOURNEY UNLOCK!'), findsOneWidget);
      expect(
        find.text('Lily is ready for solids at this time'),
        findsOneWidget,
      );
      expect(find.text('5 / 5 signs'), findsOneWidget);
    },
  );

  testWidgets(
    'not-ready variant (signsMet=1) shows "Almost there" eyebrow, 1 / 5 score '
    'and cross marks on the not-met rows',
    (tester) async {
      await _pumpResult(
        tester,
        answers: const <bool?>[true, false, false, false, false],
      );

      expect(find.text('ALMOST THERE'), findsOneWidget);
      expect(
        find.text('Lily is not ready for solids at this time'),
        findsOneWidget,
      );
      expect(find.text('1 / 5 signs'), findsOneWidget);

      // 4 not-met -> 4 cross marks; 1 met -> 1 check mark.
      expect(find.byIcon(Icons.close_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'boundary (signsMet=3) is the ready variant (NIB-120 majority gate)',
    (tester) async {
      await _pumpResult(
        tester,
        answers: const <bool?>[true, true, true, false, false],
      );

      expect(find.text('NEW JOURNEY UNLOCK!'), findsOneWidget);
      // Ready variant renders all rows positive regardless of per-answer
      // values (verbatim from `OnboardingResultScreen`'s `isPositive` rule):
      //   final isPositive = ready || (answers[i] ?? false);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.text('3 / 5 signs'), findsOneWidget);
    },
  );

  testWidgets('Next routes to /onboarding/consent in the READY variant',
      (tester) async {
    await _pumpResult(
      tester,
      answers: const <bool?>[true, true, true, true, true],
    );
    await tester.tap(find.byKey(const Key('onboarding_result_next')));
    await tester.pumpAndSettle();
    expect(find.text('CONSENT_STUB'), findsOneWidget);
  });

  testWidgets(
    'Next routes to /onboarding/consent in the NOT-READY variant too '
    '(soft-warn UX)',
    (tester) async {
      await _pumpResult(
        tester,
        answers: const <bool?>[false, false, false, false, false],
      );
      await tester.tap(find.byKey(const Key('onboarding_result_next')));
      await tester.pumpAndSettle();
      expect(find.text('CONSENT_STUB'), findsOneWidget);
    },
  );

  testWidgets(
    'baby name not captured -> headline falls back to "your baby"',
    (tester) async {
      await _pumpResult(
        tester,
        answers: const <bool?>[true, true, true, true, true],
        babyName: '',
      );
      expect(
        find.text('your baby is ready for solids at this time'),
        findsOneWidget,
      );
    },
  );
}
