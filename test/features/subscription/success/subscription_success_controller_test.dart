// ignore_for_file: depend_on_referenced_packages // fake_async is a transitive dep
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/success/subscription_success_controller.dart';
import 'package:nibbles/src/features/subscription/success/subscription_success_state.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../../support/fake_analytics.dart';

class _InactiveSubscriptionService extends SubscriptionService {
  @override
  bool build() => false;
}

class _ActiveSubscriptionService extends SubscriptionService {
  @override
  bool build() => true;
}

ProviderContainer _makeContainer({bool startActive = false}) {
  final c = ProviderContainer(
    overrides: [
      subscriptionServiceProvider.overrideWith(
        startActive
            ? _ActiveSubscriptionService.new
            : _InactiveSubscriptionService.new,
      ),
      analyticsProvider.overrideWithValue(FakeAnalytics()),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

/// Keeps the auto-dispose provider alive while fake timers advance.
/// Without this, Riverpod's GC microtask disposes the provider (and cancels
/// its timer) before async.elapse() can fire it.
ProviderSubscription<SubscriptionSuccessPhase> _listen(ProviderContainer c) =>
    c.listen(subscriptionSuccessControllerProvider, (_, __) {});

void main() {
  group('SubscriptionSuccessController — fast path (isActive=true)', () {
    test('initial state is loading', () {
      fakeAsync((async) {
        final c = _makeContainer(startActive: true);
        _listen(c);
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.loading,
        );
      });
    });

    test('does not flip before loadingMinDwell', () {
      fakeAsync((async) {
        final c = _makeContainer(startActive: true);
        _listen(c);
        async.elapse(const Duration(milliseconds: 1199));
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.loading,
        );
      });
    });

    test('flips to success at loadingMinDwell', () {
      fakeAsync((async) {
        final c = _makeContainer(startActive: true);
        _listen(c);
        async.elapse(SubscriptionSuccessController.loadingMinDwell);
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.success,
        );
      });
    });
  });

  group('SubscriptionSuccessController — slow path timeout', () {
    test('initial state is loading when inactive', () {
      fakeAsync((async) {
        final c = _makeContainer();
        _listen(c);
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.loading,
        );
      });
    });

    test('stays loading before loadingTimeout fires', () {
      fakeAsync((async) {
        final c = _makeContainer();
        _listen(c);
        async.elapse(const Duration(seconds: 3, milliseconds: 999));
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.loading,
        );
      });
    });

    test('flips to success at loadingTimeout + loadingMinDwell', () {
      // _flipAfter uses DateTime.now() (not faked), so elapsed≈0ms in tests.
      // A second timer fires after another loadingMinDwell.
      fakeAsync((async) {
        final c = _makeContainer();
        _listen(c);
        async.elapse(
          SubscriptionSuccessController.loadingTimeout +
              SubscriptionSuccessController.loadingMinDwell,
        );
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.success,
        );
      });
    });
  });

  group('SubscriptionSuccessController — slow path listener', () {
    test('state is loading before subscription activates', () {
      fakeAsync((async) {
        final c = _makeContainer();
        _listen(c);
        async.elapse(const Duration(milliseconds: 500));
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.loading,
        );
      });
    });

    test('flips to success after sub activates', () {
      // Activate at T=500ms. _flipAfter schedules Timer(≈loadingMinDwell)
      // since DateTime.now() is not faked (elapsed≈0ms in tests).
      fakeAsync((async) {
        final c = _makeContainer();
        _listen(c);
        async.elapse(const Duration(milliseconds: 500));
        c.read(subscriptionServiceProvider.notifier).setActive(value: true);
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.loading,
        );
        async.elapse(SubscriptionSuccessController.loadingMinDwell);
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.success,
        );
      });
    });

    test('listener activation cancels the timeout timer', () {
      fakeAsync((async) {
        final c = _makeContainer();
        _listen(c);
        async.elapse(const Duration(milliseconds: 500));
        c.read(subscriptionServiceProvider.notifier).setActive(value: true);
        // Past the original 4s timeout — state must remain success.
        async
          ..elapse(SubscriptionSuccessController.loadingMinDwell)
          ..elapse(
            SubscriptionSuccessController.loadingTimeout +
                SubscriptionSuccessController.loadingMinDwell,
          );
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.success,
        );
      });
    });
  });

  group('SubscriptionSuccessController — idempotency', () {
    test('_flipToSuccess is a no-op when state is already success', () {
      fakeAsync((async) {
        final c = _makeContainer(startActive: true);
        _listen(c);
        async.elapse(SubscriptionSuccessController.loadingMinDwell);
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.success,
        );
        async.elapse(const Duration(seconds: 10));
        expect(
          c.read(subscriptionSuccessControllerProvider),
          SubscriptionSuccessPhase.success,
        );
      });
    });
  });
}
