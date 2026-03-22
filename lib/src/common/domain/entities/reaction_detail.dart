import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';

part 'reaction_detail.freezed.dart';

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
