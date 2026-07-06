import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_icon_tile.dart';

/// Burgundy hero card for the currently-ongoing allergen (Figma 1089:17373 —
/// "Allergen Exposure"). Icon tile, name, "N/3 times", 3-segment progress and
/// a chevron into the allergen detail. Decorative `allergenBlob` sits behind.
class AllergenExposureCard extends StatelessWidget {
  const AllergenExposureCard({
    required this.allergen,
    required this.cleanLogCount,
    required this.onTap,
    super.key,
  });

  final Allergen allergen;
  final int cleanLogCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppSizes.radiusXl);
    final clamped = cleanLogCount.clamp(0, 3);

    return Semantics(
      identifier: 'allergen_exposure_card_${allergen.key}',
      button: true,
      child: Material(
        color: AppColors.burgundyDark,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -30,
                child: Opacity(
                  opacity: 0.06,
                  child: Assets.images.allergen.allergenBlob.image(
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AllergenIconTile(
                          size: 52,
                          backing: Colors.white10,
                        ),
                        const SizedBox(width: AppSizes.sp12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                allergen.name,
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.cream,
                                ),
                              ),
                              const SizedBox(height: AppSizes.sp2),
                              Text(
                                '$clamped/3 times',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.cream.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: AppSizes.roundButtonSm,
                          height: AppSizes.roundButtonSm,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: AppSizes.iconMd,
                            color: AppColors.cream,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    _HeroSegmentBar(filledCount: clamped),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSegmentBar extends StatelessWidget {
  const _HeroSegmentBar({required this.filledCount});

  final int filledCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(3, (i) {
        final isFilled = i < filledCount;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : AppSizes.xs),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: isFilled
                    ? AppColors.lime
                    : Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
        );
      }),
    );
  }
}
