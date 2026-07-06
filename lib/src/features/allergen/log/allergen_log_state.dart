import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';

part 'allergen_log_state.freezed.dart';

/// State for the Reaction Log capture / edit flow (NIB-127).
///
/// Shared between CREATE and EDIT modes — EDIT mode hydrates the state from
/// an existing log on first build via [logId] + [hydrated]. When
/// [hadReaction] is on the sheet captures structured [symptoms] + [severity]
/// which persist to `reaction_details`; when off they are ignored.
@freezed
class AllergenLogState with _$AllergenLogState {
  const factory AllergenLogState({
    EmojiTaste? taste,
    @Default(false) bool hadReaction,

    /// Checked symptom presets (subset of `SymptomPresets.all`). Only
    /// persisted when [hadReaction] is on; optional (may be empty).
    @Default(<String>[]) List<String> symptoms,

    /// Reaction severity. REQUIRED when [hadReaction] is on (Save is disabled
    /// until it is chosen); null otherwise.
    ReactionSeverity? severity,
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
