import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/common/data/repositories/baby_profile_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'baby_profile_service.g.dart';

class BabyProfileService {
  const BabyProfileService(this._repo);

  final BabyProfileRepository _repo;

  /// Creates the baby row + its allergen_program_state row ATOMICALLY.
  ///
  /// Atomicity lives at the repository/DB layer: the repository's `createBaby`
  /// calls the `create_baby_with_program` Postgres RPC, which does both inserts
  /// in a single transaction. A failure can therefore never orphan a baby row
  /// or duplicate it on retry (unlike the old app-side two-write sequence).
  ///
  /// Gender is optional — the redesigned onboarding (NIB-120) drops the
  /// selector. Defaults to [Gender.preferNotToSay] when omitted.
  ///
  /// [readinessSigns] persists the onboarding readiness result for the
  /// 5 Sign Readiness guide page (index 0 = pediatrician gate, 1-5 = signs).
  Future<Result<Baby>> createBaby(
    String name,
    DateTime dob, [
    Gender gender = Gender.preferNotToSay,
    List<bool> readinessSigns = const [],
  ]) => _repo.createBaby(name, dob, gender, readinessSigns);

  Future<Baby?> getBaby() => _repo.getBaby();

  Future<Result<Baby>> updateBaby(
    String babyId,
    String name,
    DateTime dob,
    Gender gender,
  ) => _repo.updateBaby(babyId, name, dob, gender);

  /// Always reads from DB — never cached in memory.
  Future<bool> get onboardingCompleted => _repo.isOnboardingCompleted();
}

@Riverpod(keepAlive: true)
// Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
// ignore: deprecated_member_use_from_same_package
BabyProfileService babyProfileService(BabyProfileServiceRef ref) =>
    BabyProfileService(ref.watch(babyProfileRepositoryProvider));

/// Fetches the current baby's id. Returns null if no baby exists yet.
@riverpod
Future<String?> currentBabyId(Ref ref) async {
  final baby = await ref.watch(babyProfileServiceProvider).getBaby();
  return baby?.id;
}

/// Fetches the current baby entity. Returns null if no baby exists yet.
@riverpod
Future<Baby?> currentBaby(Ref ref) =>
    ref.watch(babyProfileServiceProvider).getBaby();
