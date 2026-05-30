import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'feedback_repository.g.dart';

/// Write-only feedback ingestion. Inserts a row into the `feedback` table;
/// reads are admin-only (no SELECT policy), so this repo only exposes
/// [submit].
// ignore: one_member_abstracts
abstract interface class FeedbackRepository {
  /// Inserts a feedback row for the current user. The caller has already
  /// validated the message is non-empty; this method trims it before insert
  /// to match the SQL length check.
  Future<Result<void>> submit(String message);
}

class FeedbackRepositoryImpl implements FeedbackRepository {
  FeedbackRepositoryImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<Result<void>> submit(String message) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('feedback').insert({
        'user_id': userId,
        'message': message.trim(),
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
FeedbackRepository feedbackRepository(FeedbackRepositoryRef ref) =>
    FeedbackRepositoryImpl();
