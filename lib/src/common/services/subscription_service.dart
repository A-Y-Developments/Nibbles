import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_service.g.dart';

/// Stub SubscriptionService — will be wired in NIB-18.
/// Returns false by default; redirect logic sends users to paywall.
@riverpod
class SubscriptionService extends _$SubscriptionService {
  @override
  bool build() => false;

  // Riverpod state assignment requires a method body —
  // setter syntax is not valid here.
  // ignore: use_setters_to_change_properties
  void setActive({required bool value}) => state = value;
}
