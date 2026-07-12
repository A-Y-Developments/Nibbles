import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/feedback/press_scale.dart';

/// Visual variant for [AppPillButton] — maps to kit `.pillbtn--*`.
/// `text` = transparent, no border, forest label (e.g. a Cancel action).
enum AppPillButtonVariant { primary, secondary, ghost, destructive, text }

/// Sizing for [AppPillButton]. Both `full` and `small` are h49 (design-review
/// standardized all buttons to 49); the variants differ only in intent.
enum AppPillButtonSize { full, small }

/// Pill-shaped CTA. Mirrors Figma `Regular-button` (radiusFull). h49, 24
/// horizontal padding, 12 icon-label gap.
class AppPillButton extends StatelessWidget {
  const AppPillButton({
    required this.label,
    required this.onPressed,
    this.variant = AppPillButtonVariant.primary,
    this.size = AppPillButtonSize.full,
    this.expand = true,
    this.leading,
    this.identifier,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppPillButtonVariant variant;
  final AppPillButtonSize size;

  /// Whether the button stretches to its parent's width (kit `.pillbtn--full`).
  final bool expand;

  /// Optional leading widget (e.g. a `+` icon for "Add" buttons).
  final Widget? leading;

  /// Stable semantics identifier for UI automation (maps to
  /// accessibilityIdentifier on iOS).
  final String? identifier;

  bool get _isSmall => size == AppPillButtonSize.small;

  bool get _disabled => onPressed == null;

  Color _background(AppPillButtonVariant v) {
    if (_disabled) return AppColors.borderMuted;
    switch (v) {
      case AppPillButtonVariant.primary:
        return AppColors.greenDeep;
      case AppPillButtonVariant.secondary:
      case AppPillButtonVariant.text:
        return Colors.transparent;
      case AppPillButtonVariant.ghost:
        return AppColors.butter;
      case AppPillButtonVariant.destructive:
        return AppColors.destructive;
    }
  }

  Color _foreground(AppPillButtonVariant v) {
    if (_disabled) return AppColors.cream;
    switch (v) {
      case AppPillButtonVariant.primary:
      case AppPillButtonVariant.destructive:
        return AppColors.cream;
      case AppPillButtonVariant.secondary:
      case AppPillButtonVariant.ghost:
      case AppPillButtonVariant.text:
        return AppColors.greenDeep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = _foreground(variant);
    final height = _isSmall ? AppSizes.buttonHeightSm : AppSizes.buttonHeight;
    // Design-review: all buttons use 24 horizontal padding + 12 icon-label gap.
    const hPad = AppSizes.lg;
    final isSecondary = variant == AppPillButtonVariant.secondary;

    final textStyle = AppTypography.button.copyWith(color: fg);

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          IconTheme.merge(
            data: IconThemeData(color: fg, size: AppSizes.iconMd),
            child: leading!,
          ),
          const SizedBox(width: AppSizes.sp12),
        ],
        Flexible(
          child: AnimatedSwitcher(
            duration: AppDurations.quick,
            switchInCurve: AppCurves.standard,
            switchOutCurve: AppCurves.standard,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              label,
              key: ValueKey(label),
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );

    // NIB-153 — container + button so the pill stays its own accessibility
    // element; without it iOS merges the pill into surrounding row text and
    // identifier-targeted taps resolve to the row center, missing the button.
    // NIB-165 — label + excludeSemantics so the pill is a SINGLE labelled node;
    // without them the container boundary leaves the child Text as a second
    // node, so assistive tech reads the label twice ("Edit | Edit").
    return Semantics(
      identifier: identifier,
      container: true,
      button: true,
      enabled: !_disabled,
      label: label,
      excludeSemantics: true,
      child: PressableScale(
        enabled: !_disabled,
        child: Material(
          color: _background(variant),
          shape: StadiumBorder(
            side: isSecondary && !_disabled
                ? const BorderSide(color: AppColors.greenDeep, width: 1.5)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: SizedBox(
              height: height,
              width: expand ? double.infinity : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
