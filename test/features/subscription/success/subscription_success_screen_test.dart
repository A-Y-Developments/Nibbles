// NIB-130 — widget tests for the post-purchase transition screen.
//
// Covers:
//   - Loading frame renders the petal blob + UPPERCASE "LOADING" label.
//   - After the loading-min dwell, the screen flips to the success label.
//   - After the success dwell, the screen auto-routes to /home (no back nav
//     escape — PopScope.canPop is false until the route fires).
//
// `subscriptionServiceProvider` is overridden via Riverpod (no RC dependency)
// and durations are advanced via `tester.pump` so the suite is deterministic.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/success/subscription_success_controller.dart';
import 'package:nibbles/src/features/subscription/success/subscription_success_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Always-active [SubscriptionService] so the controller's fast path fires
/// and the suite doesn't have to wait the full loadingTimeout cap.
class _ActiveSubscriptionService extends SubscriptionService {
  @override
  bool build() => true;
}

/// Starts inactive; call [setActive] on the notifier to simulate provisioning.
class _InactiveSubscriptionService extends SubscriptionService {
  @override
  bool build() => false;
}

GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.subscriptionSuccess.path,
  routes: [
    GoRoute(
      path: AppRoute.subscriptionSuccess.path,
      name: AppRoute.subscriptionSuccess.name,
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

Widget _buildSut({required GoRouter router, bool startActive = true}) =>
    ProviderScope(
      overrides: [
        subscriptionServiceProvider.overrideWith(
          startActive
              ? _ActiveSubscriptionService.new
              : _InactiveSubscriptionService.new,
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );

/// Reads the *target* opacity of the [AnimatedOpacity] that wraps the widget
/// keyed [key]. Target (not currently-tweened) opacity is what we assert
/// against since it deterministically reflects the phase regardless of
/// where the cross-fade animation sits at the moment of the assertion.
double _opacityOf(WidgetTester tester, Key key) {
  final ancestor = tester.widget<AnimatedOpacity>(
    find.ancestor(of: find.byKey(key), matching: find.byType(AnimatedOpacity)),
  );
  return ancestor.opacity;
}

void main() {
  testWidgets(
    'loading frame renders the petal blob and UPPERCASE LOADING label',
    (tester) async {
      await tester.pumpWidget(
        _buildSut(router: _routerFor(const SubscriptionSuccessScreen())),
      );
      // One frame — controller is at `loading`, before the dwell elapses.
      await tester.pump();

      expect(
        find.byKey(const Key('subscription_success_blob')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('subscription_success_loading_label')),
        findsOneWidget,
      );
      // Verbatim copy from the Figma spec is rendered uppercased per CSS class.
      expect(find.text('LOADING'), findsOneWidget);

      // Both labels are always in the tree so the layout never shifts on
      // transition — visibility is gated by AnimatedOpacity. During loading
      // "You all set!" is laid out but fully transparent.
      expect(find.text('You all set!'), findsOneWidget);
      expect(
        _opacityOf(tester, const Key('subscription_success_done_label')),
        0.0,
      );
      expect(
        _opacityOf(tester, const Key('subscription_success_loading_label')),
        1.0,
      );
    },
  );

  testWidgets(
    'flips to "You all set!" after loadingMinDwell when service is active',
    (tester) async {
      await tester.pumpWidget(
        _buildSut(router: _routerFor(const SubscriptionSuccessScreen())),
      );
      // Advance past the min-dwell so the controller settles to success.
      await tester.pump(SubscriptionSuccessController.loadingMinDwell);
      await tester.pump();

      expect(
        find.byKey(const Key('subscription_success_done_label')),
        findsOneWidget,
      );
      expect(find.text('You all set!'), findsOneWidget);
      // Loading caption stays mounted (matches the Figma cross-fade snapshot)
      // but is rendered low-opacity in the success phase.
      expect(find.text('LOADING'), findsOneWidget);
      expect(
        _opacityOf(tester, const Key('subscription_success_done_label')),
        1.0,
      );
      expect(
        _opacityOf(tester, const Key('subscription_success_loading_label')),
        0.55,
      );
    },
  );

  testWidgets('after successDwell elapses the screen auto-routes to /home', (
    tester,
  ) async {
    final router = _routerFor(const SubscriptionSuccessScreen());
    await tester.pumpWidget(_buildSut(router: router));

    // Loading dwell + success dwell → screen schedules the /home push.
    await tester.pump(SubscriptionSuccessController.loadingMinDwell);
    await tester.pump();
    await tester.pump(SubscriptionSuccessController.successDwell);
    await tester.pumpAndSettle();

    expect(find.text('HOME_STUB'), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      AppRoute.home.path,
    );
  });

  testWidgets('slow path: flips to success after loadingTimeout + min-dwell', (
    tester,
  ) async {
    final router = _routerFor(const SubscriptionSuccessScreen());
    await tester.pumpWidget(_buildSut(router: router, startActive: false));
    await tester.pump();

    expect(
      _opacityOf(tester, const Key('subscription_success_done_label')),
      0.0,
    );

    // Timeout fires _flipAfter; since DateTime.now() is not faked,
    // remaining≈loadingMinDwell and a second timer is scheduled.
    await tester.pump(SubscriptionSuccessController.loadingTimeout);
    await tester.pump(SubscriptionSuccessController.loadingMinDwell);
    await tester.pump();

    expect(
      _opacityOf(tester, const Key('subscription_success_done_label')),
      1.0,
    );
  });

  testWidgets(
    'PopScope blocks back navigation while provisioning is in flight',
    (tester) async {
      final router = _routerFor(const SubscriptionSuccessScreen());
      await tester.pumpWidget(_buildSut(router: router));
      await tester.pump();

      // Attempt to pop from the GoRouter API — the wrapping PopScope sets
      // canPop=false, so the screen stays on the success route.
      unawaited(router.routerDelegate.popRoute());
      await tester.pump();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoute.subscriptionSuccess.path,
      );
      expect(find.text('HOME_STUB'), findsNothing);
    },
  );
}
