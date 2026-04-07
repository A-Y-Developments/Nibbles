import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_controller.g.dart';

@riverpod
class SplashController extends _$SplashController {
  @override
  Future<String> build() async {
    await Future<void>.delayed(const Duration(seconds: 3));

    final flags = ref.read(localFlagServiceProvider);
    if (!flags.hasLaunched()) {
      flags.setHasLaunched();
      // On reinstall the session may be restored (iOS keychain persists).
      // Fall through to the Supabase check so flags get backfilled.
      final isLoggedIn = ref.read(authServiceProvider);
      if (!isLoggedIn) return '/onboarding/intro';
    }

    final isLoggedIn = ref.read(authServiceProvider);
    if (!isLoggedIn) return '/auth/login';

    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) return '/onboarding/intro';

    final onboardingDone = await ref
        .read(babyProfileServiceProvider)
        .onboardingCompleted;
    if (!onboardingDone) return '/onboarding/intro';

    // Seed local flags from Supabase so reinstalls don't re-trigger onboarding.
    flags
      ..setOnboardingReadinessDone()
      ..setOnboardingBabySetupDone();

    // TODO(nibbles-backend): uncomment when subscriptionServiceProvider ships
    // if (!ref.read(subscriptionServiceProvider)) {
    //   return '/subscription/paywall';
    // }

    return '/home';
  }
}
