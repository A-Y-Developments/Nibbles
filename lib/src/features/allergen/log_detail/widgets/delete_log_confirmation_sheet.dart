import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/brand_flower.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Delete-log confirmation bottom sheet (Figma 1525:31338).
///
/// White sheet, top corners rounded 30px, 50% black scrim. Centered question
/// "Are you sure you want to delete?" (Parkinsans Bold 17), quatrefoil
/// illustration, then a Cancel (text) + Delete (filled forest) row. Resolves
/// to `true` when Delete is tapped, `false`/`null` otherwise.
///
/// Presented on the root navigator so the sheet + scrim sit over the log
/// detail screen.
Future<bool?> showDeleteLogConfirmationSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radius3xl),
      ),
    ),
    builder: (_) => const _DeleteLogConfirmationSheet(),
  );
}

class _DeleteLogConfirmationSheet extends StatelessWidget {
  const _DeleteLogConfirmationSheet();

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
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            const Center(child: BrandFlower(size: 153)),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: AppPillButton(
                    key: const Key('delete_log_cancel_button'),
                    label: 'Cancel',
                    variant: AppPillButtonVariant.text,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSizes.sp12),
                Expanded(
                  child: AppPillButton(
                    key: const Key('delete_log_confirm_button'),
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
