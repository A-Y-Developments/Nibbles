import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/legal/constants/legal_document.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Consent — final onboarding stage (NIB-100).
///
/// Figma section 1255:11883 "Terms and service": 971:10184 / 971:10215
/// (>6mo, empty + checked) and 971:10198 / 971:10229 (<6mo, empty + checked).
///
/// Composition (top → bottom):
///   - Title `Let's start safely` + 2-line subtitle
///   - Flower cluster centered in the free space
///   - Three checkboxes pinned to the bottom with the CTA row
///   - Bottom row: butter `AppRoundButton` (back) + primary CTA
///     `Check confirmation` (disabled) → `Yes, I Understand` (enabled)
///
/// The list is NOT age-gated. Figma only drew the third (Terms / Disclaimer /
/// Privacy) box on the <6mo frames, but an acceptance collected from half the
/// users is worthless, so it renders for everyone. The former early-solids
/// responsibility clause was removed from the design and is gone here too.
///
/// Checkbox copy is verbatim from Figma, curly apostrophes and trailing full
/// stops included.
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
  final List<bool> _checks = List<bool>.filled(_consentLabels.length, false);

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

    return PopScope(
      // Block system back and hardware back while submit is in-flight to
      // prevent racing the createBaby call with orphaned baby rows.
      canPop: !isSubmitting,
      child: GradientScaffold(
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
                  'Let’s start safely',
                  textAlign: TextAlign.center,
                  // Figma Title 1/Bold 22 (siblings also 22).
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSizes.sp12),
                // Figma 3126:11876 — Body/Regular, centred, 304 wide inside
                // the 366 column. The inset is what forces the annotated
                // 2-line break ("…before your / Nibbles journey begins.").
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                  child: Text(
                    'A few important things to know before your Nibbles '
                    'journey begins.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.fgDefault,
                    ),
                  ),
                ),
                // Flower + checklist share the free space. minHeight keeps the
                // checklist bottom-pinned on a roomy screen; the scroll view is
                // the release valve on a short one, where three checkboxes plus
                // the inline P1 error no longer fit (iPhone SE overflowed).
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Empty leading child so `spaceBetween` splits the
                            // slack evenly above and below the flower, leaving
                            // it centred in the gap (Figma) with the checklist
                            // still pinned to the bottom.
                            const SizedBox.shrink(),
                            // Figma 1025:7330 — 220x220 cluster in the gap
                            // between the subtitle and the checklist.
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.lg,
                              ),
                              child:
                                  const Center(
                                        child: BrandFlower(size: _flowerSize),
                                      )
                                      .animate()
                                      .fadeIn(duration: AppDurations.slow)
                                      .scale(
                                        duration: AppDurations.slow,
                                        curve: AppCurves.emphasized,
                                        begin: const Offset(0.85, 0.85),
                                        end: const Offset(1, 1),
                                      ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < _checks.length; i++) ...[
                                  _ConsentCheckboxRow(
                                    key: Key('onboarding_consent_checkbox_$i'),
                                    identifier:
                                        'onboarding_consent_checkbox_$i',
                                    label: _consentLabels[i],
                                    labelWidget: i == _linkedConsentIndex
                                        ? _buildLinkedLabel(context)
                                        : null,
                                    value: _checks[i],
                                    onChanged: (v) => _toggle(i, value: v),
                                  ).animate().fadeIn(
                                    delay: (120 + 70 * i).ms,
                                    duration: AppDurations.fade,
                                  ),
                                  if (i < _checks.length - 1)
                                    const SizedBox(height: AppSizes.sm),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: AppDurations.base,
                  curve: AppCurves.standard,
                  alignment: Alignment.topCenter,
                  child: errorMessage == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: AppSizes.md),
                          child: _InlineError(
                            key: const Key('onboarding_consent_error'),
                            message: errorMessage,
                            onRetry: canConfirm ? _onConfirm : null,
                          ).animate().fadeIn(duration: AppDurations.fade),
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
                      // Gate back during submit: orphan-baby race.
                      onPressed: isSubmitting ? null : _onBack,
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
      ),
    );
  }

  /// Row 3 rendered with tappable document links. The flat string still backs
  /// the row's semantics label, so screen readers read the whole sentence.
  ///
  /// "Terms of Use" is deliberately NOT a link — that document does not exist
  /// yet. "Privacy Policy" links only once [kPrivacyPolicyPublished] flips.
  Widget _buildLinkedLabel(BuildContext context) {
    void open(String slug) => context.pushNamed(
      AppRoute.legalDocument.name,
      pathParameters: {'slug': slug},
    );

    return AppLinkedText(
      text: _consentLabels[_linkedConsentIndex],
      links: {
        'Medical & Safety Disclaimer': () => open(kLegalDisclaimerSlug),
        'Privacy Policy': kPrivacyPolicyPublished
            ? () => open(kLegalPrivacyPolicySlug)
            : null,
      },
    );
  }
}

// Declared individually so each can wrap across lines —
// `no_adjacent_strings_in_list` bans that inside the list literal itself.
const String _consentGuideLabel =
    'I understand that Nibbles is a general guide and that I remain '
    'responsible for making feeding decisions based on my child’s individual '
    'needs.';

const String _consentSuperviseLabel =
    'I will actively supervise my child while eating, follow the safety '
    'guidance, check ingredients and allergens, and seek professional or '
    'emergency help when needed.';

const String _consentTermsLabel =
    'I have read and agree to the Terms of Use, including the Medical & '
    'Safety Disclaimer, and acknowledge the Privacy Policy.';

/// Verbatim checkbox copy from Figma section 1255:11883.
const List<String> _consentLabels = [
  _consentGuideLabel,
  _consentSuperviseLabel,
  _consentTermsLabel,
];

/// Index of the row that carries the document links.
const int _linkedConsentIndex = 2;

/// Figma 1025:7330 — the flower cluster's drawn size.
const double _flowerSize = 220;

/// Row composed of [AppCheckbox] + label text. Tapping the row toggles the
/// checkbox so the whole label is a hit target (kit pattern).
class _ConsentCheckboxRow extends StatelessWidget {
  const _ConsentCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.identifier,
    this.labelWidget,
    super.key,
  });

  final String label;

  /// Replaces the plain [Text] rendering of [label] when the row needs inline
  /// links. [label] still backs the semantics so the sentence reads whole.
  final Widget? labelWidget;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String identifier;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      identifier: identifier,
      container: true,
      checked: value,
      onTap: () => onChanged(!value),
      label: label,
      child: InkWell(
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
                padding: const EdgeInsets.only(top: AppSizes.sp2),
                child: ExcludeSemantics(
                  child: AppCheckbox(value: value, onChanged: onChanged),
                ),
              ),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child:
                    labelWidget ??
                    Text(
                      label,
                      // Body/Regular per Figma (Figtree 15/22) → bodyLarge.
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.fgDefault,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// P1 inline error surface — destructive-tinted panel with a Retry affordance.
/// Retry is null while submit is in-flight or the boxes are unchecked so the
/// user can't fire a duplicate submit mid-request.
class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      container: true,
      label: 'Error: $message',
      child: Container(
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
                const ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.destructive,
                    size: AppSizes.iconMd,
                  ),
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
      ),
    );
  }
}
