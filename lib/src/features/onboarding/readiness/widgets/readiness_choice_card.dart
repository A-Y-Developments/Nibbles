import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/petal_blob.dart';

/// Large square choice card used in the NIB-83 readiness questionnaire.
///
/// A cream square with forest stroke, the centered brand Nibble mascot
/// (butter petals + green nibble center, shared with the consent screen),
/// and a centered label below.
///
/// PRIVATE to the readiness feature — composes theme tokens only, NOT a
/// shared DS component. See spec: do not promote to lib/src/common/components.
class ReadinessChoiceCard extends StatelessWidget {
  const ReadinessChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.identifier,
    super.key,
  });

  /// Stable semantics identifier for UI automation.
  final String identifier;

  /// CTA label.
  final String label;

  /// Whether this card is the active answer. Selected paints the surface in
  /// butter + thicker forest stroke; unselected uses cream surface + muted
  /// stroke. (Figma does not capture selected state, kit-derived treatment.)
  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.greenDeep : AppColors.green;
    // Figma readiness-check forest stroke is 2; selected 2.5 is kit-derived.
    final borderWidth = selected ? 2.5 : 2.0;
    final surface = selected ? AppColors.butterSoft : AppColors.cream;

    // NIB-171 — excludeSemantics so the child Text doesn't surface as a second
    // node (the card was read twice, "Yes! | Yes!"); identifier for automation.
    return Semantics(
      identifier: identifier,
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
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
                      // Figma card label = Headline/SemiBold (Parkinsans 15/22).
                      style: AppTypography.headline.copyWith(
                        color: AppColors.greenDeep,
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

/// Brand Nibble mascot — butter petals with a green nibble center, matching
/// the consent screen's [PetalBlob] mark.
class _NibbleIcon extends StatelessWidget {
  const _NibbleIcon();

  @override
  Widget build(BuildContext context) {
    return const PetalBlob(size: AppSizes.xxl);
  }
}
