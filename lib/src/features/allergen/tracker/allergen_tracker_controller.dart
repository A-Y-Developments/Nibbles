import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
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

    // Collect ALL logs across allergens, sorted by date desc.
    final allEntries =
        boardItems
            .expand(
              (AllergenBoardItem b) =>
                  b.logs.map((AllergenLog l) => (allergen: b.allergen, log: l)),
            )
            .toList()
          ..sort(
            (
              ({Allergen allergen, AllergenLog log}) a,
              ({Allergen allergen, AllergenLog log}) b,
            ) => b.log.createdAt.compareTo(a.log.createdAt),
          );

    final recent = allEntries.take(5).toList();
    final recentLogs = <RecentLogEntry>[];
    for (final entry in recent) {
      ReactionSeverity? severity;
      if (entry.log.hadReaction) {
        final detailResult = await service.getReactionDetail(entry.log.id);
        severity = detailResult.dataOrNull?.severity;
      }
      recentLogs.add(
        RecentLogEntry(
          allergenKey: entry.allergen.key,
          allergenName: entry.allergen.name,
          allergenEmoji: entry.allergen.emoji,
          logDate: entry.log.logDate,
          createdAt: entry.log.createdAt,
          taste: entry.log.emojiTaste,
          hadReaction: entry.log.hadReaction,
          severity: severity,
        ),
      );
    }

    return AllergenTrackerState(
      boardItems: boardItems,
      programState: programState,
      recentLogs: recentLogs,
    );
  }
}
