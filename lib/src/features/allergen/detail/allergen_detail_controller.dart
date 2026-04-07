import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_detail_controller.g.dart';

@riverpod
class AllergenDetailController extends _$AllergenDetailController {
  @override
  Future<AllergenDetailState> build(String allergenKey) async {
    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) {
      throw StateError('No baby profile found.');
    }
    final babyId = baby.id;
    final service = ref.read(allergenServiceProvider);

    final allergensResult = await service.getAllergens();
    _throwIfFailure(allergensResult);
    final allergenList = allergensResult.dataOrNull!;
    final allergenMatches = allergenList.where(
      (Allergen a) => a.key == allergenKey,
    );
    if (allergenMatches.isEmpty) {
      throw StateError('Allergen "$allergenKey" not found.');
    }
    final allergen = allergenMatches.first;

    final logsResult = await service.getLogs(babyId, allergenKey: allergenKey);
    _throwIfFailure(logsResult);
    final logs = logsResult.dataOrNull!;

    final programStateResult = await service.getProgramState(babyId);
    _throwIfFailure(programStateResult);

    final status = service.deriveStatus(logs);

    final reactionDetails = <String, ReactionDetail>{};
    final flaggedLogs = logs.where((AllergenLog l) => l.hadReaction);
    for (final log in flaggedLogs) {
      final detailResult = await service.getReactionDetail(log.id);
      if (detailResult.isSuccess && detailResult.dataOrNull != null) {
        reactionDetails[log.id] = detailResult.dataOrNull!;
      }
    }

    // Fetch signed URLs for logs that have photos.
    final signedPhotoUrls = <String, String>{};
    final logsWithPhotos = logs.where((l) => l.photoUrl != null);
    for (final log in logsWithPhotos) {
      final urlResult = await service.getSignedPhotoUrl(log.photoUrl!);
      if (urlResult.isSuccess) {
        signedPhotoUrls[log.id] = urlResult.dataOrNull!;
      }
    }

    return AllergenDetailState(
      allergen: allergen,
      logs: logs,
      programState: programStateResult.dataOrNull!,
      status: status,
      reactionDetails: reactionDetails,
      signedPhotoUrls: signedPhotoUrls,
    );
  }

  /// Advances the program to the next allergen.
  ///
  /// Returns the next allergen key if the program is still ongoing,
  /// or `null` if the full program is now complete (navigate to AL-08).
  Future<Result<String?>> advanceToNext() async {
    final current = state.valueOrNull;
    if (current == null) {
      return const Result.failure(UnknownException());
    }

    final babyId = current.programState.babyId;
    final service = ref.read(allergenServiceProvider);

    final advanceResult = await service.advanceToNextAllergen(babyId);
    if (advanceResult.isFailure) {
      return Result.failure(advanceResult.errorOrNull!);
    }

    final newStateResult = await service.getProgramState(babyId);
    if (newStateResult.isFailure) {
      return Result.failure(newStateResult.errorOrNull!);
    }

    ref.invalidateSelf();

    final newState = newStateResult.dataOrNull!;
    if (newState.status == AllergenProgramStatus.completed) {
      return const Result.success(null);
    }
    return Result.success(newState.currentAllergenKey);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  void _throwIfFailure<T>(Result<T> result) {
    if (result.isFailure) {
      throw StateError(result.errorOrNull!.message);
    }
  }
}
