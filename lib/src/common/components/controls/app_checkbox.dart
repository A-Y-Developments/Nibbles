import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Square checkbox. Mirrors kit components-controls `.cb`: 24px, radius8,
/// greenDeep fill + cream check when on. (NOT the shopping-list `.shop-row__cb`
/// which is 22/radius6 — that is a separate widget.)
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: AppSizes.checkbox,
          height: AppSizes.checkbox,
          decoration: BoxDecoration(
            color: value ? AppColors.greenDeep : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: AppColors.greenDeep, width: 1.5),
          ),
          child: value
              ? const Icon(
                  Icons.check_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.cream,
                )
              : null,
        ),
      ),
    );
  }
}
