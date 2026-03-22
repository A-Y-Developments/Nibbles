import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';

class LogEntryCard extends StatefulWidget {
  const LogEntryCard({
    required this.log,
    required this.dayNumber,
    this.reactionDetail,
    super.key,
  });

  final AllergenLog log;
  final int dayNumber;
  final ReactionDetail? reactionDetail;

  @override
  State<LogEntryCard> createState() => _LogEntryCardState();
}

class _LogEntryCardState extends State<LogEntryCard> {
  bool _expanded = false;

  static const _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime date) {
    final weekday = _weekdays[date.weekday - 1];
    final month = _months[date.month - 1];
    return '$weekday, ${date.day} $month';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasReaction = widget.log.hadReaction;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasReaction
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.cardPadding),
              child: Row(
                children: [
                  // Day badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'D${widget.dayNumber}',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  // Date + taste
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(widget.log.logDate),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tasteLabel(widget.log.emojiTaste),
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.subtext),
                        ),
                      ],
                    ),
                  ),
                  // Reaction dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasReaction
                          ? AppColors.allergenFlagged
                          : AppColors.allergenSafe,
                    ),
                  ),
                  if (hasReaction) ...[
                    const SizedBox(width: AppSizes.xs),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: AppSizes.iconSm,
                      color: AppColors.subtext,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded && widget.reactionDetail != null)
            _ReactionDetailExpanded(detail: widget.reactionDetail!),
        ],
      ),
    );
  }

  String _tasteLabel(EmojiTaste taste) => switch (taste) {
        EmojiTaste.love => 'Love it 😍',
        EmojiTaste.neutral => 'Neutral 😐',
        EmojiTaste.dislike => 'Dislike 😣',
      };
}

class _ReactionDetailExpanded extends StatelessWidget {
  const _ReactionDetailExpanded({required this.detail});
  final ReactionDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.cardPadding,
        0,
        AppSizes.cardPadding,
        AppSizes.cardPadding,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: AppSizes.iconSm,
                color: AppColors.allergenFlagged,
              ),
              const SizedBox(width: AppSizes.xs),
              Text(
                'Reaction — ${_severityLabel(detail.severity)}',
                style: textTheme.labelMedium
                    ?.copyWith(color: AppColors.allergenFlagged),
              ),
            ],
          ),
          if (detail.symptoms.isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Wrap(
              spacing: AppSizes.xs,
              runSpacing: AppSizes.xs,
              children: detail.symptoms
                  .map(
                    (String s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.allergenFlagged.withAlpha(26),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: Text(
                        s,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.allergenFlagged,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (detail.notes != null && detail.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              detail.notes!,
              style: textTheme.bodySmall
                  ?.copyWith(color: AppColors.subtext),
            ),
          ],
        ],
      ),
    );
  }

  String _severityLabel(ReactionSeverity s) => switch (s) {
        ReactionSeverity.mild => 'Mild',
        ReactionSeverity.moderate => 'Moderate',
        ReactionSeverity.severe => 'Severe',
      };
}
