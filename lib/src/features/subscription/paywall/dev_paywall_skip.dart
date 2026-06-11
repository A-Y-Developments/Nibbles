import 'package:nibbles/src/app/config/flavor_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dev_paywall_skip.g.dart';

/// NIB-150 — dev-flavor-only seam past the M2 paywall gate (SB-01) so
/// automated QA flows can finish onboarding without a StoreKit purchase.
/// Session-scoped on purpose: nothing is persisted, prod flavor never
/// renders the affordance and the redirect ignores the flag outside dev.
@Riverpod(keepAlive: true)
bool devPaywallSkipEnabled(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  DevPaywallSkipEnabledRef ref,
) => FlavorConfig.instance.isDev;

@Riverpod(keepAlive: true)
class DevPaywallSkip extends _$DevPaywallSkip {
  @override
  bool build() => false;

  void skip() => state = true;
}
