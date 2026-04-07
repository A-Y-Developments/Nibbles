import 'package:flutter/widgets.dart';

/// All named routes in the app.
///
/// [path] is a full absolute path.
/// [name] is the unique name used for named navigation.
enum AppRoute {
  splash(path: '/', name: 'splash'),
  onboardingIntro(path: '/onboarding/intro', name: 'onboarding-intro'),
  onboardingReadiness(
    path: '/onboarding/readiness',
    name: 'onboarding-readiness',
  ),
  onboardingBabySetup(
    path: '/onboarding/baby-setup',
    name: 'onboarding-baby-setup',
  ),
  register(path: '/auth/register', name: 'register'),
  login(path: '/auth/login', name: 'login'),
  forgotPassword(path: '/auth/forgot-password', name: 'forgot-password'),
  resetPassword(path: '/auth/reset-password', name: 'reset-password'),
  paywall(path: '/subscription/paywall', name: 'paywall'),
  home(path: '/home', name: 'home'),
  mealPlan(path: '/home/meal', name: 'meal-plan'),
  shoppingList(path: '/home/shopping-list', name: 'shopping-list'),
  recipeLibrary(path: '/home/recipe', name: 'recipe-library'),
  allergenTracker(path: '/home/allergen/tracker', name: 'allergen-tracker'),
  allergenDetail(path: '/home/allergen/:allergenKey', name: 'allergen-detail'),
  allergenComplete(path: '/home/allergen/complete', name: 'allergen-complete'),
  recipeDetail(path: '/home/recipes/:recipeId', name: 'recipe-detail'),
  profile(path: '/home/profile', name: 'profile'),
  profileEdit(path: '/home/profile/edit', name: 'profile-edit');

  const AppRoute({required this.path, required this.name});

  final String path;
  final String name;
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> shellNavigatorMealKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellMeal');
final GlobalKey<NavigatorState> shellNavigatorShoppingKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellShopping');
final GlobalKey<NavigatorState> shellNavigatorRecipeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellRecipe');
