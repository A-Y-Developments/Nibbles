import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
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

class _HomeShellScreenState extends ConsumerState<HomeShellScreen>
    with SingleTickerProviderStateMixin {
  int _previousIndex = 0;
  late final AnimationController _bodyFade = AnimationController(
    vsync: this,
    duration: AppDurations.fade,
    value: 1,
  );

  @override
  void dispose() {
    _bodyFade.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex == _previousIndex) return;
    _previousIndex = newIndex;
    _bodyFade.forward(from: 0);

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
    // Hide the bottom nav while typing on the Grocery tab so the shopping-list
    // add compose bar docks flush above the keyboard (index 2 = Grocery).
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final onGrocery = widget.navigationShell.currentIndex == 2;
    final hideNav = keyboardOpen && onGrocery;

    return Scaffold(
      body: FadeTransition(
        opacity: _bodyFade.drive(CurveTween(curve: AppCurves.standard)),
        child: widget.navigationShell,
      ),
      bottomNavigationBar: AnimatedSize(
        duration: AppDurations.base,
        curve: AppCurves.standard,
        alignment: Alignment.topCenter,
        child: hideNav ? const SizedBox.shrink() : _bottomNav(),
      ),
    );
  }

  Widget _bottomNav() {
    return NavigationBarTheme(
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
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        destinations: [
          _navDestination(0, Assets.icons.nav.navHome, 'Home'),
          _navDestination(1, Assets.icons.nav.navMeal, 'Meals'),
          _navDestination(2, Assets.icons.nav.navGrocery, 'Grocery'),
          _navDestination(3, Assets.icons.nav.navRecipe, 'Recipes'),
        ],
      ),
    );
  }

  NavigationDestination _navDestination(
    int index,
    SvgGenImage icon,
    String label,
  ) {
    final selected = widget.navigationShell.currentIndex == index;
    return NavigationDestination(
      icon: _AnimatedNavIcon(icon: icon, selected: selected),
      label: label,
    );
  }
}

/// Bottom-nav glyph that eases its tint (faint → green) and scale up when its
/// tab becomes selected, so the switch settles rather than snaps.
class _AnimatedNavIcon extends StatelessWidget {
  const _AnimatedNavIcon({required this.icon, required this.selected});

  final SvgGenImage icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: selected ? 1 : 0),
      duration: AppDurations.base,
      curve: AppCurves.standard,
      builder: (context, t, _) => Transform.scale(
        scale: 1 + 0.08 * t,
        child: icon.svg(
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            Color.lerp(AppColors.fgFaint, AppColors.greenDeep, t)!,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
