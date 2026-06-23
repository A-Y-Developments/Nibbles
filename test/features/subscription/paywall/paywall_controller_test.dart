import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/paywall/paywall_controller.dart';
import 'package:nibbles/src/features/subscription/paywall/paywall_state.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../../support/fake_analytics.dart';

class _DefaultService extends SubscriptionService {
  @override
  bool build() => false;
}

class _RestoringService extends SubscriptionService {
  @override
  bool build() => false;

  @override
  Future<Result<void>> restore() async => const Result.success(null);
}

ProviderContainer _container({SubscriptionService Function()? svc}) {
  final c = ProviderContainer(
    overrides: [
      subscriptionServiceProvider.overrideWith(svc ?? _DefaultService.new),
      analyticsProvider.overrideWithValue(FakeAnalytics()),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('PaywallController.reloadOfferings', () {
    test('re-fetches offerings and transitions state to ready', () async {
      final c = _container();

      await c.read(paywallControllerProvider.notifier).reloadOfferings();

      expect(c.read(paywallControllerProvider).phase, PaywallPhase.ready);
    });
  });

  group('PaywallController.purchaseDefault', () {
    test('success — returns Success and resets action', () async {
      final c = _container();

      final result = await c
          .read(paywallControllerProvider.notifier)
          .purchaseDefault();

      expect(result.isSuccess, isTrue);
      expect(c.read(paywallControllerProvider).action, PaywallAction.none);
    });
  });

  group('PaywallController.restore', () {
    test('success — returns Success and resets action', () async {
      final c = _container(svc: _RestoringService.new);

      final result = await c.read(paywallControllerProvider.notifier).restore();

      expect(result.isSuccess, isTrue);
      expect(c.read(paywallControllerProvider).action, PaywallAction.none);
    });
  });
}
