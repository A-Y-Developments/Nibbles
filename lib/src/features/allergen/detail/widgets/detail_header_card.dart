import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_status_pill.dart';

/// Top hero card on the allergen detail screen.
///
/// Layout: round coral-soft emoji tile + name + subtext + status pill.
/// Subtext: literal 'Completed' when status == safe, else 'X/3 times'
/// (where X is clean log count, capped at 3) per spec 5.
class DetailHeaderCard extends StatelessWidget {
  const DetailHeaderCard({
    required this.emoji,
    required this.name,
    required this.cleanCount,
    required this.status,
    super.key,
  });

  final String emoji;
  final String name;
  final int cleanCount;
  final AllergenStatus status;

  String get _subtext {
    if (status == AllergenStatus.safe) return 'Completed';
    final capped = cleanCount.clamp(0, 3);
    return '$capped/3 times';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.coralSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _subtext,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.fgFaint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          DetailStatusPill(status: status),
        ],
      ),
    );
  }
}
