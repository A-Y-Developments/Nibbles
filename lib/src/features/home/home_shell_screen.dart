import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/home/home_controller.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_controller.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_controller.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_controller.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  const HomeShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  int _previousIndex = 0;

  @override
  void didUpdateWidget(HomeShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex == _previousIndex) return;
    _previousIndex = newIndex;

    final babyId = ref.read(currentBabyIdProvider).valueOrNull;
    if (babyId == null) return;

    switch (newIndex) {
      case 0:
        ref.invalidate(homeControllerProvider(babyId));
      case 1:
        ref.invalidate(mealPlanControllerProvider(babyId));
      case 2:
        ref.invalidate(shoppingListControllerProvider(babyId));
      case 3:
        ref.invalidate(recipeLibraryControllerProvider(babyId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.butter,
          backgroundColor: AppColors.surface,
          surfaceTintColor: AppColors.surface,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.greenDeep : AppColors.fgFaint,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 10,
              height: 1,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.greenDeep : AppColors.fgFaint,
            );
          }),
        ),
        child: NavigationBar(
          height: AppSizes.bottomNavHeight,
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: (index) => widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          ),
          destinations: [
            NavigationDestination(
              icon: _navIcon(Assets.icons.nav.navHome, AppColors.fgFaint),
              selectedIcon: _navIcon(
                Assets.icons.nav.navHome,
                AppColors.greenDeep,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: _navIcon(Assets.icons.nav.navMeal, AppColors.fgFaint),
              selectedIcon: _navIcon(
                Assets.icons.nav.navMeal,
                AppColors.greenDeep,
              ),
              label: 'Meals',
            ),
            NavigationDestination(
              icon: _navIcon(Assets.icons.nav.navGrocery, AppColors.fgFaint),
              selectedIcon: _navIcon(
                Assets.icons.nav.navGrocery,
                AppColors.greenDeep,
              ),
              label: 'Grocery',
            ),
            NavigationDestination(
              icon: _navIcon(Assets.icons.nav.navRecipe, AppColors.fgFaint),
              selectedIcon: _navIcon(
                Assets.icons.nav.navRecipe,
                AppColors.greenDeep,
              ),
              label: 'Recipes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(SvgGenImage icon, Color color) => icon.svg(
    width: 24,
    height: 24,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}
