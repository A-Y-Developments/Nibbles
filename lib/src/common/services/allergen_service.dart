import 'package:nibbles/src/common/data/repositories/allergen_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_service.g.dart';

class AllergenService {
  const AllergenService(this._repo);

  final AllergenRepository _repo;

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

    final items = allergens
        .map(
          (allergen) {
            final logs = allLogs
                .where((l) => l.allergenKey == allergen.key)
                .toList();
            return AllergenBoardItem(
              allergen: allergen,
              logs: logs,
              status: deriveStatus(logs),
            );
          },
        )
        .toList();

    return Result.success(items);
  }

  /// Saves a daily allergen log.
  ///
  /// Returns [DuplicateLogException] if a log already exists for the same
  /// allergen on the same calendar day — never inserts a duplicate.
  Future<Result<AllergenLog>> saveAllergenLog({
    required String babyId,
    required String allergenKey,
    required EmojiTaste emojiTaste,
    required bool hadReaction,
    ReactionDetail? reactionDetail,
  }) async {
    final today = DateTime.now();

    final duplicateCheck =
        await _repo.hasLogForToday(babyId, allergenKey, today);
    if (duplicateCheck.isFailure) {
      return Result.failure(duplicateCheck.errorOrNull!);
    }

    if (duplicateCheck.dataOrNull!) {
      final name = await _resolveAllergenName(allergenKey);
      return Result.failure(DuplicateLogException(name));
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

  Future<String> _resolveAllergenName(String allergenKey) async {
    final result = await _repo.getAllergens();
    if (result.isFailure) return 'this allergen';
    return result.dataOrNull!
        .firstWhere(
          (a) => a.key == allergenKey,
          orElse: () => const Allergen(
            key: '',
            name: 'this allergen',
            sequenceOrder: 0,
            emoji: '',
          ),
        )
        .name;
  }
}

@Riverpod(keepAlive: true)
AllergenService allergenService(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  AllergenServiceRef ref,
) =>
    AllergenService(ref.watch(allergenRepositoryProvider));
