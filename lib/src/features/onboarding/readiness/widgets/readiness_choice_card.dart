import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Large square choice card used in the NIB-83 readiness stepper.
///
/// PRIVATE to the readiness feature — composes theme tokens only, NOT a
/// shared DS component. See spec: do not promote to lib/src/common/components.
class ReadinessChoiceCard extends StatelessWidget {
  const ReadinessChoiceCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: selected ? AppColors.greenDeep : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          side: BorderSide(
            color: selected ? AppColors.greenDeep : AppColors.borderMuted,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizes.sp40,
                  height: AppSizes.sp40,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.butter : AppColors.butterSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.greenDeep,
                    size: AppSizes.iconMd,
                  ),
                ),
                Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(
                    color: selected ? AppColors.cream : AppColors.greenDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
