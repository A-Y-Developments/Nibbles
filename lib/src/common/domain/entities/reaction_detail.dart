import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';

part 'reaction_detail.freezed.dart';

/// Legacy structured-reaction record from M3 capture (severity + symptoms).
///
/// Deprecated by NIB-124: the redesigned log flow collapses reactions to a
/// single `hadReaction` toggle plus log-level `notes` on `AllergenLog`.
/// Kept so the M3 capture screens (AL-04/AL-05/AL-06) keep compiling until
/// NIB-125 / NIB-126 replace them. Do not use in new code.
@freezed
class ReactionDetail with _$ReactionDetail {
  const factory ReactionDetail({
    required String id,
    required String logId,
    required ReactionSeverity severity,
    required List<String> symptoms,
    required DateTime createdAt,
    String? notes,
  }) = _ReactionDetail;
}
