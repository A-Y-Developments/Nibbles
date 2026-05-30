import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_tracker_controller.g.dart';

/// Loads the data backing the redesigned Allergen Tracker board.
///
/// Composes three reads in parallel:
///  - `getAllergenStatuses(babyId)` — the authoritative per-allergen status
///    (NIB-126). Drives the ring, stat columns and per-card badges.
///  - `getAllergens()`              — name + emoji + display order.
///  - `getLogs(babyId)`             — raw logs for the Reaction Log list and
///    the per-card 0/3 progress.
///
/// The legacy `getAllergenBoardSummary` + `getProgramState` +
/// `advanceToNextAllergen` flow is intentionally not used here — the
/// locked sequence is retired (NIB-120).
@riverpod
class AllergenTrackerController extends _$AllergenTrackerController {
  @override
  Future<AllergenTrackerState> build(String babyId) async {
    final service = ref.read(allergenServiceProvider);

    final (
      Result<List<Allergen>> allergensResult,
      Result<Map<String, AllergenStatus>> statusesResult,
      Result<List<AllergenLog>> logsResult,
    ) = await (
      service.getAllergens(),
      service.getAllergenStatuses(babyId),
      service.getLogs(babyId),
    ).wait;

    if (allergensResult.isFailure) throw allergensResult.errorOrNull!;
    if (statusesResult.isFailure) throw statusesResult.errorOrNull!;
    if (logsResult.isFailure) throw logsResult.errorOrNull!;

    final allergens = List<Allergen>.of(allergensResult.dataOrNull!)
      ..sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

    final logs = List<AllergenLog>.of(logsResult.dataOrNull!)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return AllergenTrackerState(
      allergens: allergens,
      statuses: statusesResult.dataOrNull!,
      logs: logs,
    );
  }
}
