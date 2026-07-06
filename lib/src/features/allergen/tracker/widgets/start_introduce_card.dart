import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_icon_tile.dart';

/// Card for an allergen that hasn't been logged yet (status `notStarted`).
///
/// Visual spec — Figma 1116:18287 / "Not Tried" row:
///  - Grey card bg (borderSoft / #EAEAEA)
///  - Allergen icon in neutral circle
///  - Name + "Not Tried" subhead
///  - Lime pill "Start Introduce" CTA (butter bg, greenDeep text)
///
/// The "Start Introduce" button marks the allergen as actively introduced
/// (status flips to `inProgress`) — no navigation, no log. Disabled via
/// [enabled] while another allergen is already in progress (single-active
/// rule). Tapping the card body opens the allergen detail screen via [onTap].
class StartIntroduceCard extends StatelessWidget {
  const StartIntroduceCard({
    required this.allergen,
    required this.onStartIntroduce,
    this.onTap,
    this.enabled = true,
    super.key,
  });

  final Allergen allergen;
  final VoidCallback onStartIntroduce;
  final VoidCallback? onTap;

  /// When false, the "Start Introduce" CTA is disabled (another allergen is
  /// currently being introduced).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppSizes.radiusXl);

    return Material(
      color: AppColors.borderSoft,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sp12,
          ),
          child: Row(
            children: [
              const AllergenIconTile(size: 52, greyscale: true),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(allergen.name, style: textTheme.titleSmall),
                    const SizedBox(height: AppSizes.sp2),
                    Text(
                      'Not Tried',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.fgMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              AppPillButton(
                label: 'Start Introduce',
                identifier: 'allergen_start_introduce_button_${allergen.key}',
                onPressed: enabled ? onStartIntroduce : null,
                variant: AppPillButtonVariant.ghost,
                size: AppPillButtonSize.small,
                expand: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
