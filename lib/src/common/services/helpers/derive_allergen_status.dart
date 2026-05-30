import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

/// Canonical, ordered list of the 9 allergen keys.
///
/// Order matches the display sequence (peanut → egg → … → shellfish).
/// Per NIB-120 the sequence is the displayed ORDER only — advancement is
/// derived from logs, the user picks which allergen to introduce next.
///
/// Sourced from [AllergenEmoji.map] so a single literal owns the
/// canonical set.
final List<String> kAllergenKeys = List<String>.unmodifiable(
  AllergenEmoji.map.keys,
);

/// Derives the [AllergenStatus] for a single allergen from its [logs].
///
/// Rules (NIB-120, locked):
///  - 0 logs                       → [AllergenStatus.notStarted]
///  - ANY log with hadReaction     → [AllergenStatus.flagged]
///    (dominates over every other rule, including 3+ clean logs)
///  - ≥3 logs all with hadReaction=false → [AllergenStatus.safe]
///  - ≥1 clean log AND <3 clean logs → [AllergenStatus.inProgress]
///
/// Pure, side-effect-free, directly unit-testable without a service
/// instance.
AllergenStatus deriveStatusForLogs(Iterable<AllergenLog> logs) {
  final list = logs.toList(growable: false);
  if (list.isEmpty) return AllergenStatus.notStarted;
  if (list.any((l) => l.hadReaction)) return AllergenStatus.flagged;
  if (list.length >= 3) return AllergenStatus.safe;
  return AllergenStatus.inProgress;
}
