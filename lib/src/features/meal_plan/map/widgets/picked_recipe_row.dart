import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// A single reusable picked-recipe row for the Map Meals Plan screen (NIB-95).
///
/// Wrapped in a [Draggable] whose payload is the [Recipe] itself — dropping it
/// on the day drop-zone COPIES it onto the selected day. Tapping does the same.
/// The palette never shrinks: dragging/tapping does not remove the row, so a
/// recipe can be mapped onto many days.
class PickedRecipeRow extends StatelessWidget {
  const PickedRecipeRow({required this.recipe, required this.onTap, super.key});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = _RowCard(recipe: recipe);
    return Semantics(
      button: true,
      label: '${recipe.title}. Drag or tap to add to the selected day',
      excludeSemantics: true,
      onTap: onTap,
      child: Draggable<Recipe>(
        data: recipe,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: _DragFeedback(recipe: recipe),
        childWhenDragging: Opacity(opacity: 0.4, child: card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: card,
        ),
      ),
    );
  }
}

/// The lifted card shown under the finger while dragging.
class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-120, -32),
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 240,
          child: _RowCard(recipe: recipe, elevated: true),
        ),
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.recipe, this.elevated = false});

  final Recipe recipe;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          _Thumbnail(url: recipe.thumbnailUrl),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  recipe.title,
                  style: AppTypography.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (recipe.allergenTags.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.xs),
                  _TagsRow(tags: recipe.allergenTags),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          const Icon(
            Icons.drag_indicator,
            color: AppColors.fgFaint,
            size: AppSizes.iconMd,
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        width: AppSizes.iconXl,
        height: AppSizes.iconXl,
        color: AppColors.surfaceVariant,
        child: url == null
            ? const Icon(
                Icons.restaurant,
                color: AppColors.fgFaint,
                size: AppSizes.iconMd,
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.restaurant,
                  color: AppColors.fgFaint,
                  size: AppSizes.iconMd,
                ),
              ),
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.xs,
      runSpacing: AppSizes.xs,
      children: tags
          .take(3)
          .map(
            (t) => AppChip(
              label: AllergenEmoji.displayName(t),
              emoji: AllergenEmoji.get(t),
            ),
          )
          .toList(),
    );
  }
}
