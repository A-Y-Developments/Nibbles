import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Tall two-line "Start New Allergen" CTA.
///
/// A full-width pill with a leading circular "+" chip, a bold title and a
/// smaller subtitle. [onDark] swaps the palette so the button reads on the
/// burgundy ongoing-allergen card (lime fill) instead of the lime hero card
/// (greenDeep fill).
class StartAllergenButton extends StatelessWidget {
  const StartAllergenButton({
    required this.onPressed,
    this.onDark = false,
    super.key,
  });

  final VoidCallback onPressed;
  final bool onDark;

  static const double _height = 64;
  static const double _circle = 40;

  @override
  Widget build(BuildContext context) {
    final fill = onDark ? AppColors.lime : AppColors.greenDeep;
    final title = onDark ? AppColors.greenDeep : AppColors.cream;
    final subtitle = title.withValues(alpha: 0.7);
    final circleFill = onDark ? AppColors.greenDeep : AppColors.lime;
    final circleIcon = onDark ? AppColors.cream : AppColors.greenDeep;
    final radius = BorderRadius.circular(AppSizes.radiusFull);

    return Semantics(
      button: true,
      label: 'Start New Allergen',
      identifier: 'home_start_allergen_button',
      excludeSemantics: true,
      child: Material(
        color: fill,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: _height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                children: [
                  Container(
                    width: _circle,
                    height: _circle,
                    decoration: BoxDecoration(
                      color: circleFill,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add,
                      size: AppSizes.iconMd,
                      color: circleIcon,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sp12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start New Allergen',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: title,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sp2),
                        Text(
                          'Introduce 1 allergen at 1 time',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: subtitle,
                          ),
                        ),
                      ],
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
