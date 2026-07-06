import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/brand_flower.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Shows the DS destructive-confirm bottom-sheet (Figma 971:8143).
///
/// Centered brand flower + a confirmation prompt + a No / Yes pair (Yes is the
/// destructive action). Reused for whole-plan delete and per-day clear — pass
/// [title] to swap the copy. Returns `true` on Yes, `false` on No, `null` on
/// scrim dismiss.
Future<bool?> showClearMealPlanConfirm(
  BuildContext context, {
  String title = 'Are you sure you want to delete?',
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => _ClearConfirmSheet(title: title),
  );
}

class _ClearConfirmSheet extends StatelessWidget {
  const _ClearConfirmSheet({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandFlower(size: AppSizes.avatarLg),
            const SizedBox(height: AppSizes.lg),
            Text(
              title,
              style:
                  Theme.of(context).textTheme.titleMedium ??
                  AppTypography.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: AppPillButton(
                    label: 'No',
                    variant: AppPillButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: AppPillButton(
                    label: 'Yes',
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
