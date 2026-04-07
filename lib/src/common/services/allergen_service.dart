import 'dart:io';

import 'package:nibbles/src/common/data/repositories/allergen_repository.dart';
import 'package:nibbles/src/common/data/repositories/storage_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_service.g.dart';

class AllergenService {
  const AllergenService(this._repo, this._storage);

  final AllergenRepository _repo;
  final StorageRepository _storage;

  static const _photoBucket = 'allergen-photos';

  /// Returns the allergen the baby is currently working through.
  Future<Result<Allergen>> getCurrentAllergen(String babyId) async {
    final stateResult = await _repo.getProgramState(babyId);
    if (stateResult.isFailure) {
      return Result.failure(stateResult.errorOrNull!);
    }

    final allergensResult = await _repo.getAllergens();
    if (allergensResult.isFailure) {
      return Result.failure(allergensResult.errorOrNull!);
    }

    final state = stateResult.dataOrNull!;
    final allergens = allergensResult.dataOrNull!;

    final current = allergens.firstWhere(
      (a) => a.key == state.currentAllergenKey,
      orElse: () => allergens.first,
    );

    return Result.success(current);
  }

  /// Assembles all 9 allergens with their logs and derived [AllergenStatus].
  Future<Result<List<AllergenBoardItem>>> getAllergenBoardSummary(
    String babyId,
  ) async {
    final allergensResult = await _repo.getAllergens();
    if (allergensResult.isFailure) {
      return Result.failure(allergensResult.errorOrNull!);
    }

    final logsResult = await _repo.getLogs(babyId);
    if (logsResult.isFailure) {
      return Result.failure(logsResult.errorOrNull!);
    }

    final allergens = allergensResult.dataOrNull!;
    final allLogs = logsResult.dataOrNull!;

    final items =
        allergens.map((allergen) {
          final logs = allLogs
              .where((l) => l.allergenKey == allergen.key)
              .toList();
          return AllergenBoardItem(
            allergen: allergen,
            logs: logs,
            status: deriveStatus(logs),
          );
        }).toList()..sort(
          (a, b) =>
              a.allergen.sequenceOrder.compareTo(b.allergen.sequenceOrder),
        );

    return Result.success(items);
  }

  /// Saves an allergen log. Multiple logs per day are allowed.
  /// If [photo] is provided, uploads it first; photo upload failure is P2
  /// (log saves without photo, caller should show a toast).
  Future<Result<AllergenLog>> saveAllergenLog({
    required String babyId,
    required String allergenKey,
    required EmojiTaste emojiTaste,
    required bool hadReaction,
    ReactionDetail? reactionDetail,
    File? photo,
  }) async {
    final today = DateTime.now();

    // Upload photo if provided (P2 — failure is non-blocking).
    String? photoPath;
    if (photo != null) {
      final ts = today.millisecondsSinceEpoch;
      final uploadPath = '$babyId/${ts}_$allergenKey.jpg';
      final uploadResult = await _storage.uploadFile(
        _photoBucket,
        uploadPath,
        photo,
      );
      if (uploadResult.isSuccess) {
        photoPath = uploadPath;
      }
      // On failure: photoPath stays null, log saves without photo.
    }

    final logResult = await _repo.saveLog(
      AllergenLog(
        id: '',
        babyId: babyId,
        allergenKey: allergenKey,
        emojiTaste: emojiTaste,
        hadReaction: hadReaction,
        logDate: today,
        createdAt: today,
        photoUrl: photoPath,
      ),
    );
    if (logResult.isFailure) return Result.failure(logResult.errorOrNull!);

    final savedLog = logResult.dataOrNull!;

    if (hadReaction && reactionDetail != null) {
      final detailResult = await _repo.saveReactionDetail(
        reactionDetail.copyWith(id: '', logId: savedLog.id),
      );
      if (detailResult.isFailure) {
        return Result.failure(detailResult.errorOrNull!);
      }
    }

    return Result.success(savedLog);
  }

  /// Returns a signed URL for a photo stored in the allergen-photos bucket.
  Future<Result<String>> getSignedPhotoUrl(String photoPath) =>
      _storage.getSignedUrl(_photoBucket, photoPath);

  /// Advances the program to the next allergen in sequence.
  /// Completes the program automatically if the current allergen is last.
  Future<Result<void>> advanceToNextAllergen(String babyId) async {
    final stateResult = await _repo.getProgramState(babyId);
    if (stateResult.isFailure) {
      return Result.failure(stateResult.errorOrNull!);
    }

    final allergensResult = await _repo.getAllergens();
    if (allergensResult.isFailure) {
      return Result.failure(allergensResult.errorOrNull!);
    }

    final state = stateResult.dataOrNull!;
    final sorted = List<Allergen>.from(allergensResult.dataOrNull!)
      ..sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

    final nextIndex = sorted.indexWhere(
      (a) => a.sequenceOrder > state.currentSequenceOrder,
    );

    if (nextIndex == -1) {
      return _repo.completeProgramState(babyId);
    }

    final next = sorted[nextIndex];
    return _repo.advanceProgramState(babyId, next.key, next.sequenceOrder);
  }

  /// Returns the allergen program state for [babyId].
  Future<Result<AllergenProgramState>> getProgramState(String babyId) =>
      _repo.getProgramState(babyId);

  /// Returns the reaction detail for a given [logId], or null if none exists.
  Future<Result<ReactionDetail?>> getReactionDetail(String logId) =>
      _repo.getReactionDetail(logId);

  /// Marks the allergen program as completed.
  Future<Result<void>> completeProgram(String babyId) =>
      _repo.completeProgramState(babyId);

  /// Derives [AllergenStatus] from a list of logs for a single allergen.
  ///
  /// - 0 logs          → [AllergenStatus.notStarted]
  /// - any hadReaction  → [AllergenStatus.flagged]
  /// - 3+ no reaction   → [AllergenStatus.safe]  (NEVER `completed`)
  /// - 1–2 no reaction  → [AllergenStatus.inProgress]
  AllergenStatus deriveStatus(List<AllergenLog> logs) {
    if (logs.isEmpty) return AllergenStatus.notStarted;
    if (logs.any((l) => l.hadReaction)) return AllergenStatus.flagged;
    if (logs.length >= 3) return AllergenStatus.safe;
    return AllergenStatus.inProgress;
  }

  /// Returns all 9 allergens ordered by sequence_order.
  Future<Result<List<Allergen>>> getAllergens({bool refresh = false}) =>
      _repo.getAllergens(refresh: refresh);

  /// Returns all logs for a baby, optionally filtered by allergen key.
  Future<Result<List<AllergenLog>>> getLogs(
    String babyId, {
    String? allergenKey,
  }) => _repo.getLogs(babyId, allergenKey: allergenKey);
}

@Riverpod(keepAlive: true)
AllergenService allergenService(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  AllergenServiceRef ref,
) => AllergenService(
  ref.watch(allergenRepositoryProvider),
  ref.watch(storageRepositoryProvider),
);
