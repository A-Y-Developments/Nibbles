import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Floating Add Ingredient card. Figma 971:9883 / 971:9884.
///
/// 370x164 white rounded-[30px] card, shadow 0 4px 10px rgba(0,0,0,0.1).
/// Bare borderless text field with "Ingredients" placeholder
/// (Figtree Regular 15, color neutral-50 / fgFaint) + lime pill "Add"
/// button (77x30, rounded-[24px], bg butter, label Parkinsans SemiBold 15
/// in greenDeep) anchored top-right.
///
/// Owner provides the [controller] + [focusNode]. The caller is responsible
/// for opening the keyboard (request focus after mount) and for the
/// addManual write — this widget is purely presentational.
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
    return Container(
      // Figma fixed height — 164 — but we let it size to content so the
      // padding/insets behave on smaller devices.
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius3xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _AddPillButton(onTap: onAdd),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: controller,
            focusNode: focusNode,
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
    return GestureDetector(
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
        child: const Text(
          'Add',
          style: TextStyle(
            fontFamily: FontFamily.parkinsans,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 22 / 15,
            color: AppColors.greenDeep,
          ),
        ),
      ),
    );
  }
}
