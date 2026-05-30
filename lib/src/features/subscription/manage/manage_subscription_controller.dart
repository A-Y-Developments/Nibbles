import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/manage/manage_subscription_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manage_subscription_controller.g.dart';

/// AsyncNotifier for the Manage Subscription screen (NIB-73).
///
/// Reads the entitlement snapshot from [SubscriptionService.info]. Surfaces
/// repository failures as an `AsyncError` so the screen can render the P1
/// error placeholder + retry (mirrors the Profile screen error UI).
@riverpod
class ManageSubscriptionController extends _$ManageSubscriptionController {
  @override
  Future<ManageSubscriptionState> build() async {
    final result = await ref.read(subscriptionServiceProvider.notifier).info();
    return switch (result) {
      Success(:final data) => ManageSubscriptionState(info: data),
      // Re-throw the typed AppException so AsyncValue.error preserves the
      // domain error and the screen's error placeholder can read .message.
      Failure(:final error) => throw error,
    };
  }
}
