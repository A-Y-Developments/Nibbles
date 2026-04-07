enum EmojiTaste { love, neutral, dislike }

extension EmojiTasteX on EmojiTaste {
  String toJson() => switch (this) {
    EmojiTaste.love => 'love',
    EmojiTaste.neutral => 'neutral',
    EmojiTaste.dislike => 'dislike',
  };

  static EmojiTaste fromJson(String value) => switch (value) {
    'love' => EmojiTaste.love,
    'neutral' => EmojiTaste.neutral,
    'dislike' => EmojiTaste.dislike,
    _ => EmojiTaste.neutral,
  };
}
