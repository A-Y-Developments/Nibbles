import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// One destination in [AppBottomNav].
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.label,
    this.identifier,
  });

  final IconData icon;
  final String label;

  /// Stable semantics identifier for UI automation (maps to
  /// accessibilityIdentifier on iOS).
  final String? identifier;
}

/// Canonical bottom nav — the floating rounded-28 card + shadowCard variant
/// (components-bottom-nav preview), NOT the full-width `.tabbar`.
/// 4 tabs, active = butter pill with greenDeep content, 10/700 labels.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    this.items = defaultItems,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  static const List<AppBottomNavItem> defaultItems = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      label: 'Home',
      identifier: 'nav_tab_home',
    ),
    AppBottomNavItem(
      icon: Icons.restaurant_outlined,
      label: 'Meals',
      identifier: 'nav_tab_meal_plan',
    ),
    AppBottomNavItem(
      icon: Icons.shopping_cart_outlined,
      label: 'Grocery',
      identifier: 'nav_tab_shopping_list',
    ),
    AppBottomNavItem(
      icon: Icons.menu_book_outlined,
      label: 'Recipes',
      identifier: 'nav_tab_recipe_library',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.bottomNavRadius),
        boxShadow: AppSizes.shadowCard,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md + 2,
        vertical: AppSizes.sp12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          return _Tab(
            item: items[i],
            active: i == currentIndex,
            onTap: () => onTap(i),
          );
        }),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.active, required this.onTap});

  final AppBottomNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.greenDeep : AppColors.fgFaint;

    return Semantics(
      identifier: item.identifier,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md - 2,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.butter : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 22, color: fg),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                  height: 1,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
