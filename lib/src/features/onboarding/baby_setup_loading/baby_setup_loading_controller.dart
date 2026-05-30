import 'dart:async';

import 'package:nibbles/src/features/onboarding/baby_setup_loading/baby_setup_loading_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'baby_setup_loading_controller.g.dart';

/// NIB-137 — passive transition shown after the consent step submits
/// successfully and before the user lands on /home.
///
/// The actual `createBaby` future is owned by `OnboardingController.submit`
/// (NIB-100) — by the time this screen mounts, the baby already exists and
/// `onboarding_done` is true. So this controller only owns the *dwell*:
///
///   1. Render [BabySetupLoadingPhase.loading] immediately.
///   2. After [minDwell], flip to [BabySetupLoadingPhase.ready] so the screen
///      schedules its auto-route to /home.
///   3. [maxTimeout] is the safety belt — if some future preload were to be
///      wired in here it would force-settle anyway. Today minDwell elapses
///      first so the timeout is functionally a no-op, but the constant is
///      kept so the screen's PopScope + timeout semantics stay clearly named.
///
/// Min dwell is sized so the petal animation never just flashes (per Figma
/// audit rotating-icon cluster spec) and aligns with the NIB-130 subscription
/// success screen's 1500ms floor.
@riverpod
class BabySetupLoadingController extends _$BabySetupLoadingController {
  /// Floor on the loading frame so the petal animation reads as intentional
  /// transition rather than a flash. Verbatim per ticket acceptance:
  /// "Minimum 1.5s display".
  static const Duration minDwell = Duration(milliseconds: 1600);

  /// Hard timeout — surface the auto-route even if some future preload here
  /// stalls. Verbatim per ticket acceptance: "Maximum display duration: hard
  /// timeout (e.g. 8s)".
  static const Duration maxTimeout = Duration(seconds: 8);

  Timer? _dwellTimer;
  Timer? _timeoutTimer;

  @override
  BabySetupLoadingPhase build() {
    ref.onDispose(() {
      _dwellTimer?.cancel();
      _timeoutTimer?.cancel();
    });
    _scheduleSettle();
    return BabySetupLoadingPhase.loading;
  }

  /// Schedules both the min-dwell and the safety-belt timeout. First to fire
  /// flips the phase to [BabySetupLoadingPhase.ready]; the second fire is a
  /// no-op courtesy of the idempotency check inside [_markReady].
  void _scheduleSettle() {
    _dwellTimer = Timer(minDwell, _markReady);
    _timeoutTimer = Timer(maxTimeout, _markReady);
  }

  void _markReady() {
    if (state == BabySetupLoadingPhase.ready) return;
    state = BabySetupLoadingPhase.ready;
  }
}
