import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Background wash for [AppHeader] — maps to kit `.topbar--*`.
enum AppHeaderWash { butterGradient, butterSoft, cream }

/// Top header. Mirrors kit `.topbar` + components-header preview:
/// 44px round left/right slots, centered 17/700 title, optional title1 subline
/// and optional trailing stat slot.
///
/// Wash: butterGradient (Home/Meals), butterSoft, cream (Recipes/ShoppingList).
class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    this.wash = AppHeaderWash.butterGradient,
    this.leading,
    this.trailing,
    this.subline,
    this.stat,
    super.key,
  });

  final String title;
  final AppHeaderWash wash;

  /// 44px round left slot (e.g. back button).
  final Widget? leading;

  /// 44px round right slot (e.g. avatar / action).
  final Widget? trailing;

  /// Optional title1-scale headline rendered below the top row.
  final String? subline;

  /// Optional widget rendered opposite the [subline] (e.g. a stat pill).
  final Widget? stat;

  Decoration get _decoration {
    switch (wash) {
      case AppHeaderWash.butterGradient:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.butter, AppColors.butterSoft],
          ),
        );
      case AppHeaderWash.butterSoft:
        return const BoxDecoration(color: AppColors.butterSoft);
      case AppHeaderWash.cream:
        return const BoxDecoration(color: AppColors.cream);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _decoration,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md + 2,
        AppSizes.md - 2,
        AppSizes.md + 2,
        AppSizes.lg - 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: AppSizes.roundButton,
                child: Align(alignment: Alignment.centerLeft, child: leading),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.fgStrong,
                    height: 1,
                  ),
                ),
              ),
              SizedBox(
                width: AppSizes.roundButton,
                child: Align(alignment: Alignment.centerRight, child: trailing),
              ),
            ],
          ),
          if (subline != null) ...[
            const SizedBox(height: AppSizes.md - 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    subline!,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColors.fgStrong,
                    ),
                  ),
                ),
                if (stat != null) ...[
                  const SizedBox(width: AppSizes.sp12),
                  stat!,
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
