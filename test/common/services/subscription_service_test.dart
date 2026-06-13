import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:url_launcher/url_launcher.dart';

ProviderContainer _makeContainer({
  SubscriptionLaunchUrlFn? launchUrl,
}) {
  final c = ProviderContainer(
    overrides: [
      if (launchUrl != null)
        subscriptionLaunchUrlProvider.overrideWithValue(launchUrl),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('SubscriptionService.setActive / build', () {
    test('initial state is false', () {
      final c = _makeContainer();
      expect(c.read(subscriptionServiceProvider), isFalse);
    });

    test('setActive(value: true) flips state to true', () {
      final c = _makeContainer();
      c.read(subscriptionServiceProvider.notifier).setActive(value: true);
      expect(c.read(subscriptionServiceProvider), isTrue);
    });

    test('setActive(value: false) sets state back to false', () {
      final c = _makeContainer();
      c.read(subscriptionServiceProvider.notifier)
        ..setActive(value: true)
        ..setActive(value: false);
      expect(c.read(subscriptionServiceProvider), isFalse);
    });
  });

  group('SubscriptionService.info', () {
    test('returns SubscriptionInfo(isActive: false) when state is false',
        () async {
      final c = _makeContainer();
      final result = await c.read(subscriptionServiceProvider.notifier).info();

      expect(result.isSuccess, isTrue);
      final info = result.dataOrNull!;
      expect(info.isActive, isFalse);
    });

    test('returns active SubscriptionInfo when state is true', () async {
      final c = _makeContainer();
      c.read(subscriptionServiceProvider.notifier).setActive(value: true);

      final result = await c.read(subscriptionServiceProvider.notifier).info();

      expect(result.isSuccess, isTrue);
      final info = result.dataOrNull!;
      expect(info.isActive, isTrue);
      expect(info.planLabel, 'Free Trial');
      expect(info.isTrial, isTrue);
      expect(info.startedAt, isNotNull);
      expect(info.renewsAt, isNotNull);
      expect(info.renewsAt!.difference(info.startedAt!).inDays, 30);
    });
  });

  group('SubscriptionService.loadOfferings', () {
    test('returns Success with the placeholder trial offering', () async {
      final c = _makeContainer();
      final result =
          await c.read(subscriptionServiceProvider.notifier).loadOfferings();

      expect(result.isSuccess, isTrue);
      final offering = result.dataOrNull!;
      expect(
        offering,
        equals(SubscriptionService.placeholderTrialOffering),
      );
      expect(offering.trialDays, 3);
      expect(offering.periodLabel, 'yearly');
    });
  });

  group('SubscriptionService.purchaseDefault', () {
    test('flips state to true and returns Success', () async {
      final c = _makeContainer();
      expect(c.read(subscriptionServiceProvider), isFalse);

      final result =
          await c.read(subscriptionServiceProvider.notifier).purchaseDefault();

      expect(result, isA<Success<void>>());
      expect(c.read(subscriptionServiceProvider), isTrue);
    });
  });

  group('SubscriptionService.restore', () {
    test('returns Failure(NotFoundException) with canonical message', () async {
      final c = _makeContainer();
      final result =
          await c.read(subscriptionServiceProvider.notifier).restore();

      expect(result, isA<Failure<void>>());
      expect(
        (result as Failure<void>).error,
        isA<NotFoundException>(),
      );
      expect(result.error.message, 'No active subscription found.');
    });
  });

  group('SubscriptionService.openManagementPage', () {
    test('returns Success when launchUrl returns true', () async {
      final c = _makeContainer(
        launchUrl: (uri, {mode = LaunchMode.platformDefault}) async => true,
      );

      final result = await c
          .read(subscriptionServiceProvider.notifier)
          .openManagementPage();

      expect(result, isA<Success<void>>());
    });

    test('returns Failure when launchUrl returns false', () async {
      final c = _makeContainer(
        launchUrl: (uri, {mode = LaunchMode.platformDefault}) async => false,
      );

      final result = await c
          .read(subscriptionServiceProvider.notifier)
          .openManagementPage();

      expect(result, isA<Failure<void>>());
      expect(
        (result as Failure<void>).error,
        isA<UnknownException>(),
      );
      expect(
        result.error.message,
        contains("Couldn't open subscription settings"),
      );
    });

    test('returns Failure when launchUrl throws', () async {
      final c = _makeContainer(
        launchUrl: (uri, {mode = LaunchMode.platformDefault}) async =>
            throw Exception('platform error'),
      );

      final result = await c
          .read(subscriptionServiceProvider.notifier)
          .openManagementPage();

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });
}
