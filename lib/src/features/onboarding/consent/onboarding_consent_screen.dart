import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Final onboarding stage. Visual reskin owned by NIB-100.
///
/// Real logic (not a pure stub): on submit, calls `createBaby` via the hoisted
/// controller. P1 surface — on failure, shows the error inline and DOES NOT
/// flip `onboarding_done`, so kill-and-resume lands the user back here. On
/// success, flips `onboarding_done` and routes to `/home`. Consent itself is
/// ephemeral (NIB-120) and is NOT persisted.
class OnboardingConsentScreen extends ConsumerWidget {
  const OnboardingConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('TODO: consent')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CheckboxListTile(
              key: const Key('onboarding_consent_checkbox'),
              value: state.consentAccepted,
              onChanged: (v) => controller.setConsentAccepted(
                accepted: v ?? false,
              ),
              title: const Text('I agree (placeholder)'),
            ),
            if (state.submitErrorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.submitErrorMessage!,
                key: const Key('onboarding_consent_error'),
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('onboarding_consent_submit'),
              onPressed: (!state.consentAccepted || state.isSubmitting)
                  ? null
                  : () async {
                      final ok = await controller.submit();
                      if (!ok || !context.mounted) return;
                      ref
                          .read(localFlagServiceProvider)
                          .setOnboardingDone();
                      context.goNamed(AppRoute.home.name);
                    },
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
