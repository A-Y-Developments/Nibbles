import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Ghost "+ Add Date" pill rendered below the day list. Grows the visible
/// window by one day (Figma 971:7826).
class AddDatePill extends StatelessWidget {
  const AddDatePill({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.sm,
      ),
      child: AppPillButton(
        label: '+ Add Date',
        variant: AppPillButtonVariant.secondary,
        size: AppPillButtonSize.small,
        onPressed: onPressed,
      ),
    );
  }
}
