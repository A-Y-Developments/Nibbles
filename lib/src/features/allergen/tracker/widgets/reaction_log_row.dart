import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';

/// Single row in the Reaction Log list.
///
/// Layout: baby-avatar circle · `Log N` headline · Safe / Unsafe chip ·
/// notes preview · optional attachment chip. `emojiTaste` is nullable
/// post-NIB-124 — falls back to [EmojiTaste.neutral] for the legacy badge
/// display ONLY (no value is persisted from this widget).
class ReactionLogRow extends StatelessWidget {
  const ReactionLogRow({
    required this.log,
    required this.logIndex,
    required this.babyInitial,
    required this.onTap,
    super.key,
  });

  /// The underlying log row.
  final AllergenLog log;

  /// 1-based index used in the `Log N` headline.
  final int logIndex;

  /// First letter of the baby's name. Used to draw the avatar glyph.
  final String babyInitial;

  /// Row tap target. Routes to the read-only log detail when that screen
  /// exists; for now the tracker screen routes to the allergen detail
  /// (NIB-93 will land the dedicated read-only log view).
  final VoidCallback? onTap;

  String get _tasteGlyph {
    final taste = log.emojiTaste ?? EmojiTaste.neutral;
    switch (taste) {
      case EmojiTaste.love:
        return '😍';
      case EmojiTaste.neutral:
        return '😐';
      case EmojiTaste.dislike:
        return '😣';
    }
  }

  String get _attachmentLabel {
    final title = log.attachmentTitle;
    if (title != null && title.isNotEmpty) return title;
    return 'Photo';
  }

  bool get _hasAttachment =>
      (log.photoUrl != null && log.photoUrl!.isNotEmpty) ||
      (log.attachmentTitle != null && log.attachmentTitle!.isNotEmpty);

  bool get _hasNotes => log.notes != null && log.notes!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusChip = log.hadReaction
        ? const AppChip(label: 'Unsafe', tone: AppChipTone.flag)
        : const AppChip(label: 'Safe', tone: AppChipTone.safe);

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baby avatar with the legacy taste badge as a corner glyph.
          SizedBox(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: AppSizes.avatarMd,
                  height: AppSizes.avatarMd,
                  decoration: const BoxDecoration(
                    color: AppColors.greenTint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    babyInitial,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.greenDeep,
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _tasteGlyph,
                      style: const TextStyle(fontSize: 12, height: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Log $logIndex',
                        style: textTheme.labelLarge,
                      ),
                    ),
                    statusChip,
                  ],
                ),
                if (_hasNotes) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    log.notes!.trim(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.fgMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_hasAttachment) ...[
                  const SizedBox(height: AppSizes.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppChip(
                      label: _attachmentLabel,
                      tone: AppChipTone.mute,
                      emoji: '📎',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
