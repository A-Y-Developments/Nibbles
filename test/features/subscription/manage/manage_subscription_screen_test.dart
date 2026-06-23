// NIB-73 — widget tests for the Manage Subscription screen.
//
// Covers:
//   - Not-subscribed branch renders the info card + "Go Premium" CTA.
//   - "Go Premium" pushes /subscription/paywall.
//   - Subscribed/trial branch renders plan label + Started/Renewal timeline
//     dates pulled from SubscriptionInfo (no hardcoded 15/08/2026).
//   - "Cancel Subscription" surfaces the placeholder until NIB-82 ships.
//   - Loading branch renders the spinner; error branch renders the retry CTA.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/entities/subscription_info.dart';
import 'package:nibbles/src/features/subscription/manage/manage_subscription_controller.dart';
import 'package:nibbles/src/features/subscription/manage/manage_subscription_screen.dart';
import 'package:nibbles/src/features/subscription/manage/manage_subscription_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

import '../../../support/fake_analytics.dart';

class _FakeManageSubscriptionController extends ManageSubscriptionController {
  _FakeManageSubscriptionController(this._initial);

  final AsyncValue<ManageSubscriptionState> _initial;

  @override
  Future<ManageSubscriptionState> build() async {
    return _initial.when(
      data: (state) => state,
      loading: () => Completer<ManageSubscriptionState>().future,
      error: Future<ManageSubscriptionState>.error,
    );
  }
}

const _paywallStubKey = Key('stub_paywall');
const _profileStubKey = Key('stub_profile');

GoRouter _router() => GoRouter(
  initialLocation: AppRoute.manageSubscription.path,
  routes: [
    GoRoute(
      path: AppRoute.manageSubscription.path,
      name: AppRoute.manageSubscription.name,
      builder: (_, __) => const ManageSubscriptionScreen(),
    ),
    GoRoute(
      path: AppRoute.paywall.path,
      name: AppRoute.paywall.name,
      builder: (_, __) => const Scaffold(
        key: _paywallStubKey,
        body: Center(child: Text('PAYWALL STUB')),
      ),
    ),
    GoRoute(
      path: AppRoute.profile.path,
      name: AppRoute.profile.name,
      builder: (_, __) => const Scaffold(
        key: _profileStubKey,
        body: Center(child: Text('PROFILE STUB')),
      ),
    ),
  ],
);

Widget _wrap(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(routerConfig: _router()),
);

List<Override> _overrides(AsyncValue<ManageSubscriptionState> state) => [
  analyticsProvider.overrideWithValue(FakeAnalytics()),
  manageSubscriptionControllerProvider.overrideWith(
    () => _FakeManageSubscriptionController(state),
  ),
];

void main() {
  // ---------------------------------------------------------------------------
  // Not-subscribed branch
  // ---------------------------------------------------------------------------

  testWidgets('not-subscribed: renders verbatim copy + "Go Premium" CTA', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _wrap(
        _overrides(
          const AsyncData(
            ManageSubscriptionState(info: SubscriptionInfo(isActive: false)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Manage Subscription'), findsOneWidget);
    expect(find.text('You are not subscribed'), findsOneWidget);
    expect(
      find.text(
        'You have a free Nibbles account. You can purchase a Premium '
        'subscription to access our full recipe, content and features.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('manage_subscription_go_premium_cta')),
      findsOneWidget,
    );
    expect(find.text('Go Premium'), findsOneWidget);
    // Cancel CTA is hidden in the not-subscribed branch.
    expect(
      find.byKey(const Key('manage_subscription_cancel_cta')),
      findsNothing,
    );
  });

  testWidgets(
    'not-subscribed: tapping "Go Premium" pushes /subscription/paywall',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(
          _overrides(
            const AsyncData(
              ManageSubscriptionState(info: SubscriptionInfo(isActive: false)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('manage_subscription_go_premium_cta')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(_paywallStubKey), findsOneWidget);
    },
  );

  // ---------------------------------------------------------------------------
  // Subscribed / trial branch
  // ---------------------------------------------------------------------------

  testWidgets(
    'subscribed: renders plan label, dd/MM/yyyy timeline dates, and copy',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Distinct started/renewal dates so we know they bind separately and
      // are NOT hardcoded to the Figma placeholder 15/08/2026.
      final started = DateTime(2026, 7, 3);
      final renews = DateTime(2026, 8, 15);

      await tester.pumpWidget(
        _wrap(
          _overrides(
            AsyncData(
              ManageSubscriptionState(
                info: SubscriptionInfo(
                  isActive: true,
                  planLabel: 'Free Trial',
                  startedAt: started,
                  renewsAt: renews,
                  isTrial: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Subscription'), findsOneWidget);
      // Verbatim intro copy — leading space before the colon is preserved.
      expect(find.text('You are subscribed to :'), findsOneWidget);
      expect(find.text('Free Trial'), findsOneWidget);
      // Verbatim timeline labels — trailing space after the colon preserved.
      expect(find.text('Started : '), findsOneWidget);
      expect(find.text('Renewal : '), findsOneWidget);
      expect(
        find.byKey(const Key('manage_subscription_started_value')),
        findsOneWidget,
      );
      expect(find.text('03/07/2026'), findsOneWidget);
      expect(find.text('15/08/2026'), findsOneWidget);
      expect(
        find.text(
          'You can cancel your subscription plan. If you cancel, you can '
          'keep using the subscription until the next billing date.',
        ),
        findsOneWidget,
      );
      // Cancel CTA is the primary action on the subscribed branch.
      expect(
        find.byKey(const Key('manage_subscription_cancel_cta')),
        findsOneWidget,
      );
      expect(find.text('Cancel Subscription'), findsOneWidget);
      // Go Premium CTA is hidden in the subscribed branch.
      expect(
        find.byKey(const Key('manage_subscription_go_premium_cta')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'subscribed: tapping "Cancel Subscription" surfaces the NIB-82 overlay',
    (tester) async {
      // Tall surface so the bottom sheet (92% of viewport) fits the chips
      // and both CTAs without scrolling.
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(
          _overrides(
            AsyncData(
              ManageSubscriptionState(
                info: SubscriptionInfo(
                  isActive: true,
                  planLabel: 'Free Trial',
                  startedAt: DateTime(2026, 7, 3),
                  renewsAt: DateTime(2026, 8, 15),
                  isTrial: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('manage_subscription_cancel_cta')));
      await tester.pumpAndSettle();

      // Verbatim sheet heading from Figma 1216:12029 (U+2019 apostrophe).
      expect(find.text('Tell us why you’re canceling'), findsOneWidget);
      expect(
        find.byKey(const Key('cancel_subscription_continue_button')),
        findsOneWidget,
      );
    },
  );

  // ---------------------------------------------------------------------------
  // Loading + error branches
  // ---------------------------------------------------------------------------

  testWidgets('loading: renders the spinner placeholder', (tester) async {
    await tester.pumpWidget(_wrap(_overrides(const AsyncLoading())));
    // Single pump — spinner animates indefinitely so pumpAndSettle would
    // block.
    await tester.pump();

    expect(
      find.byKey(const Key('manage_subscription_loading')),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error: renders error message + retry CTA', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _overrides(
          const AsyncError<ManageSubscriptionState>(
            ServerException('boom'),
            StackTrace.empty,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('manage_subscription_error_message')),
      findsOneWidget,
    );
    expect(find.text('boom'), findsOneWidget);
    expect(
      find.byKey(const Key('manage_subscription_retry_button')),
      findsOneWidget,
    );
    expect(find.text('Try Again'), findsOneWidget);
  });
}
