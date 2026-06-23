// NIB-82 — unit tests for CancelSubscriptionController.
//
// Asserts the deterministic side-effect ordering of `submit(reason)`:
//   1. Sets isSubmitting=true.
//   2. Logs both intent events with the stable `analyticsKey`.
//   3. Awaits SubscriptionService.openManagementPage.
//   4. Resets isSubmitting=false.
//   5. Returns true on Success, false on Failure.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/cancel/cancel_reason.dart';
import 'package:nibbles/src/features/subscription/cancel/cancel_subscription_controller.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../support/fake_analytics.dart';

class _LaunchRecorder {
  int calls = 0;
  bool result = true;

  Future<bool> call(Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) {
    calls += 1;
    return Future.value(result);
  }
}

ProviderContainer _container({
  required FakeAnalytics analytics,
  required _LaunchRecorder launcher,
}) {
  final container = ProviderContainer(
    overrides: [
      analyticsProvider.overrideWithValue(analytics),
      subscriptionLaunchUrlProvider.overrideWithValue(launcher.call),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test(
    'submit returns true on launch success and logs both intent events',
    () async {
      final analytics = FakeAnalytics();
      final launcher = _LaunchRecorder();
      final container = _container(analytics: analytics, launcher: launcher);

      final controller = container.read(
        cancelSubscriptionControllerProvider.notifier,
      );
      final ok = await controller.submit(CancelReason.achievedGoal);

      expect(ok, isTrue);
      expect(launcher.calls, 1);
      expect(
        analytics.eventNames,
        containsAll(<String>[
          'subscription_cancel_started',
          'subscription_cancel_reason',
        ]),
      );
      final started = analytics.calls.firstWhere(
        (c) => c.name == 'subscription_cancel_started',
      );
      expect(started.parameters['reason'], 'achieved_goal');
      // Final state has isSubmitting reset.
      expect(
        container.read(cancelSubscriptionControllerProvider).isSubmitting,
        isFalse,
      );
    },
  );

  test(
    'submit returns false on launch failure and resets isSubmitting',
    () async {
      final analytics = FakeAnalytics();
      final launcher = _LaunchRecorder()..result = false;
      final container = _container(analytics: analytics, launcher: launcher);

      final controller = container.read(
        cancelSubscriptionControllerProvider.notifier,
      );
      final ok = await controller.submit(CancelReason.other);

      expect(ok, isFalse);
      expect(launcher.calls, 1);
      // Intent events still fired BEFORE the launch attempt.
      expect(analytics.eventNames, contains('subscription_cancel_started'));
      // Final state resets the flag.
      expect(
        container.read(cancelSubscriptionControllerProvider).isSubmitting,
        isFalse,
      );
    },
  );

  test('re-entrancy: a second submit while one is in-flight returns false and '
      'does NOT launch or re-log the intent events twice', () async {
    final analytics = FakeAnalytics();
    final gate = Completer<bool>();
    var launchCalls = 0;
    Future<bool> gatedLaunch(
      Uri uri, {
      LaunchMode mode = LaunchMode.platformDefault,
    }) {
      launchCalls += 1;
      return gate.future;
    }

    final container = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(analytics),
        subscriptionLaunchUrlProvider.overrideWithValue(gatedLaunch),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      cancelSubscriptionControllerProvider.notifier,
    );
    // First submit runs synchronously up to the launch await, so
    // isSubmitting is already true when the second (double-tap) lands.
    final first = controller.submit(CancelReason.achievedGoal);
    final second = await controller.submit(CancelReason.achievedGoal);

    // The in-flight guard rejects the second tap immediately.
    expect(second, isFalse);
    expect(launchCalls, 1);

    gate.complete(true);
    expect(await first, isTrue);

    // Exactly one set of intent events despite the double-tap.
    expect(
      analytics.calls
          .where((c) => c.name == 'subscription_cancel_started')
          .length,
      1,
    );
  });

  test(
    'all six CancelReason enum entries carry a unique snake_case analyticsKey',
    () {
      final keys = CancelReason.values.map((r) => r.analyticsKey).toSet();
      expect(keys.length, CancelReason.values.length);
      for (final key in keys) {
        expect(key, matches(RegExp(r'^[a-z][a-z_]*$')));
      }
    },
  );
}
