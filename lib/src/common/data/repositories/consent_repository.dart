import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/enums/consent_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'consent_repository.g.dart';

/// Write+read consent receipts (NIB-145). The UX gate on the consent screen is
/// authoritative — this row is the supplementary DB receipt produced after a
/// successful baby creation.
// ignore: one_member_abstracts
abstract interface class ConsentRepository {
  /// Inserts a row into `consents` for the current user. `baby_id` is required
  /// at the API surface (consents only make sense in the context of a baby);
  /// the column is nullable in DB for schema flexibility.
  Future<Result<void>> recordConsent({
    required String babyId,
    required ConsentType type,
  });
}

class ConsentRepositoryImpl implements ConsentRepository {
  ConsentRepositoryImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<Result<void>> recordConsent({
    required String babyId,
    required ConsentType type,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('consents').insert({
        'user_id': userId,
        'baby_id': babyId,
        'consent_type': type.dbValue,
      });
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
ConsentRepository consentRepository(ConsentRepositoryRef ref) =>
    ConsentRepositoryImpl();
