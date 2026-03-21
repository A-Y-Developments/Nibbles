import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/allergen/complete/allergen_complete_screen.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_screen.dart';
import 'package:nibbles/src/features/allergen/reaction_log/reaction_log_screen.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_screen.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_screen.dart';
import 'package:nibbles/src/features/auth/login/login_screen.dart';
import 'package:nibbles/src/features/auth/register/register_screen.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_screen.dart';
import 'package:nibbles/src/features/home/home_screen.dart';
import 'package:nibbles/src/features/home/home_shell_screen.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_screen.dart';
import 'package:nibbles/src/features/onboarding/baby_setup/onboarding_baby_setup_screen.dart';
import 'package:nibbles/src/features/onboarding/intro/onboarding_intro_screen.dart';
import 'package:nibbles/src/features/onboarding/readiness/onboarding_readiness_screen.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_screen.dart';
import 'package:nibbles/src/features/profile/profile_screen.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_screen.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_screen.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_screen.dart';
import 'package:nibbles/src/features/splash/splash_screen.dart';
import 'package:nibbles/src/features/subscription/paywall/paywall_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authServiceProvider);
  final subscriptionState = ref.watch(subscriptionServiceProvider);
  final localFlags = ref.watch(localFlagServiceProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoute.splash.path,
    redirect: (BuildContext context, GoRouterState state) {
      final hasLaunched = localFlags.hasLaunched();
      final isLoggedIn = authState;
      final hasSubscription = subscriptionState;

      final location = state.matchedLocation;

      // Allow splash through — it handles its own redirect after init.
      if (location == AppRoute.splash.path) return null;

      // 1. First launch → onboarding.
      if (!hasLaunched) return AppRoute.onboardingIntro.path;

      // 2. Not logged in → login.
      if (!isLoggedIn) {
        final authPaths = {
          AppRoute.login.path,
          AppRoute.register.path,
          AppRoute.forgotPassword.path,
          AppRoute.resetPassword.path,
          AppRoute.onboardingIntro.path,
          AppRoute.onboardingReadiness.path,
          AppRoute.onboardingBabySetup.path,
        };
        if (!authPaths.contains(location)) return AppRoute.login.path;
        return null;
      }

      // 3. No subscription → paywall.
      if (!hasSubscription) {
        if (location != AppRoute.paywall.path) return AppRoute.paywall.path;
        return null;
      }

      // 4. Logged-in with subscription trying to access auth/onboarding → home.
      final gatedPaths = {
        AppRoute.login.path,
        AppRoute.register.path,
        AppRoute.forgotPassword.path,
        AppRoute.onboardingIntro.path,
        AppRoute.onboardingReadiness.path,
        AppRoute.onboardingBabySetup.path,
        AppRoute.paywall.path,
      };
      if (gatedPaths.contains(location)) return AppRoute.home.path;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingIntro.path,
        name: AppRoute.onboardingIntro.name,
        builder: (context, state) => const OnboardingIntroScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingReadiness.path,
        name: AppRoute.onboardingReadiness.name,
        builder: (context, state) => const OnboardingReadinessScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingBabySetup.path,
        name: AppRoute.onboardingBabySetup.name,
        builder: (context, state) => const OnboardingBabySetupScreen(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.forgotPassword.path,
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoute.resetPassword.path,
        name: AppRoute.resetPassword.name,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoute.paywall.path,
        name: AppRoute.paywall.name,
        builder: (context, state) => const PaywallScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'allergen/tracker',
                    name: AppRoute.allergenTracker.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AllergenTrackerScreen(),
                    routes: [
                      GoRoute(
                        path: ':allergenKey',
                        name: AppRoute.allergenDetail.name,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => AllergenDetailScreen(
                          allergenKey:
                              state.pathParameters['allergenKey'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'allergen/complete',
                    name: AppRoute.allergenComplete.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AllergenCompleteScreen(),
                  ),
                  GoRoute(
                    path: 'allergen/reaction-log',
                    name: AppRoute.reactionLog.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ReactionLogScreen(),
                  ),
                  GoRoute(
                    path: 'recipes/:recipeId',
                    name: AppRoute.recipeDetail.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => RecipeDetailScreen(
                      recipeId: state.pathParameters['recipeId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: 'profile',
                    name: AppRoute.profile.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ProfileScreen(),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: AppRoute.profileEdit.name,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            const ProfileEditScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorMealKey,
            routes: [
              GoRoute(
                path: AppRoute.mealPlan.path,
                name: AppRoute.mealPlan.name,
                builder: (context, state) => const MealPlanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorShoppingKey,
            routes: [
              GoRoute(
                path: AppRoute.shoppingList.path,
                name: AppRoute.shoppingList.name,
                builder: (context, state) => const ShoppingListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorRecipeKey,
            routes: [
              GoRoute(
                path: AppRoute.recipeLibrary.path,
                name: AppRoute.recipeLibrary.name,
                builder: (context, state) => const RecipeLibraryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
