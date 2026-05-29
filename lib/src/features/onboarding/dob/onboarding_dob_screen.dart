import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Stub for OB DOB capture. Visual reskin owned by NIB-74.
///
/// Writes a default DOB (today - 180d) into the hoisted controller, flips the
/// baby-setup flag, and advances to readiness. End-to-end flow navigability is
/// the acceptance criterion for NIB-51.
class OnboardingDobScreen extends ConsumerWidget {
  const OnboardingDobScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('TODO: dob')),
      body: Center(
        child: FilledButton(
          key: const Key('onboarding_dob_next'),
          onPressed: () {
            final defaultDob = DateTime.now().subtract(
              const Duration(days: 180),
            );
            ref.read(onboardingControllerProvider.notifier).updateDob(
              defaultDob,
            );
            ref.read(localFlagServiceProvider).setOnboardingBabySetupDone();
            context.goNamed(AppRoute.onboardingReadiness.name);
          },
          child: const Text('Next'),
        ),
      ),
    );
  }
}
