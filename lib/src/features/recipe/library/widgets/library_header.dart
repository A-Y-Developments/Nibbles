import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Butter-wash header for the Recipe Library screen (Figma 971:8760).
///
/// Composes:
///   * a butter -> butter-soft vertical gradient background
///   * a 'Recipe Library' title row with a trailing green-deep bookmark
///     button (rounded-square, 32x32) that pushes the Starting Guide
///   * a pill-shaped search input with a search-prefix icon and an optional
///     trailing clear button when [searchValue] is non-empty
///
/// The search field is uncontrolled here — callers own the
/// [TextEditingController] and the `onSearchChanged` callback.
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.butter, AppColors.butterSoft],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.sm,
        AppSizes.pagePaddingH,
        AppSizes.md,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recipe Library',
                    style: AppTypography.textTheme.titleLarge,
                  ),
                ),
                _BookmarkButton(onTap: onBookmarkTap),
              ],
            ),
            const SizedBox(height: AppSizes.sp12),
            _SearchPill(
              controller: searchController,
              value: searchValue,
              onChanged: onSearchChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greenDeep,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        onTap: onTap,
        child: const SizedBox(
          width: AppSizes.roundButtonSm,
          height: AppSizes.roundButtonSm,
          child: Icon(
            Icons.bookmark_outline,
            color: AppColors.onGreen,
            size: AppSizes.iconMd,
          ),
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({
    required this.controller,
    required this.value,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.fieldPaddingH),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.greenDeep,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search recipes…',
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
