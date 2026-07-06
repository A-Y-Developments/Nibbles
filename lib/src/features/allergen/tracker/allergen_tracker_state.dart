import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

part 'allergen_tracker_state.freezed.dart';

/// State for the redesigned Allergen Tracker board (NIB-79).
///
/// Post-NIB-126 the per-allergen status is derived from logs via
/// `AllergenService.getAllergenStatuses`. There is no longer a locked
/// sequence or `currentAllergenKey` — every `notStarted` allergen can be
/// introduced via the Start Introduce CTA.
@freezed
class AllergenTrackerState with _$AllergenTrackerState {
  const factory AllergenTrackerState({
    /// All 9 canonical allergens ordered by `sequenceOrder` (display order).
    required List<Allergen> allergens,

    /// `kAllergenKeys` → derived [AllergenStatus]. Guaranteed to contain
    /// every canonical key.
    required Map<String, AllergenStatus> statuses,

    /// All logs for the baby, sorted oldest → newest by `createdAt`.
    /// Used to render the per-card 0/3 progress and the Reaction Log list.
    required List<AllergenLog> logs,

    /// The actively-introduced ("Start Introduce") allergen key, if any.
    /// Persists as the Ongoing-tab focus even after it flags / goes safe,
    /// until a new introduction replaces it.
    String? selectedAllergenKey,
  }) = _AllergenTrackerState;
}
