import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/allergen/complete/allergen_complete_screen.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_screen.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_screen.dart';
import 'package:nibbles/src/features/allergen/log_detail/allergen_log_detail_screen.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_screen.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_screen.dart';
import 'package:nibbles/src/features/auth/login/login_screen.dart';
import 'package:nibbles/src/features/auth/register/register_screen.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_screen.dart';
import 'package:nibbles/src/features/home/home_screen.dart';
import 'package:nibbles/src/features/home/home_shell_screen.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_screen.dart';
import 'package:nibbles/src/features/onboarding/baby_setup/onboarding_baby_setup_screen.dart';
import 'package:nibbles/src/features/onboarding/consent/onboarding_consent_screen.dart';
import 'package:nibbles/src/features/onboarding/dob/onboarding_dob_screen.dart';
import 'package:nibbles/src/features/onboarding/intro/onboarding_intro_screen.dart';
import 'package:nibbles/src/features/onboarding/name/onboarding_name_screen.dart';
import 'package:nibbles/src/features/onboarding/readiness/onboarding_readiness_screen.dart';
import 'package:nibbles/src/features/onboarding/result/onboarding_result_screen.dart';
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

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<bool>(authServiceProvider, (_, __) => notifyListeners());
  }
}

/// Pure redirect resolver. Extracted so the redirect matrix is testable without
/// spinning up a router/container. Returns the target path or null to allow
/// the current location.
///
/// New flow (NIB-51): name -> DOB -> readiness -> result -> consent -> home.
/// Per-phase whitelists are used (not single-landing bounces) because `dob`
/// and `result` are pass-through screens that share their phase's flag-state
/// with the phase's landing screen — a single-landing bounce would loop.
String? resolveAppRedirect({
  required String location,
  required bool hasLaunched,
  required bool isLoggedIn,
  required bool babySetupDone,
  required bool readinessDone,
  required bool onboardingDone,
}) {
  // Allow splash through — it handles its own redirect after init.
  if (location == AppRoute.splash.path) return null;

  // 1. First launch → onboarding intro (no login required).
  if (!hasLaunched) {
    if (location == AppRoute.onboardingIntro.path) return null;
    return AppRoute.onboardingIntro.path;
  }

  // 2. Not logged in → login. Only allow auth screens + intro through.
  if (!isLoggedIn) {
    const preAuthPaths = {
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/onboarding/intro',
    };
    if (preAuthPaths.contains(location)) return null;
    return AppRoute.login.path;
  }

  // 3. Just signed in from an auth screen — go through splash to seed local
  //    flags from Supabase before checking onboarding state. This is the
  //    seam that keeps a reinstalled-but-already-onboarded user from being
  //    bounced into /onboarding/consent.
  const justSignedInPaths = {'/auth/login', '/auth/register'};
  if (justSignedInPaths.contains(location)) return AppRoute.splash.path;

  // 4. Phase A — name + DOB not captured yet. Both screens share the same
  //    flag (`baby_setup_done` only flips after DOB). Whitelist both so
  //    name -> dob forward nav does not bounce.
  if (!babySetupDone) {
    const phaseA = {'/onboarding/name', '/onboarding/dob'};
    if (phaseA.contains(location)) return null;
    return AppRoute.onboardingName.path;
  }

  // 5. Phase B — readiness 5-step.
  if (!readinessDone) {
    if (location == AppRoute.onboardingReadiness.path) return null;
    return AppRoute.onboardingReadiness.path;
  }

  // 6. Phase C — result + consent. Both share `onboarding_done` (flag flips
  //    only after createBaby succeeds at consent submit). Whitelist both so
  //    result -> consent forward nav does not bounce; landing is consent so
  //    kill-and-resume lands on the actionable screen, not the pass-through.
  if (!onboardingDone) {
    const phaseC = {'/onboarding/result', '/onboarding/consent'};
    if (phaseC.contains(location)) return null;
    return AppRoute.onboardingConsent.path;
  }

  // 7. All onboarding done — any onboarding/auth/paywall screen redirects to
  //    home. Paywall remains gated here while M2 is deferred.
  const gatedPaths = {
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/onboarding/intro',
    '/onboarding/name',
    '/onboarding/dob',
    '/onboarding/readiness',
    '/onboarding/result',
    '/onboarding/consent',
    '/onboarding/baby-setup',
    '/subscription/paywall',
  };
  if (gatedPaths.contains(location)) return AppRoute.home.path;

  return null;
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final notifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoute.splash.path,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final localFlags = ref.read(localFlagServiceProvider);
      return resolveAppRedirect(
        location: state.matchedLocation,
        hasLaunched: localFlags.hasLaunched(),
        isLoggedIn: ref.read(authServiceProvider),
        babySetupDone: localFlags.isOnboardingBabySetupDone(),
        readinessDone: localFlags.isOnboardingReadinessDone(),
        onboardingDone: localFlags.isOnboardingDone(),
      );
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
        path: AppRoute.onboardingName.path,
        name: AppRoute.onboardingName.name,
        builder: (context, state) => const OnboardingNameScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingDob.path,
        name: AppRoute.onboardingDob.name,
        builder: (context, state) => const OnboardingDobScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingReadiness.path,
        name: AppRoute.onboardingReadiness.name,
        builder: (context, state) => const OnboardingReadinessScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingResult.path,
        name: AppRoute.onboardingResult.name,
        builder: (context, state) => const OnboardingResultScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingConsent.path,
        name: AppRoute.onboardingConsent.name,
        builder: (context, state) => const OnboardingConsentScreen(),
      ),
      // Superseded by the new flow but kept registered so auth screens (which
      // still navigate by name to onboardingBabySetup) compile and so the
      // redirect can catch + reroute legacy nav targets to the correct phase.
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
                        routes: [
                          GoRoute(
                            path: 'log',
                            name: AppRoute.allergenLogCreate.name,
                            parentNavigatorKey: rootNavigatorKey,
                            builder: (context, state) => AllergenLogScreen(
                              allergenKey:
                                  state.pathParameters['allergenKey'] ?? '',
                            ),
                            routes: [
                              GoRoute(
                                path: ':logId',
                                name: AppRoute.allergenLogDetail.name,
                                parentNavigatorKey: rootNavigatorKey,
                                builder: (context, state) {
                                  final params = state.pathParameters;
                                  return AllergenLogDetailScreen(
                                    allergenKey: params['allergenKey'] ?? '',
                                    logId: params['logId'] ?? '',
                                  );
                                },
                                routes: [
                                  GoRoute(
                                    path: 'edit',
                                    name: AppRoute.allergenLogEdit.name,
                                    parentNavigatorKey: rootNavigatorKey,
                                    builder: (context, state) {
                                      final params = state.pathParameters;
                                      return AllergenLogScreen(
                                        allergenKey:
                                            params['allergenKey'] ?? '',
                                        logId: params['logId'],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
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
                        builder: (context, state) => const ProfileEditScreen(),
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
