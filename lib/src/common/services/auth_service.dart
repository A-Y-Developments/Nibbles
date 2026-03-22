import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
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
    if (result.isSuccess) state = true;
    return result;
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
