import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/subscription_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_service.g.dart';

/// Stub SubscriptionService — will be wired in NIB-18.
/// Returns false by default; redirect logic sends users to paywall.
///
/// NIB-73 expands the surface with [info] so the Manage Subscription screen
/// can render plan / Started / Renewal from a single entitlement snapshot.
/// The shape mirrors what RevenueCat `customerInfo` will yield, so swapping
/// the stub for the real implementation is a no-op for the screen.
@riverpod
class SubscriptionService extends _$SubscriptionService {
  @override
  bool build() => false;

  // Riverpod state assignment requires a method body —
  // setter syntax is not valid here.
  // ignore: use_setters_to_change_properties
  void setActive({required bool value}) => state = value;

  /// Returns the current entitlement snapshot.
  ///
  /// Stub-only: synthesises a deterministic [SubscriptionInfo] from the
  /// notifier's bool state. When active, surfaces a 30-day Free Trial
  /// window so the subscribed branch has plausible dates to render — the
  /// real RC-backed implementation (NIB-18) will replace this verbatim.
  Future<Result<SubscriptionInfo>> info() async {
    final active = state;
    if (!active) {
      return const Result.success(SubscriptionInfo(isActive: false));
    }
    final now = DateTime.now();
    final started = DateTime(now.year, now.month, now.day);
    final renews = started.add(const Duration(days: 30));
    return Result.success(
      SubscriptionInfo(
        isActive: true,
        planLabel: 'Free Trial',
        startedAt: started,
        renewsAt: renews,
        isTrial: true,
      ),
    );
  }
}
