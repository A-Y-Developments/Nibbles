import 'package:nibbles/src/common/data/repositories/baby_profile_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'baby_profile_service.g.dart';

class BabyProfileService {
  const BabyProfileService(this._repo);

  final BabyProfileRepository _repo;

  /// Creates baby row + allergen_program_state row atomically (sequential).
  /// If allergen_program_state insert fails, returns Failure.
  Future<Result<Baby>> createBaby(
    String name,
    DateTime dob,
    Gender gender,
  ) async {
    final babyResult = await _repo.createBaby(name, dob, gender);
    if (babyResult.isFailure) return babyResult;

    final baby = babyResult.dataOrNull!;
    final programResult = await _repo.createAllergenProgramState(baby.id);
    if (programResult.isFailure) {
      return Result.failure(programResult.errorOrNull!);
    }

    return Result.success(baby);
  }

  Future<Baby?> getBaby() => _repo.getBaby();

  Future<Result<Baby>> updateBaby(
    String babyId,
    String name,
    DateTime dob,
    Gender gender,
  ) =>
      _repo.updateBaby(babyId, name, dob, gender);

  /// Always reads from DB — never cached in memory.
  Future<bool> get onboardingCompleted => _repo.isOnboardingCompleted();
}

@Riverpod(keepAlive: true)
// Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
// ignore: deprecated_member_use_from_same_package
BabyProfileService babyProfileService(BabyProfileServiceRef ref) =>
    BabyProfileService(
      ref.watch(babyProfileRepositoryProvider),
    );
