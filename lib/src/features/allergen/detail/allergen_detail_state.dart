import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

part 'allergen_detail_state.freezed.dart';

@freezed
class AllergenDetailState with _$AllergenDetailState {
  const factory AllergenDetailState({
    required Allergen allergen,
    required List<AllergenLog> logs,
    required AllergenProgramState programState,
    required AllergenStatus status,
    @Default(<String, ReactionDetail>{})
    Map<String, ReactionDetail> reactionDetails,
    @Default(<String, String>{}) Map<String, String> signedPhotoUrls,
  }) = _AllergenDetailState;
}
