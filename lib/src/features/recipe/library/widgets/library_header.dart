import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Recipe Library header (Figma 971:8644 / 971:8760, NIB-53 redesign).
///
/// Sits inside the butter-gradient page background. Composes:
///   * a 17/Bold 'Recipe Library' title row
///   * a search row — neutral-10-filled 48x input with a forest-dark border
///     (placeholder 'Search recipe') + a 47x47 forest-dark filter chip
///     pinned to the right
///
/// The search field is uncontrolled here — callers own the
/// [TextEditingController] and the `onSearchChanged` callback. The filter
/// chip mirrors the Figma `ButtonChips` Primary variant: a green-deep tile
/// with the 'class' bookmark / ribbon glyph. Tapping it fires
/// [onBookmarkTap]; per NIB-53 the host screen wires this to the Starting
/// Guide nav (Read Guide CTA on the banner is the only place that also
/// marks the seen flag).
class LibraryHeader extends StatelessWidget {
  const LibraryHeader({
    required this.searchController,
    required this.searchValue,
    required this.onSearchChanged,
    required this.onBookmarkTap,
    super.key,
  });

  final TextEditingController searchController;
  final String searchValue;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onBookmarkTap;

  // Figma sizes (971:8650 input, 894:6480 button-chips).
  static const double _inputHeight = 48;
  static const double _chipSize = 47;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.sm,
        AppSizes.pagePaddingH,
        AppSizes.sp12,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
              child: Text(
                'Recipe Library',
                style: AppTypography.textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: AppSizes.sp12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SearchInput(
                    controller: searchController,
                    value: searchValue,
                    onChanged: onSearchChanged,
                    height: _inputHeight,
                  ),
                ),
                const SizedBox(width: AppSizes.sp12),
                _FilterChipButton(
                  size: _chipSize,
                  onTap: onBookmarkTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.value,
    required this.onChanged,
    required this.height,
  });

  final TextEditingController controller;
  final String value;
  final ValueChanged<String> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.greenDeep),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sp12),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.greenDeep,
            size: AppSizes.iconMd - 4,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search recipe',
                hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.fgFaint,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (value.isNotEmpty)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              tooltip: 'Clear search',
              constraints: const BoxConstraints(
                minWidth: AppSizes.iconLg,
                minHeight: AppSizes.iconLg,
              ),
              icon: const Icon(
                Icons.clear,
                color: AppColors.greenDeep,
                size: AppSizes.iconSm + 2,
              ),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open Starting Guide',
      child: Material(
        color: AppColors.greenDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: const Icon(
              Icons.bookmark_outline,
              color: AppColors.onGreen,
              size: AppSizes.iconMd,
            ),
          ),
        ),
      ),
    );
  }
}
