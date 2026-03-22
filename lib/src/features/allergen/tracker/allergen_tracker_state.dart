import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';

part 'allergen_tracker_state.freezed.dart';

@freezed
class AllergenTrackerState with _$AllergenTrackerState {
  const factory AllergenTrackerState({
    required List<AllergenBoardItem> boardItems,
    required AllergenProgramState programState,
    required List<RecentReaction> recentReactions,
  }) = _AllergenTrackerState;
}

@freezed
class RecentReaction with _$RecentReaction {
  const factory RecentReaction({
    required String allergenName,
    required String allergenEmoji,
    required DateTime logDate,
    required ReactionSeverity? severity,
  }) = _RecentReaction;
}
