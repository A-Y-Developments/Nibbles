import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    required Baby baby,
    required List<AllergenBoardItem> safeAllergens,
    required String subscriptionLabel,
  }) = _ProfileState;
}
