import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_log_controller.g.dart';

@Riverpod(keepAlive: true)
class AllergenLogController extends _$AllergenLogController {
  @override
  AllergenLogState build() => const AllergenLogState();

  void setTaste(EmojiTaste taste) =>
      state = state.copyWith(taste: taste, errorMessage: null);

  void setReaction({required bool hadReaction}) =>
      state = state.copyWith(hadReaction: hadReaction, errorMessage: null);

  void toggleSymptom(String symptom) {
    final updated = List<String>.from(state.symptoms);
    if (updated.contains(symptom)) {
      updated.remove(symptom);
    } else {
      updated.add(symptom);
    }
    state = state.copyWith(symptoms: updated);
  }

  void setSeverity(ReactionSeverity severity) =>
      state = state.copyWith(severity: severity);

  void setNotes(String notes) =>
      state = state.copyWith(notes: notes.isEmpty ? null : notes);

  void reset() => state = const AllergenLogState();

  /// Saves the log. Pass a reaction detail when hadReaction is true.
  ///
  /// Error level: P1 — "Couldn't save your log. Please try again."
  Future<void> saveLog(
    String babyId,
    String allergenKey, {
    ReactionDetail? reactionDetail,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isDuplicateLog: false,
    );

    final result = await ref.read(allergenServiceProvider).saveAllergenLog(
          babyId: babyId,
          allergenKey: allergenKey,
          emojiTaste: state.taste!,
          hadReaction: state.hadReaction!,
          reactionDetail: reactionDetail,
        );

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false, isSaved: true);
        Analytics.instance.logAllergenLogCreated(allergenKey: allergenKey);
      },
      failure: (e) => state = state.copyWith(
        isLoading: false,
        errorMessage: e is DuplicateLogException
            ? e.message
            : "Couldn't save your log. Please try again.",
        isDuplicateLog: e is DuplicateLogException,
      ),
    );
  }
}
