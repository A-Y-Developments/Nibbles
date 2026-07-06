import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';

/// Reaction-Log row card.
///
/// Per spec 9 — salmon baby icon, 'Log N', Safe/Unsafe pill (from
/// `hadReaction`), notes preview, optional attachment chip (from
/// `attachmentTitle`), chevron.
///
/// Rows route to the read-only log detail via [onTap] (NIB-127).
class LogEntryCard extends StatelessWidget {
  const LogEntryCard({
    required this.log,
    required this.logNumber,
    this.onTap,
    super.key,
  });

  final AllergenLog log;
  final int logNumber;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hadReaction = log.hadReaction;
    final notes = log.notes;
    final hasAttachment =
        (log.photoUrl != null && log.photoUrl!.isNotEmpty) ||
        (log.attachmentTitle != null && log.attachmentTitle!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Assets.images.allergen.babyOrange.svg(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
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
                          'Log $logNumber',
                          style: textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      AppChip(
                        label: hadReaction ? 'Unsafe' : 'Safe',
                        tone: hadReaction ? AppChipTone.flag : AppChipTone.safe,
                      ),
                    ],
                  ),
                  if (notes != null && notes.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      notes,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.fgMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (hasAttachment) ...[
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
      ),
    );
  }
}
