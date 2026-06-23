import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Shopping-list row tile. Mirrors kit `.shop-row`:
///
/// * White card, 1px [AppColors.borderSoft] border, radiusMd.
/// * Custom 22px square checkbox (radius 6, [AppColors.greenDeep] border;
///   filled + cream check when [isBought]).
/// * Body label, ellipsised on overflow, strikethrough + faint when [isBought].
/// * Trailing round red x (10% [AppColors.error] tint, [AppColors.deleteGlyph]
///   glyph) — destructive, single-tap.
/// * Bought state swaps card bg to [AppColors.butterSoft] and border to
///   [AppColors.butter].
class ShopRow extends StatelessWidget {
  const ShopRow({
    required this.label,
    required this.isBought,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  /// Item display name.
  final String label;

  /// `true` when the item is in the bought tab — applies bought styling.
  final bool isBought;

  /// Fires when the user taps the checkbox.
  final VoidCallback onToggle;

  /// Fires when the user taps the round red x.
  final VoidCallback onDelete;

  // Kit-spec sizes (.shop-row__cb / .shop-row__del).
  static const double _affordance = 22;
  static const double _cbRadius = 6;
  static const double _checkGlyphSize = 13;
  static const double _delGlyphSize = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppSizes.sp12,
      ),
      decoration: BoxDecoration(
        color: isBought ? AppColors.butterSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isBought ? AppColors.butter : AppColors.borderSoft,
        ),
      ),
      child: Row(
        children: [
          _ShopRowCheckbox(value: isBought, onTap: onToggle),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isBought ? AppColors.fgFaint : AppColors.fgDefault,
                decoration: isBought
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: AppColors.fgFaint,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sp12),
          _ShopRowDelete(onTap: onDelete, glyphSize: _delGlyphSize),
        ],
      ),
    );
  }

  // Inner widgets are private classes — keep them off the public API.
}

class _ShopRowCheckbox extends StatelessWidget {
  const _ShopRowCheckbox({required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: ShopRow._affordance,
          height: ShopRow._affordance,
          decoration: BoxDecoration(
            color: value ? AppColors.greenDeep : AppColors.surface,
            borderRadius: BorderRadius.circular(ShopRow._cbRadius),
            border: Border.all(color: AppColors.greenDeep, width: 1.5),
          ),
          child: value
              ? const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: ShopRow._checkGlyphSize,
                    color: AppColors.cream,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _ShopRowDelete extends StatelessWidget {
  const _ShopRowDelete({required this.onTap, required this.glyphSize});

  final VoidCallback onTap;
  final double glyphSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Delete',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: ShopRow._affordance,
          height: ShopRow._affordance,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Center(
            child: Icon(
              Icons.close_rounded,
              size: glyphSize,
              color: AppColors.deleteGlyph,
            ),
          ),
        ),
      ),
    );
  }
}
