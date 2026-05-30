import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
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
              fontFamily: 'Parkinsans',
              fontSize: 10,
              height: 1,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.greenDeep : AppColors.fgFaint,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: (index) => widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Meals',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Grocery',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Recipes',
            ),
          ],
        ),
      ),
    );
  }
}
