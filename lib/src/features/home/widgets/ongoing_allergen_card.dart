import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_segment_bar.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_icon_tile.dart';
import 'package:nibbles/src/features/home/widgets/start_allergen_button.dart';

/// Burgundy "ongoing allergen" card for the Home hero.
///
/// Shows the actively-introduced allergen (icon + name + `X/3 times`), a
/// 3-segment progress bar, and — when [showStartButton] is true (the
/// finished-start-next hero state) — an inset [StartAllergenButton]. The row
/// and its chevron both invoke [onTap] (allergen detail); [onStart] drives
/// the inset button (allergen tracker).
class OngoingAllergenCard extends StatelessWidget {
  const OngoingAllergenCard({
    required this.allergenKey,
    required this.displayName,
    required this.cleanCount,
    required this.onTap,
    this.showStartButton = false,
    this.onStart,
    super.key,
  });

  final String allergenKey;
  final String displayName;
  final int cleanCount;
  final bool showStartButton;
  final VoidCallback onTap;
  final VoidCallback? onStart;

  static const int _target = 3;

  @override
  Widget build(BuildContext context) {
    final clamped = cleanCount.clamp(0, _target);
    final radius = BorderRadius.circular(AppSizes.radiusFull);

    return Material(
      color: AppColors.burgundyDark,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -12,
            bottom: -12,
            child: Opacity(
              opacity: 0.06,
              child: Assets.images.allergen.allergenBlob.image(
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  button: true,
                  label: '$displayName, introduced $clamped of $_target times',
                  identifier: 'home_ongoing_allergen_card',
                  excludeSemantics: true,
                  onTap: onTap,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: radius,
                    child: Row(
                      children: [
                        const AllergenIconTile(backing: Colors.white10),
                        const SizedBox(width: AppSizes.sp12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayName,
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(color: AppColors.cream),
                              ),
                              const SizedBox(height: AppSizes.sp2),
                              Text(
                                '$clamped/$_target times',
                                style: AppTypography.textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.cream.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        const _ChevronButton(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                DetailSegmentBar(introducedCount: clamped, onDark: true),
                if (showStartButton) ...[
                  const SizedBox(height: AppSizes.md),
                  StartAllergenButton(
                    onDark: true,
                    onPressed: onStart ?? onTap,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.roundButtonSm,
      height: AppSizes.roundButtonSm,
      decoration: const BoxDecoration(
        color: Colors.white12,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.chevron_right,
        size: AppSizes.iconMd,
        color: AppColors.cream,
      ),
    );
  }
}
