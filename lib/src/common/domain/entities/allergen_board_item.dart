import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

part 'allergen_board_item.freezed.dart';

@freezed
class AllergenBoardItem with _$AllergenBoardItem {
  const factory AllergenBoardItem({
    required Allergen allergen,
    required List<AllergenLog> logs,
    required AllergenStatus status,
  }) = _AllergenBoardItem;
}
