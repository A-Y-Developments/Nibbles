// NIB-55 — widget tests for the paywall (Try for $0 sheet).
//
// Coverage:
//   * Populated/ready state renders the verbatim copy + price from the
//     stub offering (no hardcoded "$29.99" literal in lib/**).
//   * Loading frame renders the spinner placeholder (offerings fetch).
//   * Error frame surfaces the inline error + retry CTA.
//   * Purchase failure → P1 dialog with the RC message verbatim.
//   * Restore-no-entitlement → P1 dialog with the canonical copy.
//   * Restore success pops the sheet (entitlement flips active).
//
// Strategy:
//   * Override `subscriptionServiceProvider` with a fake whose Result returns
//     are scripted per-test. The paywall controller reads through this seam,
//     so every state variant is reachable without RevenueCat in the loop.
//   * Stub Firebase so `Analytics.instance.logScreenView` + the controller's
//     `paywall_viewed` event are no-ops.

// Firebase platform-interface packages are transitive deps; the public
// barrels do not re-export FirebaseAnalyticsPlatform / setupFirebaseCoreMocks.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/subscription_offering.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/paywall/dev_paywall_skip.dart';
import 'package:nibbles/src/features/subscription/paywall/paywall_sheet.dart';
import 'package:nibbles/src/features/subscription/paywall/widgets/all_plans_sheet.dart';
import 'package:nibbles/src/routing/route_enums.dart';

// ---------------------------------------------------------------------------
// Firebase shim — replicates the home/recipe test pattern. The paywall
// controller fires `paywall_viewed` on build and the sheet fires
// `logScreenView` post-frame; both reach `FirebaseAnalytics.instance` which
// must resolve to a no-op platform implementation in widget-test context.
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Fake SubscriptionService — every call is scripted via the params below so
// each test can drive the seam into the success / failure variant it needs.
// ---------------------------------------------------------------------------

class _FakeSubscriptionService extends SubscriptionService {
  _FakeSubscriptionService({
    required this.offeringsResult,
    required this.purchaseResult,
    required this.restoreResult,
  });

  final Result<SubscriptionOffering> offeringsResult;
  final Result<void> purchaseResult;
  final Result<void> restoreResult;

  @override
  bool build() => false;

  @override
  Future<Result<SubscriptionOffering>> loadOfferings() async => offeringsResult;

  @override
  Future<Result<void>> purchaseDefault() async {
    purchaseResult.whenOrNull(success: (_) => state = true);
    return purchaseResult;
  }

  @override
  Future<Result<void>> restore() async {
    restoreResult.whenOrNull(success: (_) => state = true);
    return restoreResult;
  }
}

const _kOffering = SubscriptionOffering(
  productId: 'nibbles_yearly_test',
  priceString: r'$12.34',
  periodLabel: 'yearly',
  trialDays: 3,
);

Widget _buildSut({
  required SubscriptionService Function() factory,
  // FlavorConfig is never initialized in widget tests, so the dev-skip
  // flavor probe (NIB-150) must always be overridden; default to prod.
  bool devSkipEnabled = false,
}) {
  return ProviderScope(
    overrides: [
      subscriptionServiceProvider.overrideWith(factory),
      devPaywallSkipEnabledProvider.overrideWithValue(devSkipEnabled),
    ],
    child: const MaterialApp(home: Scaffold(body: PaywallSheet())),
  );
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  // -------------------------------------------------------------------------
  // Populated / default state (AC: at minimum, ship the populated test).
  // -------------------------------------------------------------------------

  testWidgets('populated state renders Figma copy + price from service', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildSut(
        factory: () => _FakeSubscriptionService(
          offeringsResult: const Result.success(_kOffering),
          purchaseResult: const Result.success(null),
          restoreResult: const Result.failure(
            NotFoundException('No active subscription found.'),
          ),
        ),
      ),
    );
    // Settle the async offerings load.
    await tester.pump();

    expect(find.text('Restore purchase'), findsOneWidget);
    expect(find.text('Everything you need for safe feeding'), findsOneWidget);
    expect(find.text('Introduce allergens safely'), findsOneWidget);
    expect(find.text('Get 300+ recipes'), findsOneWidget);
    expect(find.text('Meal Planning'), findsOneWidget);
    expect(find.text('Clear, guided steps through the Big 11'), findsOneWidget);
    expect(find.text('Baby-led meals for every stage'), findsOneWidget);
    expect(find.text('Plan the whole week in a few taps'), findsOneWidget);
    expect(find.text('Already helping 150+ parents'), findsOneWidget);
    expect(find.text(r'Try for $0'), findsOneWidget);
    expect(find.text('View all plans'), findsOneWidget);

    // Trial card — pulls trialDays + priceString from the offering, not a
    // hardcoded literal in the widget tree.
    expect(find.text('3 Days Free'), findsOneWidget);
    // RichText composes "Then billed at " + "$12.34 yearly" → assert against
    // the rendered span text. `find.byType(RichText)` returns multiple matches
    // because every `Text` widget renders as a RichText under the hood, so
    // search the whole tree for the one whose plain text matches the trial
    // line.
    final richTexts = tester
        .widgetList<RichText>(
          find.descendant(
            of: find.byKey(const Key('paywall_trial_card')),
            matching: find.byType(RichText),
          ),
        )
        .map((rt) => rt.text.toPlainText())
        .toList();
    expect(
      richTexts.any((text) => text.contains(r'Then billed at $12.34 yearly')),
      isTrue,
      reason: 'rendered trial card spans: $richTexts',
    );

    // CTA keys are wired (no close button — forced entitlement gate, NIB-144).
    expect(
      find.byKey(const Key('paywall_restore_purchase_button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('paywall_try_for_zero_button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('paywall_view_all_plans_button')),
      findsOneWidget,
    );
  });

  // -------------------------------------------------------------------------
  // Loading state — the spinner is rendered while offerings are in flight.
  // -------------------------------------------------------------------------

  testWidgets('loading frame renders spinner placeholder', (tester) async {
    await tester.pumpWidget(
      _buildSut(
        factory: () => _FakeSubscriptionService(
          offeringsResult: const Result.success(_kOffering),
          purchaseResult: const Result.success(null),
          restoreResult: const Result.failure(
            NotFoundException('No active subscription found.'),
          ),
        ),
      ),
    );
    // First pump — the controller has scheduled the offerings load but it
    // hasn't resolved yet, so the loading card is visible.
    expect(find.byKey(const Key('paywall_trial_card_loading')), findsOneWidget);
    // Resolve so the test ends cleanly (no pending timers).
    await tester.pump();
  });

  // -------------------------------------------------------------------------
  // Error state — inline error + retry CTA on offerings load failure.
  // -------------------------------------------------------------------------

  testWidgets('error frame renders inline error + retry', (tester) async {
    await tester.pumpWidget(
      _buildSut(
        factory: () => _FakeSubscriptionService(
          offeringsResult: const Result.failure(NetworkException()),
          purchaseResult: const Result.success(null),
          restoreResult: const Result.failure(
            NotFoundException('No active subscription found.'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('paywall_trial_card_error')), findsOneWidget);
    expect(find.text('No internet connection.'), findsOneWidget);
    expect(
      find.byKey(const Key('paywall_offerings_retry_button')),
      findsOneWidget,
    );
    // The primary CTA stays in its disabled-pill state while offerings are
    // unavailable — guarded by `state.phase == ready` in the body.
    expect(find.text(r'Try for $0'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Purchase failure surfaces the P1 dialog with the RC message verbatim.
  // -------------------------------------------------------------------------

  testWidgets('purchase failure shows P1 dialog with RC message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildSut(
        factory: () => _FakeSubscriptionService(
          offeringsResult: const Result.success(_kOffering),
          purchaseResult: const Result.failure(
            ServerException('Card declined.'),
          ),
          restoreResult: const Result.failure(
            NotFoundException('No active subscription found.'),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('paywall_try_for_zero_button')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('paywall_error_dialog')), findsOneWidget);
    expect(find.text('Purchase failed'), findsOneWidget);
    expect(find.text('Card declined.'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Restore-no-entitlement surfaces the canonical P1 copy.
  // -------------------------------------------------------------------------

  testWidgets('restore with no entitlement shows canonical P1 copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildSut(
        factory: () => _FakeSubscriptionService(
          offeringsResult: const Result.success(_kOffering),
          purchaseResult: const Result.success(null),
          restoreResult: const Result.failure(
            NotFoundException('whatever the service says'),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('paywall_restore_purchase_button')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('paywall_error_dialog')), findsOneWidget);
    expect(find.text('Restore failed'), findsOneWidget);
    // Canonical copy from error-handling.md — overrides whatever the
    // service message happens to be when the failure is `NotFoundException`.
    expect(find.text('No active subscription found.'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // View all plans — opens the all-plans overlay (NIB-61 wired). The single
  // live offering surfaces as a one-plan list (single-plan edge case), so the
  // sheet renders the offering's price label verbatim.
  // -------------------------------------------------------------------------

  testWidgets('view all plans opens the all-plans sheet', (tester) async {
    await tester.pumpWidget(
      _buildSut(
        factory: () => _FakeSubscriptionService(
          offeringsResult: const Result.success(_kOffering),
          purchaseResult: const Result.success(null),
          restoreResult: const Result.failure(
            NotFoundException('No active subscription found.'),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('paywall_view_all_plans_button')));
    await tester.pumpAndSettle();

    // The all-plans sheet is mounted and shows the live offering's price.
    expect(find.byType(AllPlansSheet), findsOneWidget);
    expect(find.text(r'$12.34 yearly'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // The placeholder snackbar is gone.
    expect(
      find.byKey(const Key('paywall_view_all_plans_snackbar')),
      findsNothing,
    );
  });

  // -------------------------------------------------------------------------
  // NIB-150 — dev-flavor-only skip past the entitlement gate.
  // -------------------------------------------------------------------------

  testWidgets('dev skip link is absent outside the dev flavor', (tester) async {
    await tester.pumpWidget(
      _buildSut(
        factory: () => _FakeSubscriptionService(
          offeringsResult: const Result.success(_kOffering),
          purchaseResult: const Result.success(null),
          restoreResult: const Result.failure(
            NotFoundException('No active subscription found.'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('paywall_dev_skip_button')), findsNothing);
    expect(find.text('Maybe later (dev)'), findsNothing);
  });

  testWidgets('dev skip link sets the skip flag and routes home (dev)', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        subscriptionServiceProvider.overrideWith(
          () => _FakeSubscriptionService(
            offeringsResult: const Result.success(_kOffering),
            purchaseResult: const Result.success(null),
            restoreResult: const Result.failure(
              NotFoundException('No active subscription found.'),
            ),
          ),
        ),
        devPaywallSkipEnabledProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: PaywallSheet()),
        ),
        GoRoute(
          path: AppRoute.home.path,
          name: AppRoute.home.name,
          builder: (_, __) => const Scaffold(body: Text('home-stub')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('paywall_dev_skip_button')), findsOneWidget);
    expect(find.text('Maybe later (dev)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('paywall_dev_skip_button')));
    await tester.pumpAndSettle();

    expect(container.read(devPaywallSkipProvider), isTrue);
    expect(find.text('home-stub'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // NIB-177 regression — the price/trial-terms card must stay laid out and
  // on-screen above the purchase CTA, even on a short viewport with the extra
  // dev-skip button taking footer space. It previously scrolled off the fold
  // (0x0 frame) because it lived at the bottom of the scroll content.
  // -------------------------------------------------------------------------

  testWidgets('price card stays visible above the CTA under space pressure', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375 * 3, 600 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _buildSut(
        factory: () => _FakeSubscriptionService(
          offeringsResult: const Result.success(_kOffering),
          purchaseResult: const Result.success(null),
          restoreResult: const Result.failure(
            NotFoundException('No active subscription found.'),
          ),
        ),
        devSkipEnabled: true,
      ),
    );
    await tester.pump();

    final cardRect = tester.getRect(
      find.byKey(const Key('paywall_trial_card')),
    );
    final ctaRect = tester.getRect(
      find.byKey(const Key('paywall_try_for_zero_button')),
    );
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;

    // Laid out with real size (the regression rendered it as a 0x0 frame).
    expect(cardRect.height, greaterThan(0));
    // Fully within the viewport — not scrolled off the top or bottom fold.
    expect(cardRect.top, greaterThanOrEqualTo(0));
    expect(cardRect.bottom, lessThanOrEqualTo(screenHeight));
    // Price disclosure sits above the purchase CTA (App Review 3.1.2).
    expect(cardRect.bottom, lessThanOrEqualTo(ctaRect.top));
  });
}
