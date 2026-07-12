import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Selectable pill used for radio-style choices (e.g. Yes / No).
/// Mirrors kit components-controls radio pills: h36, radiusFull,
/// selected greenDeep/cream, idle outline greenDeep.
class RadioPill extends StatelessWidget {
  const RadioPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected ? AppColors.cream : AppColors.greenDeep;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: AppCurves.standard,
            decoration: ShapeDecoration(
              color: selected ? AppColors.greenDeep : Colors.transparent,
              shape: StadiumBorder(
                side: selected
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.greenDeep, width: 1.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md - 2,
              vertical: AppSizes.sm,
            ),
            child: AnimatedDefaultTextStyle(
              duration: AppDurations.fast,
              curve: AppCurves.standard,
              style: (theme.textTheme.labelMedium ?? const TextStyle())
                  .copyWith(fontWeight: FontWeight.w700, color: fg, height: 1),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
