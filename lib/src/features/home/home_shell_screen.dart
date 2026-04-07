import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Meal Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Shopping',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Recipes',
          ),
        ],
      ),
    );
  }
}
