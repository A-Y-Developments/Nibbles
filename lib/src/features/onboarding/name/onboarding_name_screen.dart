import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Stub for OB name capture. Visual reskin owned by NIB-66.
///
/// Writes a default name into the hoisted controller and advances. End-to-end
/// flow navigability is the acceptance criterion for NIB-51; the real text
/// field comes with the reskin.
class OnboardingNameScreen extends ConsumerWidget {
  const OnboardingNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('TODO: name')),
      body: Center(
        child: FilledButton(
          key: const Key('onboarding_name_next'),
          onPressed: () {
            ref.read(onboardingControllerProvider.notifier).updateName('Baby');
            context.goNamed(AppRoute.onboardingDob.name);
          },
          child: const Text('Next'),
        ),
      ),
    );
  }
}
