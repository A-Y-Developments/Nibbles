import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';

/// "Contains allergens" card — a plain sentence naming the recipe's Big 11
/// allergens, followed by a burgundy-ghost advisory box. Figma node
/// 1129:25330. No per-allergen chips in this redesign.
class ContainsAllergensCard extends StatelessWidget {
  const ContainsAllergensCard({required this.allergenTags, super.key});

  final List<String> allergenTags;

  String _sentence() {
    final names = allergenTags
        .map((t) => AllergenEmoji.displayName(t).toLowerCase())
        .toList();
    final String list;
    if (names.length == 1) {
      list = names.first;
    } else if (names.length == 2) {
      list = '${names[0]} and ${names[1]}';
    } else {
      list =
          '${names.sublist(0, names.length - 1).join(', ')}, '
          'and ${names.last}';
    }
    return 'This recipe contains $list, which are included in the '
        'Big 11 allergens.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contains allergens',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            _sentence(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgDefault,
            ),
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
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.burgundyGhost,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          Assets.images.recipe.ingredientsIcon.svg(width: 37, height: 37),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Text(
              'Always consult your pediatrician before introducing '
              'allergens to your baby.',
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
