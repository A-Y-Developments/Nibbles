import 'package:hive_flutter/hive_flutter.dart';
import 'package:nibbles/src/app/constants/hive_box_names.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_flag_service.g.dart';

/// Wraps the `local_flags` Hive box.
///
/// Read operations are synchronous — the box is opened before runApp.
/// Write operations are fire-and-forget (Hive writes are async but callers
/// do not need to await them for flag semantics).
class LocalFlagService {
  LocalFlagService(this._box);

  final Box<dynamic> _box;

  // ---------------------------------------------------------------------------
  // App launch flag
  // ---------------------------------------------------------------------------

  /// Returns `true` if the app has been launched at least once.
  bool hasLaunched() =>
      _box.get('app_has_launched', defaultValue: false) as bool;

  /// Marks the app as having been launched.
  void setHasLaunched() => _box.put('app_has_launched', true);

  // ---------------------------------------------------------------------------
  // Onboarding flow flags
  // ---------------------------------------------------------------------------

  bool isOnboardingReadinessDone() =>
      _box.get('onboarding_readiness_done', defaultValue: false) as bool;

  void setOnboardingReadinessDone() =>
      _box.put('onboarding_readiness_done', true);

  bool isOnboardingBabySetupDone() =>
      _box.get('onboarding_baby_setup_done', defaultValue: false) as bool;

  void setOnboardingBabySetupDone() =>
      _box.put('onboarding_baby_setup_done', true);

  /// Flips true after consent submit + createBaby success. Final gate before
  /// /home; consent itself is NOT persisted (NIB-120 — ephemeral UI gate).
  bool isOnboardingDone() =>
      _box.get('onboarding_done', defaultValue: false) as bool;

  void setOnboardingDone() => _box.put('onboarding_done', true);

  /// Clears all three onboarding progress flags. Called by splash when a
  /// logged-in user has no baby row yet — the in-memory hoisted state from a
  /// previous run is gone after process death, so stale `*_done` flags must be
  /// reset to replay the flow from /onboarding/name. Resetting ALL three (not
  /// just baby-setup) keeps a kill-after-readiness path from skipping the
  /// readiness step on resume.
  void resetOnboardingProgress() {
    _box
      ..put('onboarding_baby_setup_done', false)
      ..put('onboarding_readiness_done', false)
      ..put('onboarding_done', false);
  }

  // ---------------------------------------------------------------------------
  // Per-baby allergen program completion flag
  // ---------------------------------------------------------------------------

  /// Returns `true` if the completion screen has been shown for `babyId`.
  bool isProgramCompletionShown(String babyId) =>
      _box.get('program_completion_shown_$babyId', defaultValue: false) as bool;

  /// Marks the completion screen as shown for `babyId`.
  void setProgramCompletionShown(String babyId) =>
      _box.put('program_completion_shown_$babyId', true);

  /// Awaitable variant of [setProgramCompletionShown]. Used by the AL-08
  /// reachability gate in `allergen_log_screen.dart` (NIB-128) so the flag
  /// flip is durable BEFORE we route to `/home/allergen/complete`.
  Future<void> markProgramCompletionShown(String babyId) =>
      _box.put('program_completion_shown_$babyId', true);

  // ---------------------------------------------------------------------------
  // Recipe Library — first-launch 'Read Guide' banner flag (NIB-53)
  // ---------------------------------------------------------------------------

  /// Returns `true` if the user has dismissed the Recipe Library first-launch
  /// 'Read Guide' banner (by tapping its CTA or the bookmark in the header).
  bool isStartingGuideSeen() =>
      _box.get('starting_guide_seen', defaultValue: false) as bool;

  /// Marks the Starting Guide as seen. Awaited so the banner stays dismissed
  /// across the same frame's rebuild.
  Future<void> markStartingGuideSeen() =>
      _box.put('starting_guide_seen', true);

  // ---------------------------------------------------------------------------
  // Account deletion (NIB-85 / NIB-120)
  // ---------------------------------------------------------------------------

  /// Set by the profile delete-account flow (NIB-78) BEFORE the auth
  /// `signOut()` call so the router/splash can treat the session as deleted
  /// even if a stale Supabase session is still cached.
  bool isAccountDeleted() =>
      _box.get('account_deleted', defaultValue: false) as bool;

  /// Awaitable so the flag is durable before signOut() races.
  Future<void> setAccountDeleted() => _box.put('account_deleted', true);

  /// Wipes every key in the `local_flags` box. Called by the delete-account
  /// flow BEFORE signing out so that re-registering on the same device
  /// replays onboarding from scratch (no stale `onboarding_*_done`,
  /// `program_completion_shown_*`, `starting_guide_seen`, etc.).
  Future<void> clearAll() => _box.clear();
}

@riverpod
// ignore: deprecated_member_use_from_same_package // *Ref types deprecated in riverpod 3.0; upgrade deferred
LocalFlagService localFlagService(LocalFlagServiceRef ref) {
  return LocalFlagService(Hive.box<dynamic>(HiveBoxNames.localFlags));
}
