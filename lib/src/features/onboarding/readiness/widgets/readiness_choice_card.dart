import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Large square choice card used in the NIB-83 readiness questionnaire.
///
/// A cream square with forest stroke, a centered yes/no scallop badge
/// (check for the affirmative card, cross for the unsure card), and a
/// centered label below.
///
/// PRIVATE to the readiness feature — composes theme tokens only, NOT a
/// shared DS component. See spec: do not promote to lib/src/common/components.
class ReadinessChoiceCard extends StatelessWidget {
  const ReadinessChoiceCard({
    required this.label,
    required this.selected,
    required this.affirmative,
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

  /// Whether this is the "yes" card (check badge) vs the "unsure" card (cross).
  final bool affirmative;

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
        child: AnimatedContainer(
          duration: AppDurations.base,
          curve: AppCurves.standard,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSizes.radius2xl),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Material(
            color: Colors.transparent,
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
                    _ChoiceBadge(affirmative: affirmative),
                    const SizedBox(height: AppSizes.sm),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        // Figma card label = Headline/SemiBold (Parkinsans
                        // 15/22).
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
      ),
    );
  }
}

/// Yes/no scallop badge — butter scallop background with a centered Material
/// glyph (check for the affirmative card, cross for the unsure card). Mirrors
/// the result screen's per-sign badge.
class _ChoiceBadge extends StatelessWidget {
  const _ChoiceBadge({required this.affirmative});

  final bool affirmative;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final glyph = affirmative
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Assets.images.onboarding.readinessSignBadge.svg(
            width: _size,
            height: _size,
            colorFilter: const ColorFilter.mode(
              AppColors.butter,
              BlendMode.srcIn,
            ),
          ),
          Icon(glyph, size: AppSizes.iconLg, color: AppColors.greenDeep),
        ],
      ),
    );
  }
}
