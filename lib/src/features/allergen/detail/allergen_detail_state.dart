import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

part 'allergen_detail_state.freezed.dart';

@freezed
class AllergenDetailState with _$AllergenDetailState {
  const factory AllergenDetailState({
    required Allergen allergen,
    required List<AllergenLog> logs,
    required AllergenStatus status,
    required String babyId,
    required String babyName,
    // First introduced = min(logDate), Last given = max(logDate).
    // Null when there are 0 logs.
    DateTime? firstIntroduced,
    DateTime? lastGiven,
  }) = _AllergenDetailState;
}
