import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';

/// Destructive confirm popup mirroring Figma frame 1525:31338.
///
/// Displays a Quatrefoil illustration above the question
/// "Are you sure you want to delete?" with a two-button action row
/// (Cancel + Delete). The Delete button is the primary greenDeep pill — the
/// destructive intent comes from the question copy, not the colour, per the
/// Figma source.
///
/// Returns `true` when the user confirms, `false`/`null` when cancelled or
/// dismissed via barrier tap.
Future<bool?> showDeleteLogConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: (ctx) => const _DeleteLogConfirmationDialog(),
  );
}

class _DeleteLogConfirmationDialog extends StatelessWidget {
  const _DeleteLogConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius2xl),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.lg,
          AppSizes.md,
          AppSizes.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _QuestionText(),
            const SizedBox(height: AppSizes.md),
            const Quatrefoil(size: 153),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: AppPillButton(
                    key: const Key('delete_log_cancel_button'),
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(false),
                    variant: AppPillButtonVariant.secondary,
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

class _QuestionText extends StatelessWidget {
  const _QuestionText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Are you sure you want to delete?',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: FontFamily.parkinsans,
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}
