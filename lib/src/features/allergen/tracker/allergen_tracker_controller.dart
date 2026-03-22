import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_tracker_controller.g.dart';

@riverpod
class AllergenTrackerController extends _$AllergenTrackerController {
  @override
  Future<AllergenTrackerState> build(String babyId) async {
    final service = ref.read(allergenServiceProvider);

    final (
      Result<List<AllergenBoardItem>> boardResult,
      Result<AllergenProgramState> programResult,
    ) = await (
      service.getAllergenBoardSummary(babyId),
      service.getProgramState(babyId),
    ).wait;

    if (boardResult.isFailure) throw boardResult.errorOrNull!;
    if (programResult.isFailure) throw programResult.errorOrNull!;

    final boardItems = boardResult.dataOrNull!;
    final programState = programResult.dataOrNull!;

    // Collect all flagged logs with their allergen, sorted by date desc.
    final flaggedEntries = boardItems
        .expand(
          (AllergenBoardItem b) => b.logs
              .where((AllergenLog l) => l.hadReaction)
              .map((AllergenLog l) => (allergen: b.allergen, log: l)),
        )
        .toList()
      ..sort(
        (
          ({Allergen allergen, AllergenLog log}) a,
          ({Allergen allergen, AllergenLog log}) b,
        ) =>
            b.log.logDate.compareTo(a.log.logDate),
      );

    final recent = flaggedEntries.take(3).toList();
    final recentReactions = <RecentReaction>[];
    for (final entry in recent) {
      final detailResult = await service.getReactionDetail(entry.log.id);
      recentReactions.add(
        RecentReaction(
          allergenName: entry.allergen.name,
          allergenEmoji: entry.allergen.emoji,
          logDate: entry.log.logDate,
          severity: detailResult.dataOrNull?.severity,
        ),
      );
    }

    return AllergenTrackerState(
      boardItems: boardItems,
      programState: programState,
      recentReactions: recentReactions,
    );
  }
}
