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

/// Consent / housekeeping — final onboarding stage (NIB-100).
///
/// Figma nodes: 971:10184 (>=6mo, empty) / 971:10215 (>=6mo, checked) /
/// 971:10198 (<6mo, empty) / 971:10229 (<6mo, checked).
///
/// Composition (top → bottom):
///   - Title `Before we start, some housekeeping`
///   - Brand `PetalBlob` (shared with baby-setup-loading)
///   - Age-gated checkbox list (2 boxes when baby >= 6mo, 3 when younger —
///     extra row carries the "full responsibility" early-solids clause)
///   - Bottom row: butter `AppRoundButton` (back) + primary CTA
///     `Check confirmation` (disabled) → `Yes, I Understand` (enabled)
///
/// All checkbox copy is verbatim from the Figma audit (no trailing periods,
/// matches the spec strings byte-for-byte).
///
/// Consent itself is EPHEMERAL per NIB-120 — checkbox state lives in this
/// widget only, never persisted. Submit path validates name/DOB via
/// [OnboardingController.submit] which creates the baby via the baby-profile
/// service. On success this screen sets `onboarding_done` + navigates to
/// `/home`. On failure the inline P1 error from `state.submitErrorMessage`
/// is shown with a Retry button.
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
    // NIB-137 — drop the user on the post-consent loading transition; the
    // loading screen auto-routes to /home after a short min dwell. createBaby
    // has already resolved at this point so this screen is purely visual.
    context.goNamed(AppRoute.onboardingBabySetupLoading.name);
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    // Defensive fall-through: result is the previous stage in the new flow
    // (NIB-51). The hoisted controller (keepAlive) preserves answers.
    context.goNamed(AppRoute.onboardingResult.name);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Before we start, some housekeeping',
                textAlign: TextAlign.center,
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: AppSizes.lg),
              // Figma audit calls the cluster at 220x220; we render at 180
              // so the 3-checkbox <6mo variant still fits without scrolling on
              // ~5.5" devices (the cluster scales linearly via [PetalBlob]).
              const Center(child: PetalBlob(size: 180)),
              const SizedBox(height: AppSizes.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _checks.length; i++) ...[
                        _ConsentCheckboxRow(
                          key: Key('onboarding_consent_checkbox_$i'),
                          label: _labelFor(i),
                          value: _checks[i],
                          onChanged: (v) => _toggle(i, value: v),
                        ),
                        if (i < _checks.length - 1)
                          const SizedBox(height: AppSizes.sm),
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
              Row(
                children: [
                  AppRoundButton(
                    key: const Key('onboarding_consent_back'),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tone: AppRoundButtonTone.butter,
                    semanticLabel: 'Back',
                    onPressed: _onBack,
                  ),
                  const SizedBox(width: AppSizes.sp12),
                  Expanded(
                    child: AppPillButton(
                      key: const Key('onboarding_consent_submit'),
                      label: ctaLabel,
                      onPressed: canConfirm ? _onConfirm : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Verbatim copy for each checkbox row from the Figma audit
  /// (.figma-audit/onboarding/baby-setup-{gt6mo,lt6mo}-1/report.md).
  ///
  /// Index 2 only renders when `_checks.length == 3` (baby younger than
  /// 6 months) and carries the early-solids responsibility acknowledgement.
  String _labelFor(int index) {
    switch (index) {
      case 0:
        return 'I understand that Nibbles shares general educational '
            'information, not medical advice, and that parents make the '
            'final decisions for their baby';
      case 1:
        return 'I confirm I have received medical clearance and understand '
            'the above';
      case 2:
        return 'I accept full responsibility for my decision to start solids '
            'before 6 months';
      default:
        return '';
    }
  }
}

/// Row composed of [AppCheckbox] + label text. Tapping the row toggles the
/// checkbox so the whole label is a hit target (kit pattern).
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
              // line of label text.
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
                // Body/Regular per Figma audit (Figtree 15/22) → bodyLarge.
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
/// Retry is null while submit is in-flight or the boxes are unchecked so the
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
