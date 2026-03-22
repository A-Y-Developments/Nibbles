import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

const _kJwtKey = 'jwt_token';

abstract interface class AuthRepository {
  Future<Result<void>> signUp(String name, String email, String password);
  Future<Result<void>> signIn(String email, String password);
  Future<Result<void>> signOut();
  Future<Result<void>> resetPassword(String email);
  Future<Result<void>> updatePassword(String newPassword);
  bool get isLoggedIn;
  Stream<AuthState> get authStateStream;
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    SupabaseClient? supabaseClient,
    FlutterSecureStorage? storage,
  })  : _supabase = supabaseClient ?? Supabase.instance.client,
        _storage = storage ?? const FlutterSecureStorage();

  final SupabaseClient _supabase;
  final FlutterSecureStorage _storage;

  @override
  bool get isLoggedIn => _supabase.auth.currentSession != null;

  @override
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;

  @override
  Future<Result<void>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final token = response.session?.accessToken;
      if (token != null) {
        await _storage.write(key: _kJwtKey, value: token);
      }
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _storage.delete(key: _kJwtKey);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.nibbles://reset',
      );
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }
}

@Riverpod(keepAlive: true)
// Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
// ignore: deprecated_member_use_from_same_package
AuthRepository authRepository(AuthRepositoryRef ref) =>
    AuthRepositoryImpl();
