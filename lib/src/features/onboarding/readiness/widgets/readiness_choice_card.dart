import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';

/// Large square choice card used in the NIB-83 readiness questionnaire.
///
/// Composition matches the Figma frames
/// (.figma-audit/onboarding/readiness-check-{1..6}/screenshot.png):
/// a cream square with forest stroke, centered butter Quatrefoil with a
/// cancel-X overlay glyph, and a centered label below.
///
/// PRIVATE to the readiness feature — composes theme tokens only, NOT a
/// shared DS component. See spec: do not promote to lib/src/common/components.
class ReadinessChoiceCard extends StatelessWidget {
  const ReadinessChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// CTA label.
  final String label;

  /// Whether this card is the active answer. Selected paints the surface in
  /// butter + thicker forest stroke; unselected uses cream surface + muted
  /// stroke. (Figma does not capture selected state, kit-derived treatment.)
  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderColor = selected ? AppColors.greenDeep : AppColors.green;
    final borderWidth = selected ? 2.5 : 1.5;
    final surface = selected ? AppColors.butterSoft : AppColors.cream;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AspectRatio(
        aspectRatio: 1,
        child: Material(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius2xl),
            side: BorderSide(color: borderColor, width: borderWidth),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radius2xl),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sp12,
                vertical: AppSizes.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _NibbleIcon(),
                  const SizedBox(height: AppSizes.sm),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.greenDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Butter Quatrefoil with a small cancel-X overlay, per the Figma frames.
class _NibbleIcon extends StatelessWidget {
  const _NibbleIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: AppSizes.xxl,
      height: AppSizes.xxl,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Quatrefoil(
            size: AppSizes.xxl,
            coreColor: AppColors.butter,
          ),
          Icon(
            Icons.cancel_outlined,
            size: AppSizes.iconMd,
            color: AppColors.greenDeep,
          ),
        ],
      ),
    );
  }
}
