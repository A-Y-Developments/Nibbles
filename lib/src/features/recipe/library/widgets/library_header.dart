import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/inputs/app_search_field.dart';

/// Recipe Library header (Figma 971:8644 / 971:8760, NIB-53 redesign).
///
/// Sits inside the butter-gradient page background. Composes:
///   * a 17/Bold 'Recipe Library' title row
///   * a search row — neutral-10-filled 40h input with a forest-dark border
///     (placeholder 'Search recipe') + a 40x40 forest-dark filter chip
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

  // Figma sizes (971:8650 input 38 in a 40 row, 894:6480 button-chips 40x40).
  static const double _searchVerticalPadding = 9;
  static const double _chipSize = 40;

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
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sp12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppSearchField(
                    controller: searchController,
                    value: searchValue,
                    onChanged: onSearchChanged,
                    hintText: 'Search recipe',
                    horizontalPadding: AppSizes.sp12,
                    verticalPadding: _searchVerticalPadding,
                    backgroundColor: AppColors.divider,
                    bordered: true,
                  ),
                ),
                const SizedBox(width: AppSizes.sp12),
                _FilterChipButton(size: _chipSize, onTap: onBookmarkTap),
              ],
            ),
          ],
        ),
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
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Assets.icons.recipeGuide.svg(
                width: 16,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.onGreen,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
