import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Shows the DS clear-week confirm bottom-sheet (Figma 971:8090).
///
/// Renders a centered confirmation sheet pinned to the bottom of the screen
/// with the planner visible behind a scrim. Returns `true` if the user tapped
/// Delete, `false` if Cancel, and `null` if dismissed via the scrim.
Future<bool?> showClearMealPlanConfirm(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => const _ClearConfirmSheet(),
  );
}

class _ClearConfirmSheet extends StatelessWidget {
  const _ClearConfirmSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
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
            Text(
              'Are you sure you want to delete?',
              style: Theme.of(context).textTheme.titleMedium ??
                  AppTypography.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            const Quatrefoil(size: AppSizes.avatarLg),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: AppPillButton(
                    label: 'Cancel',
                    variant: AppPillButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: AppPillButton(
                    label: 'Delete',
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
