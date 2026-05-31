import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Bulk-delete confirmation sheet for the Shopping List
/// (Figma 971:9958 — Clear All confirm).
///
/// White sheet with top corners rounded 30px, scrim 50% black.
/// Title "Are you sure you want to delete?" (Parkinsans Bold 17, centered),
/// 153px quatrefoil illustration, Cancel (outline forest) + Delete (filled
/// forest) bottom row. Resolves to `true` when Delete is tapped, `false` /
/// `null` otherwise.
Future<bool?> showClearAllConfirmSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => const _ClearAllConfirmSheet(),
  );
}

class _ClearAllConfirmSheet extends StatelessWidget {
  const _ClearAllConfirmSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.sp12,
          AppSizes.lg,
          AppSizes.sp12,
          AppSizes.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                width: 212,
                child: Text(
                  'Are you sure you want to delete?',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.titleSmall,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Center(child: Quatrefoil(size: 153)),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: AppPillButton(
                    label: 'Cancel',
                    variant: AppPillButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSizes.sp12),
                Expanded(
                  child: AppPillButton(
                    label: 'Delete',
                    onPressed: () => Navigator.of(context).pop(true),
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
