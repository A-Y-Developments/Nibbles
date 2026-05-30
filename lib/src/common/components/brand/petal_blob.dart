import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';

/// Layered brand petal cluster — pale-butter outer quatrefoil, sage inner
/// quatrefoil and a soft butter glow dot at the core. Mirrors the Figma
/// `LoadingAnimation` frame shared across the baby-setup loading screen
/// (NIB-131) and the consent / housekeeping screen (NIB-100).
///
/// Stateless and presentational — callers wrap it in their own layout.
class PetalBlob extends StatelessWidget {
  const PetalBlob({
    this.size = AppSizes.avatarXl * 1.84,
    super.key,
  });

  /// Outer diameter. Inner quatrefoil scales to ~52% (matches the audit
  /// snapshot) and the glow dot scales relative to that.
  final double size;

  @override
  Widget build(BuildContext context) {
    // Ratios are anchored to the original loading-screen geometry — outer
    // 220.8 (avatarXl*1.84), inner 115.2 (avatarXl*0.96), glow 16.8 (sp12*1.4).
    // Computed from the outer so other call sites that pass a custom [size]
    // scale linearly without drifting against the NIB-131 baseline.
    const baseOuter = AppSizes.avatarXl * 1.84;
    const baseInner = AppSizes.avatarXl * 0.96;
    const baseGlow = AppSizes.sp12 * 1.4;
    final innerSize = size * (baseInner / baseOuter);
    final glowSize = size * (baseGlow / baseOuter);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pale-butter petal blob (spec petal layer 1+2 composite).
          Quatrefoil(
            size: size,
            coreColor: AppColors.butter,
          ),
          // Inner sage petal — smaller, scales down to ~52% of outer.
          Quatrefoil(
            size: innerSize,
            petalColor: AppColors.green,
            coreColor: AppColors.greenDeep,
          ),
          // Soft butter glow dot at the center (spec blurred lime dot).
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.butter,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.butter.withValues(alpha: 0.9),
                  blurRadius: AppSizes.sm,
                  spreadRadius: AppSizes.xs,
                ),
              ],
            ),
            child: SizedBox(width: glowSize, height: glowSize),
          ),
        ],
      ),
    );
  }
}
