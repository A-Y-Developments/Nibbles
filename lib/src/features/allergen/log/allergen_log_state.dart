import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';

part 'allergen_log_state.freezed.dart';

@freezed
class AllergenLogState with _$AllergenLogState {
  const factory AllergenLogState({
    EmojiTaste? taste,
    @Default(false) bool hadReaction,
    @Default([]) List<String> symptoms,
    ReactionSeverity? severity,
    String? notes,
    String? photoPath,
    @Default(false) bool isLoading,
    @Default(false) bool isSaved,
    @Default(false) bool photoUploadFailed,
    String? errorMessage,
  }) = _AllergenLogState;
}
