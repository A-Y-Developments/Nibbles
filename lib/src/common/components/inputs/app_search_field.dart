import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/inputs/app_text_field.dart';

/// Pill search field. A variant of [AppTextField] — mirrors kit `.search`
/// (radiusFull, bgInput fill, leading greenDeep search icon).
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.value,
    this.backgroundColor = AppColors.bgInput,
    this.bordered = false,
    this.horizontalPadding = AppSizes.md,
    this.verticalPadding = AppSizes.sp12 + 1,
    super.key,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  /// Current text value. When non-empty, shows a trailing clear button.
  final String? value;
  final Color backgroundColor;

  /// Draws a static `greenDeep` outline around the pill (Figma forest-dark
  /// border), instead of [AppTextField]'s default focus-only border.
  final bool bordered;

  /// Also used as the search icon's left inset, so the icon and text share
  /// the same edge margin.
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      fillColor: backgroundColor,
      borderColor: bordered ? AppColors.greenDeep : Colors.transparent,
      contentPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: horizontalPadding, right: AppSizes.sm),
        child: const Icon(
          Icons.search,
          size: AppSizes.iconSm + 2,
          color: AppColors.greenDeep,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(),
      suffixIcon: (value != null && value!.isNotEmpty)
          ? IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              tooltip: 'Clear search',
              icon: const Icon(
                Icons.clear,
                color: AppColors.greenDeep,
                size: AppSizes.iconSm + 2,
              ),
              onPressed: () {
                controller?.clear();
                onChanged?.call('');
              },
            )
          : null,
    );
  }
}
