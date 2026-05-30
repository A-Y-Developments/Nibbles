import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';

part 'allergen_log_detail_state.freezed.dart';

/// State for the read-only Allergen Log Detail screen (NIB-127).
@freezed
class AllergenLogDetailState with _$AllergenLogDetailState {
  const factory AllergenLogDetailState({
    required Allergen allergen,
    required AllergenLog log,
    required String babyId,
    required int logNumber,
  }) = _AllergenLogDetailState;
}
