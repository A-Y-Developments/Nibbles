import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Opens the "Add Ingredients" bottom sheet (backlog #9). White surface,
/// top corners rounded 30px, lifts above the keyboard via
/// `isScrollControlled` + viewInsets padding. Hosts [AddIngredientCard]
/// (Ingredients field + lime Add pill). The caller owns [controller] /
/// [focusNode] and the addManual write via [onAdd]; this sheet is purely
/// presentational.
///
/// Presented on the root navigator so the sheet + scrim sit OVER the bottom
/// navigation bar (matching the Clear All confirm sheet) rather than inside
/// the shell body.
Future<void> showAddIngredientSheet(
  BuildContext context, {
  required TextEditingController controller,
  required FocusNode focusNode,
  required VoidCallback onAdd,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    isScrollControlled: true,
    builder: (_) => _AddIngredientSheet(
      controller: controller,
      focusNode: focusNode,
      onAdd: onAdd,
    ),
  );
}

class _AddIngredientSheet extends StatelessWidget {
  const _AddIngredientSheet({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radius3xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.sm),
              // Grab handle.
              Container(
                width: AppSizes.sp40,
                height: AppSizes.xs,
                decoration: BoxDecoration(
                  color: AppColors.borderSoft,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Add Ingredients',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.fgStrong,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              AddIngredientCard(
                controller: controller,
                focusNode: focusNode,
                onAdd: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add Ingredients content — Figma 971:9883 / 971:9884.
///
/// Bare borderless text field with "Ingredients" placeholder
/// (Figtree Regular 15, color neutral-50 / fgFaint) + lime pill "Add"
/// button (77x30, rounded-[24px], bg butter, label Parkinsans SemiBold 15
/// in greenDeep) to the right of the field. Rendered inside the Add
/// Ingredients bottom sheet — no card chrome of its own.
class AddIngredientCard extends StatelessWidget {
  const AddIngredientCard({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Sheet supplies the surface/rounded-top; this is just inner padding.
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              onSubmitted: (_) => onAdd(),
              textInputAction: TextInputAction.done,
              // Figma body/regular — Figtree 15/22 (matches textTheme.bodyLarge).
              style: AppTypography.textTheme.bodyLarge,
              cursorColor: AppColors.greenDeep,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Ingredients',
                hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.fgFaint,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          _AddPillButton(onTap: onAdd),
        ],
      ),
    );
  }
}

/// Lime "Add" pill — Figma 1465:49397. 77x30 rounded-[24px] bg butter
/// (#eaec8c), label "Add" Parkinsans SemiBold 15 in greenDeep (#3d5236).
class _AddPillButton extends StatelessWidget {
  const _AddPillButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 77,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.butter,
            borderRadius: BorderRadius.circular(AppSizes.radius2xl),
          ),
          child: Text(
            'Add',
            style: AppTypography.headline.copyWith(color: AppColors.greenDeep),
          ),
        ),
      ),
    );
  }
}
