import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_log_controller.g.dart';

@Riverpod(keepAlive: true)
class AllergenLogController extends _$AllergenLogController {
  final _picker = ImagePicker();

  @override
  AllergenLogState build() => const AllergenLogState();

  void setTaste(EmojiTaste taste) =>
      state = state.copyWith(taste: taste, errorMessage: null);

  void toggleReaction() {
    final toggled = !state.hadReaction;
    state = state.copyWith(
      hadReaction: toggled,
      // Clear reaction fields when toggling off.
      symptoms: toggled ? state.symptoms : const [],
      severity: toggled ? state.severity : null,
      notes: toggled ? state.notes : null,
      errorMessage: null,
    );
  }

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

  Future<void> pickPhoto(ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (xFile == null) return;
    state = state.copyWith(photoPath: xFile.path);
  }

  void removePhoto() => state = state.copyWith(photoPath: null);

  void reset() => state = const AllergenLogState();

  /// Saves the log with optional reaction detail and photo.
  ///
  /// For no-reaction logs: auto-advances to the next allergen once 3 clean
  /// logs exist (safe status).
  ///
  /// Error level: P1 — "Couldn't save your log. Please try again."
  Future<void> saveLog(String babyId, String allergenKey) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final service = ref.read(allergenServiceProvider);

    ReactionDetail? reactionDetail;
    if (state.hadReaction && state.severity != null) {
      reactionDetail = ReactionDetail(
        id: '',
        logId: '',
        severity: state.severity!,
        symptoms: state.symptoms,
        notes: state.notes,
        createdAt: DateTime.now(),
      );
    }

    final result = await service.saveAllergenLog(
      babyId: babyId,
      allergenKey: allergenKey,
      emojiTaste: state.taste!,
      hadReaction: state.hadReaction,
      reactionDetail: reactionDetail,
      photo: state.photoPath != null ? File(state.photoPath!) : null,
    );

    if (result.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't save your log. Please try again.",
      );
      return;
    }

    // Check if photo upload failed (log saved but without photo).
    final savedLog = result.dataOrNull!;
    final photoFailed = state.photoPath != null && savedLog.photoUrl == null;

    // Auto-advance when the allergen reaches safe status (3+ clean logs).
    if (!state.hadReaction) {
      final logsResult = await service.getLogs(
        babyId,
        allergenKey: allergenKey,
      );
      if (logsResult.isSuccess) {
        final status = service.deriveStatus(logsResult.dataOrNull!);
        if (status == AllergenStatus.safe) {
          await service.advanceToNextAllergen(babyId);
        }
      }
    }

    state = state.copyWith(
      isLoading: false,
      isSaved: true,
      photoUploadFailed: photoFailed,
    );
    unawaited(
      Analytics.instance.logAllergenLogCreated(allergenKey: allergenKey),
    );
  }
}
