import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';
import 'package:nibbles/src/utils/age_in_months.dart';

/// Consent / housekeeping — final onboarding stage.
///
/// Per NIB-100 (Figma 971:10184 / 971:10198): Quatrefoil + title1 +
/// age-gated checkbox list (2 boxes if baby is >= 6 months old; 3 boxes if
/// younger, with an extra "full responsibility" acknowledgement). CTA is
/// disabled until every box is checked. Consent itself is EPHEMERAL per
/// NIB-120 — checkbox state lives in this widget only, never persisted.
///
/// Submit path: validates name/DOB via [OnboardingController.submit] which
/// creates the baby via the baby-profile service. On success this screen
/// sets `onboarding_done` + navigates to `/home` (the GoRouter redirect
/// cannot fire without the flag and nothing else flips it). On failure the
/// inline P1 error from `state.submitErrorMessage` is shown with a Retry
/// button.
class OnboardingConsentScreen extends ConsumerStatefulWidget {
  const OnboardingConsentScreen({super.key});

  @override
  ConsumerState<OnboardingConsentScreen> createState() =>
      _OnboardingConsentScreenState();
}

class _OnboardingConsentScreenState
    extends ConsumerState<OnboardingConsentScreen> {
  // Default to the safer 2-checkbox path when DOB is missing (spec step 2).
  static const int _defaultAgeMonths = 6;
  static const int _earlySolidsThresholdMonths = 6;

  late List<bool> _checks;

  @override
  void initState() {
    super.initState();
    final dob = ref.read(onboardingControllerProvider).dob;
    final ageMonths = dob != null ? ageInMonths(dob) : _defaultAgeMonths;
    _checks = List<bool>.filled(_countFor(ageMonths), false);
  }

  int _countFor(int ageMonths) =>
      ageMonths >= _earlySolidsThresholdMonths ? 2 : 3;

  bool get _allChecked => _checks.every((c) => c);

  void _toggle(int index, {required bool value}) {
    setState(() => _checks[index] = value);
  }

  Future<void> _onConfirm() async {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final ok = await controller.submit();
    if (!ok || !mounted) return;
    ref.read(localFlagServiceProvider).setOnboardingDone();
    if (!mounted) return;
    context.goNamed(AppRoute.home.name);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSubmitting = ref.watch(
      onboardingControllerProvider.select((s) => s.isSubmitting),
    );
    final errorMessage = ref.watch(
      onboardingControllerProvider.select((s) => s.submitErrorMessage),
    );

    final canConfirm = _allChecked && !isSubmitting;
    final ctaLabel = _allChecked ? 'Yes, I Understand' : 'Check confirmation';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: Quatrefoil()),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Before we start, some housekeeping',
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: AppSizes.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _checks.length; i++) ...[
                        _ConsentCheckboxRow(
                          key: Key('onboarding_consent_checkbox_$i'),
                          label: _labelFor(i, _checks.length),
                          value: _checks[i],
                          onChanged: (v) => _toggle(i, value: v),
                        ),
                        if (i < _checks.length - 1)
                          const SizedBox(height: AppSizes.md),
                      ],
                      if (errorMessage != null) ...[
                        const SizedBox(height: AppSizes.md),
                        _InlineError(
                          key: const Key('onboarding_consent_error'),
                          message: errorMessage,
                          onRetry: canConfirm ? _onConfirm : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AppPillButton(
                key: const Key('onboarding_consent_submit'),
                label: ctaLabel,
                onPressed: canConfirm ? _onConfirm : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Copy for each checkbox row. Index 2 only renders when [count] == 3 (baby
  /// younger than 6 months) and carries the early-solids acknowledgement.
  String _labelFor(int index, int count) {
    switch (index) {
      case 0:
        return 'I understand Nibbles is guidance, not medical advice.';
      case 1:
        return 'I will watch my baby closely during meals and stop if anything '
            "doesn't feel right.";
      case 2:
        // Only shown when count == 3 — verbatim from the spec.
        return 'I accept full responsibility for my decision to start solids '
            'before 6 months.';
      default:
        return '';
    }
  }
}

/// Row composed of [AppCheckbox] + label text. Tapping the label toggles the
/// checkbox so the whole row is a hit target (kit pattern).
class _ConsentCheckboxRow extends StatelessWidget {
  const _ConsentCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              // Nudge the checkbox down so it visually aligns with the first
              // line of label text (label has a 22pt line-height; checkbox 24).
              padding: const EdgeInsets.only(top: 2),
              child: AppCheckbox(
                value: value,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: AppSizes.sp12),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.fgDefault,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// P1 inline error surface — destructive-tinted panel with a Retry affordance.
/// Retry is null while submit is in-flight or the boxes are unchecked, so the
/// user can't fire a duplicate submit mid-request.
class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.destructiveSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.destructive,
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Align(
            alignment: Alignment.centerRight,
            child: AppPillButton(
              key: const Key('onboarding_consent_retry'),
              label: 'Retry',
              variant: AppPillButtonVariant.secondary,
              size: AppPillButtonSize.small,
              expand: false,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}
