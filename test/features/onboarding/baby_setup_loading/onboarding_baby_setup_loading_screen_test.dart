// NIB-137 — widget tests for the post-consent baby-setup loading transition.
//
// Covers:
//   - Loading frame renders the petal blob + faint "LOADING" caption + the
//     verbatim footer copy.
//   - PopScope blocks back navigation while the dwell is running.
//   - After [BabySetupLoadingController.minDwell] elapses the screen auto-
//     routes to /home (single edge — no double-fire on subsequent rebuilds).
//
// Durations are advanced via `tester.pump` so the suite is deterministic.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/features/onboarding/baby_setup_loading/baby_setup_loading_controller.dart';
import 'package:nibbles/src/features/onboarding/baby_setup_loading/onboarding_baby_setup_loading_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.onboardingBabySetupLoading.path,
  routes: [
    GoRoute(
      path: AppRoute.onboardingBabySetupLoading.path,
      name: AppRoute.onboardingBabySetupLoading.name,
      builder: (_, __) => screen,
    ),
    GoRoute(
      path: AppRoute.home.path,
      name: AppRoute.home.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('HOME_STUB'))),
    ),
  ],
);

Widget _buildSut({required GoRouter router}) => ProviderScope(
  child: MaterialApp.router(routerConfig: router),
);

void main() {
  testWidgets(
    'loading frame renders the petal blob, LOADING caption and footer copy',
    (tester) async {
      await tester.pumpWidget(
        _buildSut(
          router: _routerFor(const OnboardingBabySetupLoadingScreen()),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('onboarding_baby_setup_loading_blob')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_baby_setup_loading_caption')),
        findsOneWidget,
      );
      expect(find.text('LOADING'), findsOneWidget);
      // Verbatim copy from the Figma audit (grammar issue preserved).
      expect(
        find.text('We need several data to know more about your babys'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'after minDwell elapses the screen auto-routes to /home',
    (tester) async {
      final router = _routerFor(const OnboardingBabySetupLoadingScreen());
      await tester.pumpWidget(_buildSut(router: router));
      await tester.pump();

      // Advance past the min-dwell so the controller flips to `ready` and
      // the screen schedules its push to /home. The celebration animations
      // repeat() forever, so `pumpAndSettle` would hang — pump explicit frames
      // to let the GoRouter nav transition settle instead.
      await tester.pump(BabySetupLoadingController.minDwell);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('HOME_STUB'), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoute.home.path,
      );
    },
  );

  testWidgets(
    'PopScope blocks back navigation while the dwell is running',
    (tester) async {
      final router = _routerFor(const OnboardingBabySetupLoadingScreen());
      await tester.pumpWidget(_buildSut(router: router));
      await tester.pump();

      // Attempt to pop from the GoRouter API — PopScope.canPop is false so
      // the screen stays on the loading route until the auto-route fires.
      unawaited(router.routerDelegate.popRoute());
      await tester.pump();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoute.onboardingBabySetupLoading.path,
      );
      expect(find.text('HOME_STUB'), findsNothing);
    },
  );

  testWidgets(
    'within maxTimeout window the screen still ends up on /home',
    (tester) async {
      // Sanity: even under the safety-belt cap, the screen still resolves.
      // Today minDwell elapses first (so this is functionally the same as the
      // happy-path test) but the assertion guards a future where the dwell
      // is replaced by a real preload.
      final router = _routerFor(const OnboardingBabySetupLoadingScreen());
      await tester.pumpWidget(_buildSut(router: router));
      await tester.pump();

      // `pumpAndSettle` would hang on the forever-repeating celebration
      // animations — pump explicit frames to settle the nav transition.
      await tester.pump(BabySetupLoadingController.maxTimeout);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoute.home.path,
      );
    },
  );

  testWidgets(
    'celebration animation controllers are running (rotation advances)',
    (tester) async {
      await tester.pumpWidget(
        _buildSut(
          router: _routerFor(const OnboardingBabySetupLoadingScreen()),
        ),
      );
      await tester.pump();

      final rotation = tester.widget<RotationTransition>(
        find.descendant(
          of: find.byKey(const Key('onboarding_baby_setup_loading_blob')),
          matching: find.byType(RotationTransition),
        ),
      );
      final before = rotation.turns.value;

      // Advance a fraction of the dwell — the looping controller must tick.
      await tester.pump(const Duration(milliseconds: 500));

      expect(rotation.turns.value, isNot(equals(before)));
      expect(
        find.descendant(
          of: find.byKey(const Key('onboarding_baby_setup_loading_blob')),
          matching: find.byType(ScaleTransition),
        ),
        findsOneWidget,
      );
    },
  );
}
