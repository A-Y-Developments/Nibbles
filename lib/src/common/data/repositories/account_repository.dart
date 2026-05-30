import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'account_repository.g.dart';

/// Account-scoped operations that don't belong on AuthRepository (which is
/// strictly Supabase auth) — namely, the NIB-120 soft-delete RPC.
///
/// The abstract interface is intentional even with a single method: it lets
/// `AccountService` test against a `Mock implements AccountRepository` and
/// matches the Repository pattern documented in CLAUDE.md.
// ignore: one_member_abstracts
abstract interface class AccountRepository {
  /// Calls `request_account_deletion(p_reason)` — inserts a row into
  /// `account_deletion_requests` and soft-deletes the user's babies. The
  /// Supabase auth user is NOT removed here; that's an ops-side purge.
  Future<Result<void>> requestAccountDeletion(String reason);
}

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<Result<void>> requestAccountDeletion(String reason) async {
    try {
      await _supabase.rpc<void>(
        'request_account_deletion',
        params: {'p_reason': reason},
      );
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }
}

@Riverpod(keepAlive: true)
// Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
// ignore: deprecated_member_use_from_same_package
AccountRepository accountRepository(AccountRepositoryRef ref) =>
    AccountRepositoryImpl();
