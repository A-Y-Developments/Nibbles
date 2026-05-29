import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_controller.g.dart';

/// Discriminable boot failure surfaced as the AsyncNotifier error state so the
/// splash screen can render a P0 (full-screen + retry) instead of leaking a raw
/// remote exception to the UI.
class SplashBootException implements Exception {
  const SplashBootException(this.cause);

  /// The original error (e.g. no connectivity) that broke boot.
  final Object cause;

  @override
  String toString() => 'SplashBootException: $cause';
}

@riverpod
class SplashController extends _$SplashController {
  @override
  Future<String> build() async {
    await Future<void>.delayed(const Duration(seconds: 3));

    final flags = ref.read(localFlagServiceProvider);
    if (!flags.hasLaunched()) {
      flags.setHasLaunched();
      // On reinstall the session may be restored (iOS keychain persists).
      // Fall through to the Supabase check so flags get backfilled.
      final isLoggedIn = ref.read(authServiceProvider);
      if (!isLoggedIn) return '/onboarding/intro';
    }

    final isLoggedIn = ref.read(authServiceProvider);
    if (!isLoggedIn) return '/auth/login';

    // Defensive: a failed remote read here (e.g. no connectivity) is a P0.
    // Wrap it so the screen renders a full-screen retry rather than a raw
    // AsyncError. Does NOT change baby_profile_service signatures.
    final baby = await _guardBoot(
      () => ref.read(babyProfileServiceProvider).getBaby(),
    );
    if (baby == null) return '/onboarding/intro';

    final onboardingDone = await _guardBoot(
      () => ref.read(babyProfileServiceProvider).onboardingCompleted,
    );
    if (!onboardingDone) return '/onboarding/intro';

    // Seed local flags from Supabase so reinstalls don't re-trigger onboarding.
    flags
      ..setOnboardingReadinessDone()
      ..setOnboardingBabySetupDone();

    // TODO(nibbles-backend): uncomment when subscriptionServiceProvider ships
    // if (!ref.read(subscriptionServiceProvider)) {
    //   return '/subscription/paywall';
    // }

    return '/home';
  }

  /// Runs a boot-critical remote read, rewrapping any throw as a
  /// [SplashBootException] so the AsyncNotifier error state is discriminable.
  Future<T> _guardBoot<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on Object catch (e) {
      throw SplashBootException(e);
    }
  }
}
