import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';

part 'allergen_log_state.freezed.dart';

/// State for the full-screen Allergen Log capture / edit flow (NIB-127).
///
/// Shared between CREATE and EDIT modes — EDIT mode hydrates the state from
/// an existing log on first build via [logId] + [hydrated]. The redesigned
/// flow (NIB-124) drops the legacy severity / symptoms capture, so reactions
/// reduce to the [hadReaction] toggle + [notes].
@freezed
class AllergenLogState with _$AllergenLogState {
  const factory AllergenLogState({
    EmojiTaste? taste,
    @Default(false) bool hadReaction,
    String? notes,
    String? attachmentTitle,
    String? attachmentDescription,
    String? photoPath,

    /// Existing storage path of the photo when editing an existing log. Used
    /// to drive best-effort deletion when the user re-takes the photo.
    String? existingPhotoPath,

    /// When set the controller is in EDIT mode; `null` for CREATE mode.
    String? logId,

    /// Whether existing-log hydration has completed (EDIT mode only). Always
    /// `true` for CREATE mode.
    @Default(false) bool hydrated,

    /// Date the food was given. Defaults to "now" at construction time and
    /// is editable via a date picker.
    DateTime? logDate,
    @Default(false) bool isLoading,
    @Default(false) bool isSaved,
    @Default(false) bool photoUploadFailed,
    String? errorMessage,
  }) = _AllergenLogState;
}
