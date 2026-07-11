import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/meal_recipe_card.dart';

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
    final card = MealRecipeCard(
      recipe: recipe,
      trailing: const Icon(
        Icons.drag_indicator,
        color: AppColors.fgFaint,
        size: AppSizes.iconMd,
      ),
    );
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
          child: MealRecipeCard(
            recipe: recipe,
            elevated: true,
            trailing: const Icon(
              Icons.drag_indicator,
              color: AppColors.fgFaint,
              size: AppSizes.iconMd,
            ),
          ),
        ),
      ),
    );
  }
}
