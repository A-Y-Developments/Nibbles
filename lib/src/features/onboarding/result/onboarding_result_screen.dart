import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Stub for OB readiness result. Visual reskin owned by NIB-91.
///
/// Pass-through screen — no flag of its own. Advances to consent.
class OnboardingResultScreen extends ConsumerWidget {
  const OnboardingResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('TODO: result')),
      body: Center(
        child: FilledButton(
          key: const Key('onboarding_result_next'),
          onPressed: () => context.goNamed(AppRoute.onboardingConsent.name),
          child: const Text('Next'),
        ),
      ),
    );
  }
}
