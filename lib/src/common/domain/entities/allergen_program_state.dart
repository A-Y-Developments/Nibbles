import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';

part 'allergen_program_state.freezed.dart';

@freezed
class AllergenProgramState with _$AllergenProgramState {
  const factory AllergenProgramState({
    required String id,
    required String babyId,
    required String currentAllergenKey,
    required int currentSequenceOrder,
    required AllergenProgramStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AllergenProgramState;
}
