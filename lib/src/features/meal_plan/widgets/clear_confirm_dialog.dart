import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Shows the DS clear-week confirm dialog (Figma 971:8151).
///
/// Returns `true` if the user tapped Delete, `false` if Cancel, and `null`
/// if dismissed via the barrier. Leaf widget — NIB-69 will swap the legacy
/// Material `AlertDialog` call site in `meal_plan_screen.dart` over to this.
Future<bool?> showClearMealPlanConfirm(BuildContext context) {
  return showDialog<bool>(
    context: context,
    // Spec NIB-103 build-rule 5 requires `barrierDismissible: true` to be
    // passed explicitly even though it matches the default.
    // ignore: avoid_redundant_argument_values
    barrierDismissible: true,
    builder: (ctx) => const _ClearConfirmDialog(),
  );
}

class _ClearConfirmDialog extends StatelessWidget {
  const _ClearConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cream,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Quatrefoil(size: AppSizes.avatarLg),
            const SizedBox(height: AppSizes.md),
            Text(
              'Are you sure you want to delete?',
              style: Theme.of(context).textTheme.titleMedium ??
                  AppTypography.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: AppPillButton(
                    label: 'Cancel',
                    variant: AppPillButtonVariant.ghost,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: AppPillButton(
                    label: 'Delete',
                    variant: AppPillButtonVariant.destructive,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
