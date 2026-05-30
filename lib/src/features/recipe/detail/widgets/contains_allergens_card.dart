import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

/// "Contains allergens" section — renders a chip per allergen tag plus a
/// salmon-ghost advisory box telling parents to consult a pediatrician.
///
/// Chip tone uses the canonical status semantics: safe → safe chip,
/// flagged → flag chip; everything else stays neutral. `.completed` is
/// never used — see CLAUDE.md.
class ContainsAllergensCard extends StatelessWidget {
  const ContainsAllergensCard({
    required this.allergenTags,
    required this.statuses,
    super.key,
  });

  final List<String> allergenTags;
  final Map<String, AllergenStatus> statuses;

  String _humanize(String raw) {
    return raw
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  AppChipTone _toneFor(String tag) {
    final status = statuses[tag] ?? AllergenStatus.notStarted;
    return switch (status) {
      AllergenStatus.safe => AppChipTone.safe,
      AllergenStatus.flagged => AppChipTone.flag,
      AllergenStatus.inProgress => AppChipTone.warn,
      AllergenStatus.notStarted => AppChipTone.mute,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: AppSizes.iconSm,
                color: AppColors.coralDeep,
              ),
              const SizedBox(width: AppSizes.xs),
              Text(
                'Contains allergens',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.fgStrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.xs,
            runSpacing: AppSizes.xs,
            children: [
              for (final tag in allergenTags)
                AppChip(
                  label: _humanize(tag),
                  tone: _toneFor(tag),
                  emoji: AllergenEmoji.get(tag),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          _AdvisoryBox(theme: theme),
        ],
      ),
    );
  }
}

class _AdvisoryBox extends StatelessWidget {
  const _AdvisoryBox({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sp12,
        vertical: AppSizes.sp12,
      ),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.menu_book_outlined,
            size: AppSizes.iconMd,
            color: AppColors.coralDeep,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Always consult your pediatrician before introducing '
              'new allergens.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.fgDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
