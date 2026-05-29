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
  /// Minimum time the brand splash stays visible so launch never flickers,
  /// regardless of how fast boot resolves.
  static const _brandFloor = Duration(milliseconds: 1800);

  /// Cap on how long we wait for Supabase to settle the restored session.
  /// Past this, we proceed on whatever the current session truth is rather
  /// than hanging the splash forever.
  static const _sessionSettleTimeout = Duration(seconds: 4);

  @override
  Future<String> build() async {
    // Start the brand floor at the top so it overlaps boot work; awaited in
    // the finally below. Net effect is max(brandFloor, bootWork) on BOTH the
    // success and the error path — keeping NIB-57's retry window intact.
    final floorDone = Future<void>.delayed(_brandFloor);
    try {
      await _awaitSessionSettled();

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

      // Seed local flags from Supabase so reinstalls don't re-trigger
      // onboarding.
      flags
        ..setOnboardingReadinessDone()
        ..setOnboardingBabySetupDone();

      // TODO(nibbles-backend): uncomment when subscriptionServiceProvider ships
      // if (!ref.read(subscriptionServiceProvider)) {
      //   return '/subscription/paywall';
      // }

      return '/home';
    } finally {
      await floorDone;
    }
  }

  /// Deterministically waits for Supabase to settle the restored session
  /// instead of guessing with a blind delay.
  ///
  /// On cold start with a persisted session, [AuthService.isLoggedIn] can be
  /// `false` at t=0 while Supabase asynchronously restores from the keychain.
  /// Reading it too early routes a logged-in user to `/auth/login` — the race
  /// this method kills.
  ///
  /// Fast path: if the session is already present, there is nothing to wait
  /// for. Otherwise await the first auth-state emission (the `initialSession`
  /// event = session-ready signal) with a timeout. A stalled restore resolves
  /// via timeout — never a hang — and the caller re-reads the current truth
  /// afterward, so a logged-out user is sent to `/auth/login` and a (rare)
  /// late-arriving session is still honored.
  ///
  /// A timeout is NOT a boot failure: it is swallowed here so it never reaches
  /// NIB-57's [_guardBoot] / P0 path. Genuine restore failures surface through
  /// the guarded reads below.
  Future<void> _awaitSessionSettled() async {
    if (ref.read(authServiceProvider)) return;

    final authService = ref.read(authServiceProvider.notifier);
    try {
      // Any first emission is the settle signal; `initialSession(null)` lets a
      // logged-out user proceed promptly without eating the full timeout.
      await authService.authStateStream.first.timeout(_sessionSettleTimeout);
    } on Object {
      // Timeout or a stream error: stop waiting and fall through. The caller
      // re-reads the current session truth, so this degrades to the
      // not-logged-in fallback rather than hanging or escalating to a P0.
    }
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
