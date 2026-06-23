import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';

/// Single card holding the Ingredients, Method and Utensils sections, each
/// with a salmon-blob icon header and plain numbered rows (no number
/// background). Figma node 971:9659.
class RecipeStepsCard extends StatelessWidget {
  const RecipeStepsCard({
    required this.ingredients,
    required this.steps,
    required this.utensils,
    super.key,
  });

  final List<Ingredient> ingredients;
  final List<String> steps;
  final List<String> utensils;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ingredients.isNotEmpty) ...[
            _SectionHead(
              icon: Assets.images.recipe.ingredientsIcon,
              title: 'Ingredients',
            ),
            const SizedBox(height: AppSizes.sm),
            for (var i = 0; i < ingredients.length; i++)
              _NumberedRow(
                number: i + 1,
                text: '${ingredients[i].quantity} ${ingredients[i].name}',
              ),
          ],
          if (steps.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            _SectionHead(
              icon: Assets.images.recipe.methodIcon,
              title: 'Method',
            ),
            const SizedBox(height: AppSizes.sm),
            for (var i = 0; i < steps.length; i++)
              _NumberedRow(number: i + 1, text: steps[i]),
          ],
          if (utensils.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            _SectionHead(
              icon: Assets.images.recipe.utensilsIcon,
              title: 'Utensils / appliances',
            ),
            const SizedBox(height: AppSizes.sm),
            for (var i = 0; i < utensils.length; i++)
              _NumberedRow(number: i + 1, text: utensils[i]),
          ],
        ],
      ),
    );
  }
}

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.icon, required this.title});

  final SvgGenImage icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon.svg(width: 37, height: 37),
        const SizedBox(width: AppSizes.sp12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.fgStrong),
        ),
      ],
    );
  }
}

class _NumberedRow extends StatelessWidget {
  const _NumberedRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppColors.fgDefault);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSizes.lg,
            child: Text('$number', style: bodyStyle),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(text, style: bodyStyle)),
        ],
      ),
    );
  }
}
