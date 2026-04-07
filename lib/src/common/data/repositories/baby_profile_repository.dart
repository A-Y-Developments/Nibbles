import 'package:nibbles/src/common/data/mappers/baby_mapper.dart';
import 'package:nibbles/src/common/data/models/responses/baby_response.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'baby_profile_repository.g.dart';

abstract interface class BabyProfileRepository {
  Future<Result<Baby>> createBaby(String name, DateTime dob, Gender gender);
  Future<Baby?> getBaby();
  Future<Result<Baby>> updateBaby(
    String babyId,
    String name,
    DateTime dob,
    Gender gender,
  );
  Future<Result<void>> createAllergenProgramState(String babyId);
  Future<bool> isOnboardingCompleted();
}

class BabyProfileRepositoryImpl implements BabyProfileRepository {
  BabyProfileRepositoryImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  String get _userId {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw const UnauthorizedException();
    return uid;
  }

  @override
  Future<Result<Baby>> createBaby(
    String name,
    DateTime dob,
    Gender gender,
  ) async {
    try {
      final data = await _supabase
          .from('babies')
          .insert({
            'user_id': _userId,
            'name': name,
            'date_of_birth': dob.toIso8601String().split('T').first,
            'gender': gender.toJson(),
            'onboarding_completed': true,
          })
          .select()
          .single();
      return Result.success(BabyResponse.fromJson(data).toDomain());
    } on AppException catch (e) {
      return Result.failure(e);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Baby?> getBaby() async {
    try {
      final data = await _supabase
          .from('babies')
          .select()
          .eq('user_id', _userId)
          .limit(1)
          .maybeSingle();
      if (data == null) return null;
      return BabyResponse.fromJson(data).toDomain();
    } on Object {
      return null;
    }
  }

  @override
  Future<Result<Baby>> updateBaby(
    String babyId,
    String name,
    DateTime dob,
    Gender gender,
  ) async {
    try {
      final data = await _supabase
          .from('babies')
          .update({
            'name': name,
            'date_of_birth': dob.toIso8601String().split('T').first,
            'gender': gender.toJson(),
          })
          .eq('id', babyId)
          .select()
          .single();
      return Result.success(BabyResponse.fromJson(data).toDomain());
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> createAllergenProgramState(String babyId) async {
    try {
      await _supabase.from('allergen_program_state').insert({
        'baby_id': babyId,
        'current_allergen_key': 'peanut',
        'current_sequence_order': 1,
        'status': 'in_progress',
      });
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    try {
      final data = await _supabase
          .from('babies')
          .select('onboarding_completed')
          .eq('user_id', _userId)
          .limit(1)
          .maybeSingle();
      return data?['onboarding_completed'] as bool? ?? false;
    } on Object {
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
BabyProfileRepository babyProfileRepository(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  BabyProfileRepositoryRef ref,
) => BabyProfileRepositoryImpl();
