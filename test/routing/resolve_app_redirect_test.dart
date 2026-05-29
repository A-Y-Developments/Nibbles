import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/routing/route_enums.dart';
import 'package:nibbles/src/routing/routes.dart';

/// Redirect matrix coverage for NIB-51 (pattern: NIB-88 splash matrix).
///
/// Drives the extracted pure [resolveAppRedirect] across every meaningful
/// combination of flags + location so flow ordering, phase whitelists, and
/// reinstall seeding are pinned by tests rather than by transient
/// implementation detail.
void main() {
  // Sugar so each case reads as a state row rather than a constructor.
  String? resolve({
    required String at,
    bool launched = true,
    bool loggedIn = true,
    bool babySetup = false,
    bool readiness = false,
    bool onboarding = false,
  }) => resolveAppRedirect(
    location: at,
    hasLaunched: launched,
    isLoggedIn: loggedIn,
    babySetupDone: babySetup,
    readinessDone: readiness,
    onboardingDone: onboarding,
  );

  group('splash + first launch', () {
    test('splash is always a pass-through', () {
      expect(resolve(at: AppRoute.splash.path), isNull);
      expect(
        resolve(
          at: AppRoute.splash.path,
          launched: false,
          loggedIn: false,
        ),
        isNull,
      );
    });

    test('first launch routes any non-intro path to /onboarding/intro', () {
      expect(
        resolve(at: AppRoute.home.path, launched: false, loggedIn: false),
        AppRoute.onboardingIntro.path,
      );
      expect(
        resolve(at: AppRoute.login.path, launched: false, loggedIn: false),
        AppRoute.onboardingIntro.path,
      );
    });

    test('first launch keeps user on /onboarding/intro', () {
      expect(
        resolve(
          at: AppRoute.onboardingIntro.path,
          launched: false,
          loggedIn: false,
        ),
        isNull,
      );
    });
  });

  group('logged out', () {
    test('non-auth path bounces to /auth/login', () {
      expect(
        resolve(at: AppRoute.home.path, loggedIn: false),
        AppRoute.login.path,
      );
      expect(
        resolve(at: AppRoute.onboardingName.path, loggedIn: false),
        AppRoute.login.path,
      );
    });

    test('auth + intro screens are allowed pre-login', () {
      for (final p in [
        AppRoute.login.path,
        AppRoute.register.path,
        AppRoute.forgotPassword.path,
        AppRoute.resetPassword.path,
        AppRoute.onboardingIntro.path,
      ]) {
        expect(resolve(at: p, loggedIn: false), isNull, reason: p);
      }
    });
  });

  group('just signed in bounce', () {
    test('logged-in user on /auth/login bounces to splash to seed flags', () {
      expect(
        resolve(at: AppRoute.login.path),
        AppRoute.splash.path,
      );
    });

    test('logged-in user on /auth/register bounces to splash', () {
      expect(
        resolve(at: AppRoute.register.path),
        AppRoute.splash.path,
      );
    });
  });

  group('phase A — name + DOB (!babySetupDone)', () {
    test('logged-in user with no baby_setup_done lands on /onboarding/name', () {
      expect(
        resolve(at: AppRoute.home.path),
        AppRoute.onboardingName.path,
      );
    });

    test('both name and dob are allowed inside phase A — no loop on next', () {
      expect(resolve(at: AppRoute.onboardingName.path), isNull);
      expect(resolve(at: AppRoute.onboardingDob.path), isNull);
    });

    test('phase A blocks later stages until baby_setup_done flips', () {
      for (final later in [
        AppRoute.onboardingReadiness.path,
        AppRoute.onboardingResult.path,
        AppRoute.onboardingConsent.path,
      ]) {
        expect(
          resolve(at: later),
          AppRoute.onboardingName.path,
          reason: later,
        );
      }
    });
  });

  group('phase B — readiness (babySetupDone && !readinessDone)', () {
    test('readiness is allowed', () {
      expect(
        resolve(at: AppRoute.onboardingReadiness.path, babySetup: true),
        isNull,
      );
    });

    test('readiness bounces every other path', () {
      for (final other in [
        AppRoute.home.path,
        AppRoute.onboardingName.path,
        AppRoute.onboardingDob.path,
        AppRoute.onboardingResult.path,
        AppRoute.onboardingConsent.path,
      ]) {
        expect(
          resolve(at: other, babySetup: true),
          AppRoute.onboardingReadiness.path,
          reason: other,
        );
      }
    });
  });

  group(
    'phase C — result + consent (readinessDone && !onboardingDone)',
    () {
      test('result and consent are both allowed — no loop on result -> consent',
          () {
        expect(
          resolve(
            at: AppRoute.onboardingResult.path,
            babySetup: true,
            readiness: true,
          ),
          isNull,
        );
        expect(
          resolve(
            at: AppRoute.onboardingConsent.path,
            babySetup: true,
            readiness: true,
          ),
          isNull,
        );
      });

      test(
        'phase C bounces every other path to consent (the landing screen — '
        'kill/resume must land on the actionable submit step)',
        () {
          for (final other in [
            AppRoute.home.path,
            AppRoute.onboardingName.path,
            AppRoute.onboardingDob.path,
            AppRoute.onboardingReadiness.path,
          ]) {
            expect(
              resolve(at: other, babySetup: true, readiness: true),
              AppRoute.onboardingConsent.path,
              reason: other,
            );
          }
        },
      );
    },
  );

  group(
    'all done — onboarding_done = true (the reinstall seeded path)',
    () {
      test('any onboarding/auth path redirects to /home', () {
        for (final gated in [
          AppRoute.onboardingIntro.path,
          AppRoute.onboardingName.path,
          AppRoute.onboardingDob.path,
          AppRoute.onboardingReadiness.path,
          AppRoute.onboardingResult.path,
          AppRoute.onboardingConsent.path,
          AppRoute.onboardingBabySetup.path,
          AppRoute.forgotPassword.path,
          AppRoute.paywall.path,
        ]) {
          expect(
            resolve(
              at: gated,
              babySetup: true,
              readiness: true,
              onboarding: true,
            ),
            AppRoute.home.path,
            reason: gated,
          );
        }
      });

      test('home + child tabs pass through', () {
        for (final p in [
          AppRoute.home.path,
          AppRoute.mealPlan.path,
          AppRoute.shoppingList.path,
          AppRoute.recipeLibrary.path,
          AppRoute.profile.path,
        ]) {
          expect(
            resolve(
              at: p,
              babySetup: true,
              readiness: true,
              onboarding: true,
            ),
            isNull,
            reason: p,
          );
        }
      });
    },
  );

  group('legacy onboardingBabySetup path is caught by phase A', () {
    test('!babySetupDone redirects /onboarding/baby-setup to /onboarding/name',
        () {
      expect(
        resolve(at: AppRoute.onboardingBabySetup.path),
        AppRoute.onboardingName.path,
      );
    });
  });
}
