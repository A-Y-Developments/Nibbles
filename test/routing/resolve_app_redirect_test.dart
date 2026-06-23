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
  //
  // Defaults to `subscribed: true` so existing pre-NIB-144 matrix rows keep
  // exercising the same redirect paths (without the M2 paywall guard kicking
  // in). The dedicated "M2 paywall guard" group below flips this to false.
  String? resolve({
    required String at,
    bool launched = true,
    bool loggedIn = true,
    bool babySetup = false,
    bool readiness = false,
    bool onboarding = false,
    bool subscribed = true,
    bool devSkip = false,
  }) => resolveAppRedirect(
    location: at,
    hasLaunched: launched,
    isLoggedIn: loggedIn,
    babySetupDone: babySetup,
    readinessDone: readiness,
    onboardingDone: onboarding,
    isSubscribed: subscribed,
    devPaywallSkipped: devSkip,
  );

  group('splash + first launch', () {
    test('splash is always a pass-through', () {
      expect(resolve(at: AppRoute.splash.path), isNull);
      expect(
        resolve(at: AppRoute.splash.path, launched: false, loggedIn: false),
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
      expect(resolve(at: AppRoute.login.path), AppRoute.splash.path);
    });

    test('logged-in user on /auth/register bounces to splash', () {
      expect(resolve(at: AppRoute.register.path), AppRoute.splash.path);
    });
  });

  group('phase A — name + DOB (!babySetupDone)', () {
    test(
      'logged-in user with no baby_setup_done lands on /onboarding/name',
      () {
        expect(resolve(at: AppRoute.home.path), AppRoute.onboardingName.path);
      },
    );

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
        expect(resolve(at: later), AppRoute.onboardingName.path, reason: later);
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

    test('name + dob allowed so back-nav from readiness Q1 reaches DOB', () {
      expect(
        resolve(at: AppRoute.onboardingName.path, babySetup: true),
        isNull,
      );
      expect(resolve(at: AppRoute.onboardingDob.path, babySetup: true), isNull);
    });

    test('readiness bounces forward paths back to readiness', () {
      for (final other in [
        AppRoute.home.path,
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

  group('phase C — result + consent (readinessDone && !onboardingDone)', () {
    test(
      'result and consent are both allowed — no loop on result -> consent',
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
      },
    );

    test('readiness is allowed so back-nav from result reaches readiness', () {
      expect(
        resolve(
          at: AppRoute.onboardingReadiness.path,
          babySetup: true,
          readiness: true,
        ),
        isNull,
      );
    });

    test('phase C bounces unrelated paths to consent (the landing screen — '
        'kill/resume must land on the actionable submit step)', () {
      for (final other in [
        AppRoute.home.path,
        AppRoute.onboardingName.path,
        AppRoute.onboardingDob.path,
      ]) {
        expect(
          resolve(at: other, babySetup: true, readiness: true),
          AppRoute.onboardingConsent.path,
          reason: other,
        );
      }
    });
  });

  group('all done — onboarding_done = true (the reinstall seeded path)', () {
    test('any onboarding/auth path redirects to /home', () {
      // Post-NIB-144: paywall is intentionally NOT in gatedPaths because
      // the M2 guard sends unsubscribed onboarded users TO it. Subscribed
      // onboarded users on paywall fall through to `null` (covered by the
      // M2 group below).
      for (final gated in [
        AppRoute.onboardingIntro.path,
        AppRoute.onboardingName.path,
        AppRoute.onboardingDob.path,
        AppRoute.onboardingReadiness.path,
        AppRoute.onboardingResult.path,
        AppRoute.onboardingConsent.path,
        AppRoute.onboardingBabySetup.path,
        AppRoute.forgotPassword.path,
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
          resolve(at: p, babySetup: true, readiness: true, onboarding: true),
          isNull,
          reason: p,
        );
      }
    });
  });

  group('legacy onboardingBabySetup path is caught by phase A', () {
    test(
      '!babySetupDone redirects /onboarding/baby-setup to /onboarding/name',
      () {
        expect(
          resolve(at: AppRoute.onboardingBabySetup.path),
          AppRoute.onboardingName.path,
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // NIB-105 — onboarding redirect matrix pin
  //
  // The four named phase-landing transitions are already exercised piecemeal
  // above. This group restates them as the literal NIB-105 contract row so a
  // future edit of `resolveAppRedirect` that touches phase landings (without
  // breaking the existing rows) is still caught by a single, top-level
  // assertion per phase.
  // ---------------------------------------------------------------------------
  group('NIB-105 onboarding redirect contract', () {
    test('!babySetupDone -> /onboarding/name', () {
      expect(resolve(at: AppRoute.home.path), AppRoute.onboardingName.path);
    });

    test('babySetupDone && !readinessDone -> /onboarding/readiness', () {
      expect(
        resolve(at: AppRoute.home.path, babySetup: true),
        AppRoute.onboardingReadiness.path,
      );
    });

    test('readinessDone && !onboardingDone -> /onboarding/consent', () {
      expect(
        resolve(at: AppRoute.home.path, babySetup: true, readiness: true),
        AppRoute.onboardingConsent.path,
      );
    });

    test('all done -> /home (passes through)', () {
      expect(
        resolve(
          at: AppRoute.home.path,
          babySetup: true,
          readiness: true,
          onboarding: true,
        ),
        isNull,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // M2 paywall guard — DISABLED while M2 is deferred (step 8 commented out in
  // resolveAppRedirect). Onboarded users reach /home regardless of subscription
  // state. These rows pin the disabled behaviour; restore them to the NIB-144
  // contract (unsubscribed -> /subscription/paywall) when the paywall ships.
  // ---------------------------------------------------------------------------
  group('M2 paywall guard (disabled — M2 deferred)', () {
    test('onboarded + unsubscribed user reaches /home + tabs (guard off)', () {
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
            subscribed: false,
          ),
          isNull,
          reason: p,
        );
      }
    });

    test(
      'onboarded + unsubscribed user can reach paywall + success screens',
      () {
        for (final p in [
          AppRoute.paywall.path,
          AppRoute.subscriptionSuccess.path,
        ]) {
          expect(
            resolve(
              at: p,
              babySetup: true,
              readiness: true,
              onboarding: true,
              subscribed: false,
            ),
            isNull,
            reason: p,
          );
        }
      },
    );

    test('onboarded + subscribed user can reach /home', () {
      expect(
        resolve(
          at: AppRoute.home.path,
          babySetup: true,
          readiness: true,
          onboarding: true,
        ),
        isNull,
      );
    });

    test(
      'onboarded + subscribed user on paywall passes through (no bounce)',
      () {
        expect(
          resolve(
            at: AppRoute.paywall.path,
            babySetup: true,
            readiness: true,
            onboarding: true,
          ),
          isNull,
        );
      },
    );

    test('guard does not fire while still onboarding', () {
      // Phase A — unsubscribed user must still be funneled through onboarding,
      // not bounced to paywall.
      expect(
        resolve(at: AppRoute.home.path, subscribed: false),
        AppRoute.onboardingName.path,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // NIB-150 — dev-flavor paywall skip. The flag is only ever true in the dev
  // flavor (composed at the router as `enabled && skipped`); the resolver
  // itself just honors it so the matrix stays pure.
  // ---------------------------------------------------------------------------
  group('NIB-150 dev paywall skip', () {
    test('skip flag lets an onboarded unsubscribed user reach home + tabs', () {
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
            subscribed: false,
            devSkip: true,
          ),
          isNull,
          reason: p,
        );
      }
    });

    test('skip flag does not bypass onboarding phases', () {
      expect(
        resolve(at: AppRoute.home.path, subscribed: false, devSkip: true),
        AppRoute.onboardingName.path,
      );
    });

    test('guard disabled — omitted skip flag still reaches /home', () {
      // With the M2 guard off, the skip flag is moot: an onboarded unsubscribed
      // user reaches /home whether or not devSkip is set.
      expect(
        resolve(
          at: AppRoute.home.path,
          babySetup: true,
          readiness: true,
          onboarding: true,
          subscribed: false,
        ),
        isNull,
      );
    });
  });
}
