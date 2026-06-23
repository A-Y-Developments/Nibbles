import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:nibbles/src/common/data/repositories/allergen_repository.dart';
import 'package:nibbles/src/common/data/repositories/storage_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_service.g.dart';

/// Function injected so unit tests don't touch real Crashlytics. Records a
/// non-fatal diagnostic for a best-effort storage deletion failure.
typedef AllergenCrashRecorderFn =
    Future<void> Function(Object error, StackTrace stack, {String? reason});

class AllergenService {
  AllergenService(
    this._repo,
    this._storage, {
    AllergenCrashRecorderFn? crashRecorder,
  }) : _crashRecorder = crashRecorder ?? _defaultCrashRecorder;

  final AllergenRepository _repo;
  final StorageRepository _storage;
  final AllergenCrashRecorderFn _crashRecorder;

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
  ///
  /// [emojiTaste], [notes], [attachmentTitle], [attachmentDescription] and
  /// [logDate] are part of the redesigned NIB-124 capture model. They are
  /// optional so existing M3 callers stay compatible while the new flow is
  /// being built (NIB-125 / NIB-126). [reactionDetail] is legacy and only
  /// written when supplied by the M3 capture screens.
  Future<Result<AllergenLog>> saveAllergenLog({
    required String babyId,
    required String allergenKey,
    required bool hadReaction,
    EmojiTaste? emojiTaste,
    String? notes,
    String? attachmentTitle,
    String? attachmentDescription,
    DateTime? logDate,
    ReactionDetail? reactionDetail,
    File? photo,
  }) async {
    final now = DateTime.now();
    final effectiveLogDate = logDate ?? now;

    // Upload photo if provided (P2 — failure is non-blocking).
    String? photoPath;
    if (photo != null) {
      final ts = now.millisecondsSinceEpoch;
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
        hadReaction: hadReaction,
        logDate: effectiveLogDate,
        createdAt: now,
        emojiTaste: emojiTaste,
        notes: notes,
        attachmentTitle: attachmentTitle,
        attachmentDescription: attachmentDescription,
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

  /// Updates an existing allergen log. Supports the redesigned Change-Picture
  /// flow: if [newPhotoLocalPath] is supplied, the new photo is uploaded to
  /// the allergen-photos bucket first; on a successful upload the log's
  /// photoUrl is rewritten to the new storage path. An upload failure fails
  /// the whole update (the row is not modified).
  ///
  /// After a successful new upload, [oldPhotoPath] is best-effort deleted
  /// (P3 — failure is logged to Crashlytics and never propagated, so the
  /// row update is not blocked by a stale photo). The final UPDATE on
  /// allergen_logs always runs once we reach it.
  Future<Result<AllergenLog>> updateAllergenLog({
    required AllergenLog log,
    String? newPhotoLocalPath,
    String? oldPhotoPath,
  }) async {
    var effectiveLog = log;

    if (newPhotoLocalPath != null) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final uploadPath = '${log.babyId}/${ts}_${log.allergenKey}.jpg';
      final uploadResult = await _storage.uploadFile(
        _photoBucket,
        uploadPath,
        File(newPhotoLocalPath),
      );
      if (uploadResult.isFailure) {
        return Result.failure(uploadResult.errorOrNull!);
      }
      effectiveLog = log.copyWith(photoUrl: uploadPath);

      if (oldPhotoPath != null && oldPhotoPath.isNotEmpty) {
        await _deletePhotoBestEffort(
          oldPhotoPath,
          reason: 'allergen_update_old_photo',
        );
      }
    }

    return _repo.updateLog(effectiveLog);
  }

  /// Deletes an allergen log and its associated photo (if any).
  /// The storage deletion is best-effort (P3 — logged to Crashlytics on
  /// failure); the row delete always runs.
  Future<Result<void>> deleteAllergenLog({
    required String logId,
    String? photoPath,
  }) async {
    if (photoPath != null && photoPath.isNotEmpty) {
      await _deletePhotoBestEffort(photoPath, reason: 'allergen_delete_photo');
    }
    return _repo.deleteLog(logId);
  }

  /// Best-effort photo delete: never throws, never returns failure. A
  /// failure is recorded to Crashlytics as a non-fatal so the row mutation
  /// can proceed.
  Future<void> _deletePhotoBestEffort(
    String path, {
    required String reason,
  }) async {
    final result = await _storage.deleteFile(_photoBucket, path);
    if (result.isFailure) {
      final error = result.errorOrNull ?? const UnknownException();
      await _crashRecorder(error, StackTrace.current, reason: reason);
    }
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
  ///
  /// Thin wrapper around the pure top-level [deriveStatusForLogs] helper —
  /// kept so existing call sites stay compatible.
  AllergenStatus deriveStatus(List<AllergenLog> logs) =>
      deriveStatusForLogs(logs);

  /// Returns a map of every one of the 9 canonical allergen keys to its
  /// derived [AllergenStatus] for [babyId].
  ///
  /// Per NIB-120 the per-allergen status is derived from `allergen_logs`,
  /// not from `allergen_program_state`. The 9 keys (peanut → … → shellfish)
  /// remain the displayed ORDER; advancement is no longer locked to that
  /// sequence.
  ///
  /// Every key in [kAllergenKeys] is guaranteed to be present in the result
  /// map; allergens with no logs default to [AllergenStatus.notStarted].
  Future<Result<Map<String, AllergenStatus>>> getAllergenStatuses(
    String babyId,
  ) async {
    final logsResult = await _repo.getLogs(babyId);
    if (logsResult.isFailure) {
      return Result.failure(logsResult.errorOrNull!);
    }

    final allLogs = logsResult.dataOrNull!;
    final byKey = <String, List<AllergenLog>>{};
    for (final log in allLogs) {
      (byKey[log.allergenKey] ??= <AllergenLog>[]).add(log);
    }

    final statuses = <String, AllergenStatus>{
      for (final key in kAllergenKeys)
        key: deriveStatusForLogs(byKey[key] ?? const <AllergenLog>[]),
    };

    return Result.success(statuses);
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

Future<void> _defaultCrashRecorder(
  Object error,
  StackTrace stack, {
  String? reason,
}) => FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);

@Riverpod(keepAlive: true)
AllergenService allergenService(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  AllergenServiceRef ref,
) => AllergenService(
  ref.watch(allergenRepositoryProvider),
  ref.watch(storageRepositoryProvider),
);
