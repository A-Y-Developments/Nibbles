import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Visual variant for [AppPillButton] — maps to kit `.pillbtn--*`.
enum AppPillButtonVariant { primary, secondary, ghost, destructive }

/// Sizing for [AppPillButton]. `full` = h52, `small` = h40 (kit.css).
enum AppPillButtonSize { full, small }

/// Pill-shaped CTA. Mirrors kit `.pillbtn` (radiusFull, Parkinsans 700).
///
/// kit.css wins over the preview on pixels: full=52h, small=40h.
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
        return AppColors.greenDeep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = _foreground(variant);
    final height = _isSmall ? AppSizes.buttonHeightSm : AppSizes.buttonHeight;
    final hPad = _isSmall ? AppSizes.md : AppSizes.lg;
    final isSecondary = variant == AppPillButtonVariant.secondary;

    final textStyle = AppTypography.button.copyWith(
      color: fg,
      fontSize: _isSmall ? 14 : 16,
    );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          IconTheme.merge(
            data: IconThemeData(color: fg, size: AppSizes.iconSm),
            child: leading!,
          ),
          const SizedBox(width: AppSizes.xs),
        ],
        Flexible(
          child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    return Semantics(
      identifier: identifier,
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
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
