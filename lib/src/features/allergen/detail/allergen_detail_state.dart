import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';

part 'allergen_detail_state.freezed.dart';

@freezed
class AllergenDetailState with _$AllergenDetailState {
  const factory AllergenDetailState({
    required AllergenBoardItem boardItem,
    required String babyId,
    Allergen? nextAllergen,
  }) = _AllergenDetailState;
}
