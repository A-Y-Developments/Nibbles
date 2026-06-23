import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/subscription_info.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/manage/manage_subscription_controller.dart';
import 'package:nibbles/src/features/subscription/manage/manage_subscription_state.dart';

class _InactiveSubscriptionService extends SubscriptionService {
  @override
  bool build() => false;
}

class _FailingSubscriptionService extends SubscriptionService {
  @override
  bool build() => false;

  @override
  Future<Result<SubscriptionInfo>> info() async =>
      const Result.failure(ServerException('service unavailable'));
}

ProviderContainer _container(SubscriptionService Function() factory) {
  final c = ProviderContainer(
    overrides: [subscriptionServiceProvider.overrideWith(factory)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('ManageSubscriptionController.build', () {
    test('success — maps SubscriptionInfo into state', () async {
      final c = _container(_InactiveSubscriptionService.new);

      final state = await c.read(manageSubscriptionControllerProvider.future);

      expect(state, isA<ManageSubscriptionState>());
      expect(state.info.isActive, isFalse);
    });

    test('failure — throws AppException into AsyncError', () async {
      final c = _container(_FailingSubscriptionService.new);

      await expectLater(
        c.read(manageSubscriptionControllerProvider.future),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
