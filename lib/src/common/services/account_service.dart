import 'package:nibbles/src/common/data/repositories/account_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_service.g.dart';

/// Thin facade over [AccountRepository]. NIB-78's profile UI calls
/// [deleteAccount] with a reason from a user-selected enum; the actual
/// soft-delete semantics live in the SQL RPC.
class AccountService {
  const AccountService(this._repo);

  final AccountRepository _repo;

  Future<Result<void>> deleteAccount(String reason) =>
      _repo.requestAccountDeletion(reason);
}

@Riverpod(keepAlive: true)
// Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
// ignore: deprecated_member_use_from_same_package
AccountService accountService(AccountServiceRef ref) =>
    AccountService(ref.watch(accountRepositoryProvider));
