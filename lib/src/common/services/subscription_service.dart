import 'package:flutter/foundation.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/subscription_info.dart';
import 'package:nibbles/src/common/domain/entities/subscription_offering.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'subscription_service.g.dart';

/// Test-injectable signature for `url_launcher`'s `launchUrl`. Allows the
/// widget / controller tests to replace the platform call without touching
/// the method channel. Mirrors the `deleteAccountCrashRecorder` typedef +
/// provider seam from NIB-78.
typedef SubscriptionLaunchUrlFn =
    Future<bool> Function(Uri url, {LaunchMode mode});

Future<bool> _defaultLaunchUrl(
  Uri url, {
  LaunchMode mode = LaunchMode.platformDefault,
}) => launchUrl(url, mode: mode);

/// Provider for [SubscriptionLaunchUrlFn]. Defaults to the real `launchUrl`
/// from `url_launcher`; tests override it to assert calls without hitting the
/// platform channel.
@Riverpod(keepAlive: true)
SubscriptionLaunchUrlFn subscriptionLaunchUrl(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  SubscriptionLaunchUrlRef ref,
) => _defaultLaunchUrl;

/// Platform-default management URLs. Apps cannot programmatically cancel
/// App Store / Play subscriptions — the OS owns the cancellation UI. The
/// https URLs avoid an Info.plist `LSApplicationQueriesSchemes` entry that
/// `itms-apps://` would otherwise force.
@visibleForTesting
const String iosManagementUrl = 'https://apps.apple.com/account/subscriptions';
@visibleForTesting
const String androidManagementUrl =
    'https://play.google.com/store/account/subscriptions';

/// Stub SubscriptionService — to be wired through `purchases_flutter` in
/// NIB-18. State is the entitlement bool used by callers like the post-
/// purchase transition controller and the (currently deferred) router guard.
///
/// NIB-73 expands the surface with [info] so the Manage Subscription screen
/// can render plan / Started / Renewal from a single entitlement snapshot.
/// NIB-55 adds [loadOfferings] / [purchaseDefault] / [restore] so the paywall
/// reads its default trial offering and triggers purchase/restore at this
/// seam. Until NIB-18 lands the stub returns a fixed placeholder offering so
/// the UI never has to hardcode price strings, and the three P1 failure paths
/// (`purchaseFail` / `restoreNoEntitlement` / `offeringsLoadFail`) are wired
/// at the seam — tests override the provider to exercise them.
///
/// The shape mirrors what RevenueCat `customerInfo` will yield, so swapping
/// the stub for the real implementation is a no-op for callers.
@riverpod
class SubscriptionService extends _$SubscriptionService {
  /// Hardcoded placeholder offering. The string is taken verbatim from the
  /// Figma spec so the design renders correctly; NIB-18 replaces it with a
  /// real `StoreProduct.priceString` read from RevenueCat.
  ///
  /// IMPORTANT: this constant only lives in the SERVICE layer (the seam where
  /// RC will plug in). The paywall UI never references it directly — it reads
  /// the price out of controller state, which sources it from [loadOfferings].
  // TODO(NIB-18): replace with a real StoreProduct lookup via RC.
  static const SubscriptionOffering placeholderTrialOffering =
      SubscriptionOffering(
        productId: 'nibbles_yearly_placeholder',
        priceString: r'$29.99',
        periodLabel: 'yearly',
        trialDays: 3,
      );

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

  /// Loads the default trial offering. Stub returns the placeholder; NIB-18
  /// will replace with `Purchases.getOfferings()`. Returns [Result] so the
  /// controller can surface the `offeringsLoadFail` P1 state at the seam.
  Future<Result<SubscriptionOffering>> loadOfferings() async {
    // TODO(NIB-18): real `Purchases.getOfferings()` call.
    return const Result.success(placeholderTrialOffering);
  }

  /// Purchases the default trial offering. Stub flips entitlement to active
  /// and returns success; NIB-18 will wrap `Purchases.purchasePackage` and
  /// map RC errors → [AppException]. Returns [Result] so the controller can
  /// surface RC error messages verbatim (P1 modal).
  Future<Result<void>> purchaseDefault() async {
    // TODO(NIB-18): real `Purchases.purchasePackage` call.
    state = true;
    return const Result.success(null);
  }

  /// Restores entitlements. Stub returns `notFound` so callers can exercise
  /// the "No active subscription found." P1 path; NIB-18 will wrap
  /// `Purchases.restorePurchases` and flip [state] only when an active
  /// entitlement is actually returned.
  Future<Result<void>> restore() async {
    // TODO(NIB-18): real `Purchases.restorePurchases` call.
    return const Result.failure(
      NotFoundException('No active subscription found.'),
    );
  }

  /// Opens the OS-managed subscription page (NIB-82). Apps cannot
  /// programmatically cancel App Store / Play subscriptions, so the cancel
  /// flow deep-links to the store-owned cancellation UI.
  ///
  /// Returns [Failure] when the URL can't be opened — the overlay maps that
  /// onto a P2 toast ("Couldn't open subscription settings. Try again.") per
  /// the ticket's error rule. NIB-18 will swap the platform default for
  /// `customerInfo.managementURL` when RC is wired through.
  Future<Result<void>> openManagementPage() async {
    final launchFn = ref.read(subscriptionLaunchUrlProvider);
    final uri = Uri.parse(_managementUrl);
    try {
      final ok = await launchFn(uri, mode: LaunchMode.externalApplication);
      if (ok) return const Result.success(null);
      return const Result.failure(
        UnknownException("Couldn't open subscription settings. Try again."),
      );
    } on Object catch (_) {
      // url_launcher throws PlatformException when the OS rejects the URL.
      // Surface a P2-friendly message; the underlying exception is logged at
      // the call site (Crashlytics non-fatal) if needed.
      return const Result.failure(
        UnknownException("Couldn't open subscription settings. Try again."),
      );
    }
  }

  /// Resolves the platform-default management URL. iOS / Android only — web
  /// and desktop fall through to the iOS URL since the app ships
  /// mobile-only per CLAUDE.md (iOS 15+ / Android 10+).
  String get _managementUrl =>
      defaultTargetPlatform == TargetPlatform.android
          ? androidManagementUrl
          : iosManagementUrl;
}
