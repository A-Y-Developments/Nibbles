import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';

/// Single row in the Reaction Log list (Figma 1089:17373).
///
/// Baby glyph · `Log N` headline · Safe/Unsafe chip · notes preview · optional
/// butter "Attachment" chip · chevron into the read-only log detail.
class ReactionLogRow extends StatelessWidget {
  const ReactionLogRow({
    required this.log,
    required this.logIndex,
    required this.onTap,
    super.key,
  });

  /// The underlying log row.
  final AllergenLog log;

  /// 1-based index used in the `Log N` headline.
  final int logIndex;

  /// Row tap target. Routes to the read-only log detail (NIB-127).
  final VoidCallback? onTap;

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
        children: [
          Assets.images.allergen.babyOrange.svg(width: 52, height: 52),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Log $logIndex', style: textTheme.labelLarge),
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
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppChip(
                      label: 'Attachment',
                      tone: AppChipTone.butter,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          const Icon(
            Icons.chevron_right_rounded,
            size: AppSizes.iconMd,
            color: AppColors.fgFaint,
          ),
        ],
      ),
    );
  }
}
