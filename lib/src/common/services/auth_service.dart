import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/repositories/baby_profile_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  late AuthRepository _repo;

  @override
  bool build() {
    _repo = ref.watch(authRepositoryProvider);

    // Keep state in sync with Supabase's internal auth events (session restore,
    // token refresh, expiry). Without this, the initial build() value would
    // never update if Supabase restores or clears a session after boot.
    final sub = _repo.authStateStream.listen((authState) {
      state = authState.session != null;
    });
    ref.onDispose(sub.cancel);

    return _repo.isLoggedIn;
  }

  bool get isLoggedIn => state;

  Stream<AuthState> get authStateStream => _repo.authStateStream;

  Future<Result<void>> signUp(
    String name,
    String email,
    String password,
  ) async {
    final result = await _repo.signUp(name, email, password);
    if (result.isSuccess) state = true;
    return result;
  }

  Future<Result<void>> signIn(String email, String password) async {
    final result = await _repo.signIn(email, password);
    if (result.isSuccess) {
      // Backfill Hive flags before triggering router redirect so reinstalled
      // users with existing baby data skip onboarding.
      await _backfillOnboardingFlagsIfNeeded();
      state = true;
    }
    return result;
  }

  Future<void> _backfillOnboardingFlagsIfNeeded() async {
    final flags = ref.read(localFlagServiceProvider);
    if (flags.isOnboardingBabySetupDone()) return;
    try {
      final isCompleted = await ref
          .read(babyProfileRepositoryProvider)
          .isOnboardingCompleted();
      if (isCompleted) {
        flags
          ..setOnboardingReadinessDone()
          ..setOnboardingBabySetupDone();
      }
    } on Object {
      // Non-critical — if this fails the user re-does onboarding, which is safe
    }
  }

  Future<Result<void>> signOut() async {
    final result = await _repo.signOut();
    if (result.isSuccess) {
      try {
        await Purchases.logOut();
      } on Object {
        // RevenueCat logOut is best-effort — don't block sign out
      }
      state = false;
    }
    return result;
  }

  Future<Result<void>> resetPassword(String email) =>
      _repo.resetPassword(email);

  Future<Result<void>> updatePassword(String newPassword) =>
      _repo.updatePassword(newPassword);
}
