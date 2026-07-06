import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_log_controller.g.dart';

/// Controller backing the redesigned full-screen Allergen Log capture screen
/// (NIB-127).
///
/// Shared between CREATE (new log) and EDIT (existing log) modes. EDIT mode
/// hydrates state from an existing log via [hydrateForEdit]; submit dispatches
/// to either [AllergenService.saveAllergenLog] or
/// [AllergenService.updateAllergenLog].
@Riverpod(keepAlive: true)
class AllergenLogController extends _$AllergenLogController {
  final _picker = ImagePicker();

  @override
  AllergenLogState build() => const AllergenLogState(hydrated: true);

  void setTaste(EmojiTaste taste) =>
      state = state.copyWith(taste: taste, errorMessage: null);

  void toggleReaction() => state = state.copyWith(
    hadReaction: !state.hadReaction,
    errorMessage: null,
  );

  /// Toggles a symptom preset in/out of the checked set (order preserved).
  void toggleSymptom(String symptom) {
    final next = List<String>.from(state.symptoms);
    if (next.remove(symptom)) {
      state = state.copyWith(symptoms: next, errorMessage: null);
      return;
    }
    state = state.copyWith(symptoms: [...next, symptom], errorMessage: null);
  }

  void setSeverity(ReactionSeverity severity) =>
      state = state.copyWith(severity: severity, errorMessage: null);

  void setNotes(String value) =>
      state = state.copyWith(notes: value.isEmpty ? null : value);

  void setAttachmentTitle(String value) =>
      state = state.copyWith(attachmentTitle: value.isEmpty ? null : value);

  void setAttachmentDescription(String value) => state = state.copyWith(
    attachmentDescription: value.isEmpty ? null : value,
  );

  void setLogDate(DateTime date) => state = state.copyWith(logDate: date);

  Future<void> pickPhoto(ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (xFile == null) return;
    state = state.copyWith(photoPath: xFile.path);
  }

  /// Commits a photo path that was captured outside of the controller (e.g.
  /// by the Attachment bottom-sheet which manages its own local draft state
  /// so Cancel does not bleed into the parent form). Passing `null` clears
  /// the staged photo.
  void setAttachmentPhoto(String? path) =>
      state = state.copyWith(photoPath: path);

  void removePhoto() => state = state.copyWith(photoPath: null);

  /// Resets the controller to its CREATE-mode defaults (logDate = today, all
  /// fields empty).
  void reset() =>
      state = AllergenLogState(hydrated: true, logDate: DateTime.now());

  /// Hydrates the controller from an existing [AllergenLog] for EDIT mode.
  /// Looks up the log via [AllergenService.getLogs] filtered to [logId].
  ///
  /// Idempotent — if the controller is already hydrated for [logId] it
  /// short-circuits so screen rebuilds don't double-fetch.
  Future<void> hydrateForEdit({
    required String babyId,
    required String allergenKey,
    required String logId,
  }) async {
    if (state.hydrated && state.logId == logId) {
      // Re-entering EDIT for the SAME log: clear any stale `isSaved` left by a
      // previous save of this log. The controller is keepAlive, so without
      // this the screen's save-listener trips on the first interaction and
      // bounces the user out — dropping the second edit + returning a phantom
      // saved=true.
      if (state.isSaved) state = state.copyWith(isSaved: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    final service = ref.read(allergenServiceProvider);
    final logsResult = await service.getLogs(babyId, allergenKey: allergenKey);
    if (logsResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't load this log. Please try again.",
      );
      return;
    }

    final log = logsResult.dataOrNull!
        .where((AllergenLog l) => l.id == logId)
        .firstOrNull;
    if (log == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't load this log. Please try again.",
      );
      return;
    }

    state = AllergenLogState(
      logId: log.id,
      hydrated: true,
      taste: log.emojiTaste,
      hadReaction: log.hadReaction,
      notes: log.notes,
      attachmentTitle: log.attachmentTitle,
      attachmentDescription: log.attachmentDescription,
      existingPhotoPath: log.photoUrl,
      logDate: log.logDate,
    );
  }

  /// Hydrates the controller directly from an [AllergenLog] the caller already
  /// holds (EDIT mode entry from the reaction sheet). When the log records a
  /// reaction its `reaction_details` row is fetched to seed `symptoms` +
  /// `severity`. Idempotent for the same log id (clears a stale `isSaved`).
  Future<void> hydrateFromLog(AllergenLog log) async {
    if (state.hydrated && state.logId == log.id) {
      if (state.isSaved) state = state.copyWith(isSaved: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    var symptoms = const <String>[];
    ReactionSeverity? severity;
    if (log.hadReaction) {
      final detailResult = await ref
          .read(allergenServiceProvider)
          .getReactionDetail(log.id);
      final detail = detailResult.dataOrNull;
      if (detail != null) {
        symptoms = detail.symptoms;
        severity = detail.severity;
      }
    }

    state = AllergenLogState(
      logId: log.id,
      hydrated: true,
      taste: log.emojiTaste,
      hadReaction: log.hadReaction,
      symptoms: symptoms,
      severity: severity,
      notes: log.notes,
      attachmentTitle: log.attachmentTitle,
      attachmentDescription: log.attachmentDescription,
      existingPhotoPath: log.photoUrl,
      logDate: log.logDate,
    );
  }

  /// Saves or updates the log, then flips [AllergenLogState.isSaved] when the
  /// screen should pop. CREATE mode also auto-advances the program once the
  /// allergen reaches `safe`.
  ///
  /// Error level: P1 — "Couldn't save your log. Please try again."
  Future<void> submit({
    required String babyId,
    required String allergenKey,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final service = ref.read(allergenServiceProvider);
    final isEdit = state.logId != null;

    if (isEdit) {
      final hydrated = AllergenLog(
        id: state.logId!,
        babyId: babyId,
        allergenKey: allergenKey,
        hadReaction: state.hadReaction,
        logDate: state.logDate ?? DateTime.now(),
        createdAt: DateTime.now(),
        emojiTaste: state.taste,
        notes: state.notes,
        attachmentTitle: state.attachmentTitle,
        attachmentDescription: state.attachmentDescription,
        // Keep existing photoUrl unless the user picked a new file — the
        // service rewrites it on a successful new upload.
        photoUrl: state.existingPhotoPath,
      );

      final result = await service.updateAllergenLog(
        log: hydrated,
        newPhotoLocalPath: state.photoPath,
        oldPhotoPath: state.existingPhotoPath,
        reactionDetail: _buildReactionDetail(),
      );

      if (result.isFailure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Couldn't save your log. Please try again.",
        );
        return;
      }

      state = state.copyWith(isLoading: false, isSaved: true);
      unawaited(
        Analytics.instance.logAllergenLogEdited(
          allergenKey: allergenKey,
          hasAttachment: _hasAttachment(),
        ),
      );
      _logReactionIfAny(allergenKey);
      return;
    }

    // CREATE
    final result = await service.saveAllergenLog(
      babyId: babyId,
      allergenKey: allergenKey,
      emojiTaste: state.taste,
      notes: state.notes,
      attachmentTitle: state.attachmentTitle,
      attachmentDescription: state.attachmentDescription,
      logDate: state.logDate,
      hadReaction: state.hadReaction,
      reactionDetail: _buildReactionDetail(),
      photo: state.photoPath != null ? File(state.photoPath!) : null,
    );

    if (result.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't save your log. Please try again.",
      );
      return;
    }

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
      Analytics.instance.logAllergenLogCreated(
        allergenKey: allergenKey,
        hasAttachment: _hasAttachment(),
      ),
    );
    _logReactionIfAny(allergenKey);
  }

  /// Builds the `reaction_details` payload from the captured symptoms +
  /// severity when a reaction is recorded; null when `hadReaction` is off (so
  /// the service clears any existing row on edit). `id` / `logId` are filled
  /// by the service after the parent log is written.
  ReactionDetail? _buildReactionDetail() {
    if (!state.hadReaction || state.severity == null) return null;
    return ReactionDetail(
      id: '',
      logId: '',
      severity: state.severity!,
      symptoms: state.symptoms,
      createdAt: DateTime.now(),
      notes: state.notes,
    );
  }

  void _logReactionIfAny(String allergenKey) {
    if (!state.hadReaction || state.severity == null) return;
    unawaited(
      Analytics.instance.logReactionLogged(
        allergenKey: allergenKey,
        severity: state.severity!.toJson(),
      ),
    );
  }

  bool _hasAttachment() {
    final title = state.attachmentTitle;
    final description = state.attachmentDescription;
    final photo = state.photoPath;
    final existingPhoto = state.existingPhotoPath;
    return (photo != null && photo.isNotEmpty) ||
        (existingPhoto != null && existingPhoto.isNotEmpty) ||
        (title != null && title.isNotEmpty) ||
        (description != null && description.isNotEmpty);
  }
}
