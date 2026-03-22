import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';

part 'allergen_complete_state.freezed.dart';

@freezed
class AllergenCompleteState with _$AllergenCompleteState {
  const factory AllergenCompleteState({
    required String babyName,
    required String babyId,
    required List<Allergen> allergens,
  }) = _AllergenCompleteState;
}
