import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Single-select button-choice row used in the Delete Account overlay.
///
/// Default: butter-soft fill, transparent border, Parkinsans SemiBold label.
/// Selected: butter fill + green-deep 1.5 border + green-deep label, with a
/// filled green-deep check disc trailing so the picked reason is unmistakable.
class ReasonChoiceRow extends StatelessWidget {
  const ReasonChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = selected ? AppColors.butter : AppColors.butterSoft;
    final fg = selected ? AppColors.greenDeep : AppColors.text;

    // Single-select choice: expose selected + button role so a screen reader
    // announces which reason is picked (mirrors SettingsRow / RadioPill).
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: AppDurations.quick,
          curve: AppCurves.standard,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: selected ? AppColors.greenDeep : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.sp12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.headline.copyWith(color: fg),
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: AppSizes.sm),
                      const _SelectedCheck()
                          .animate()
                          .scale(
                            begin: const Offset(0.6, 0.6),
                            end: const Offset(1, 1),
                            duration: AppDurations.base,
                            curve: AppCurves.emphasized,
                          )
                          .fadeIn(duration: AppDurations.fast),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedCheck extends StatelessWidget {
  const _SelectedCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.greenDeep,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 14, color: AppColors.cream),
    );
  }
}
