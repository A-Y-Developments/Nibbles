import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';

part 'allergen_log.freezed.dart';

@freezed
class AllergenLog with _$AllergenLog {
  const factory AllergenLog({
    required String id,
    required String babyId,
    required String allergenKey,
    required EmojiTaste emojiTaste,
    required bool hadReaction,
    required DateTime logDate,
    required DateTime createdAt,
    String? photoUrl,
  }) = _AllergenLog;
}
