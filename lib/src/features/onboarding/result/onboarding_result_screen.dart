import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';
import 'package:nibbles/src/common/components/layout/gradient_scaffold.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/features/onboarding/onboarding_state.dart';
import 'package:nibbles/src/features/onboarding/readiness/readiness_signs.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Lime fill for the Readiness Signs card — matched to the baby-icon hero so
/// the cluster blends into the card edge (per design feedback).
const Color _signsCardColor = Color(0xFFE9EB8C);

/// NIB-91 — Readiness RESULT screen.
///
/// Reads `readinessAnswers` (length 5) from the hoisted [OnboardingController]
/// and renders one of two variants based on `signsMet >= 3` (NIB-120 majority
/// gate). Soft-warn UX: Next routes to `/onboarding/consent` in BOTH variants.
///
/// Layout matches Figma 1255:11893 / 1029:8508:
/// * Title (+ eyebrow on ready) at the top above the hero.
/// * Hero quatrefoil cluster overlaps the top of the lime card.
/// * Card carries the "Readiness Signs" header row + salmon X/5 chip and the
///   5 sign rows with per-answer check/cross icons (ready variant renders all
///   rows as passed regardless of per-answer values).
/// * Bottom row: butter `AppRoundButton` (back) + primary `AppPillButton` Next.
///
/// Back returns to `/onboarding/readiness` — readiness `push`es this screen, so
/// `_onBack` is a plain pop that lands on the last question with the hoisted
/// controller's captured answers intact (keepAlive). A `goNamed` fallback
/// covers the kill-and-resume case where the stack can't pop.
class OnboardingResultScreen extends ConsumerWidget {
  const OnboardingResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Defensive: row 0 is the pediatrician gate, rows 1-5 the developmental
    // signs — so the label count must be the question count + 1. Fail loudly
    // in debug if either drifts.
    assert(
      kReadinessSignLabels.length == readinessQuestionCount + 1,
      'Result sign label count drifted from OnboardingState seed',
    );

    final answers = ref.watch(
      onboardingControllerProvider.select((s) => s.readinessAnswers),
    );
    final pediatricianApproved = ref.watch(
      onboardingControllerProvider.select((s) => s.pediatricianApproved),
    );
    final babyNameRaw = ref.watch(
      onboardingControllerProvider.select((s) => s.babyName.value),
    );

    // Pediatrician gate (Q1) is the first sign, then the five Q2-Q6 answers.
    final signs = <bool?>[pediatricianApproved, ...answers];
    final firstName = _firstToken(babyNameRaw);
    final signsMet = signs.where((a) => a ?? false).length;
    final ready = signsMet >= kReadinessReadyThreshold;
    final outcomeTitle = ready
        ? '$firstName is ready for solids at this time'
        : '$firstName is not ready for solids at this time';

    final textTheme = Theme.of(context).textTheme;

    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (ready) ...[
                        Text(
                          'New Journey Unlock!',
                          textAlign: TextAlign.center,
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.fgStrong,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                      ],
                      Text(
                        outcomeTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.fgStrong,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      _HeroCard(
                        signsMet: signsMet,
                        answers: signs,
                        ready: ready,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  AppRoundButton(
                    key: const Key('onboarding_result_back'),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tone: AppRoundButtonTone.butter,
                    semanticLabel: 'Back',
                    onPressed: () => _onBack(context),
                  ),
                  const SizedBox(width: AppSizes.sp12),
                  Expanded(
                    child: AppPillButton(
                      key: const Key('onboarding_result_next'),
                      label: 'Next',
                      // Push (not go) so consent's back button gets a real
                      // reverse pop. Safe: result + consent share phase C, so
                      // popping consent->result is not redirect-bounced.
                      onPressed: () =>
                          context.pushNamed(AppRoute.onboardingConsent.name),
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

  /// First whitespace-separated token of [raw], or "your baby" fallback when
  /// the name has not been captured yet. Mirrors the readiness screen so copy
  /// stays consistent across both stages.
  String _firstToken(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'your baby';
    final idx = trimmed.indexOf(' ');
    return idx < 0 ? trimmed : trimmed.substring(0, idx);
  }

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(AppRoute.onboardingReadiness.name);
  }
}

/// Hero cluster + lime card composition. Stack overlaps the brand mark on the
/// top edge of the card so it visually punches through the lime panel — matches
/// the Figma 1255:11893 / 1029:8508 layering.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.signsMet,
    required this.answers,
    required this.ready,
  });

  final int signsMet;
  final List<bool?> answers;
  final bool ready;

  // Figma readiness-ready/not-ready hero "Group 78" is 154x154.
  static const double _heroSize = 154;

  @override
  Widget build(BuildContext context) {
    // Overlap = half the hero so the lower hemisphere sits inside the card.
    const overlap = _heroSize / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: overlap),
          child: _SignsCard(signsMet: signsMet, answers: answers, ready: ready),
        ),
        Assets.images.onboarding.babyIcon.svg(
          width: _heroSize,
          height: _heroSize,
        ),
      ],
    );
  }
}

class _SignsCard extends StatelessWidget {
  const _SignsCard({
    required this.signsMet,
    required this.answers,
    required this.ready,
  });

  final int signsMet;
  final List<bool?> answers;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        // Matches the baby-icon hero so the cluster blends into the card.
        color: _signsCardColor,
        borderRadius: BorderRadius.circular(AppSizes.radius2xl),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          // Clear only the hero's lower chin (not the full half) so the header
          // sits close under the baby icon — Figma's tight hero/header gap.
          AppSizes.lg + (_HeroCard._heroSize * 0.30),
          AppSizes.lg,
          AppSizes.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Readiness Signs',
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.fgDefault,
                    ),
                  ),
                ),
                _ScoreChip(
                  signsMet: signsMet,
                  total: kReadinessSignLabels.length,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            for (var i = 0; i < kReadinessSignLabels.length; i++) ...[
              _SignRow(
                // Ready variant: all rows render as positive per spec — the
                // X/5 chip still reflects `signsMet` so the user sees their
                // actual score.
                positive: ready || (answers[i] ?? false),
                label: kReadinessSignLabels[i],
              ),
              if (i < kReadinessSignLabels.length - 1)
                const SizedBox(height: AppSizes.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.signsMet, required this.total});

  final int signsMet;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sp12,
          vertical: AppSizes.xs,
        ),
        child: Text(
          '$signsMet/$total',
          style: textTheme.labelMedium?.copyWith(color: AppColors.coralDeep),
        ),
      ),
    );
  }
}

class _SignRow extends StatelessWidget {
  const _SignRow({required this.positive, required this.label});

  final bool positive;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final glyph = positive ? Icons.check_circle_outline : Icons.cancel_outlined;
    return Semantics(
      container: true,
      label: '${positive ? 'Met' : 'Not met'}: $label',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: AppSizes.iconLg,
              height: AppSizes.iconLg,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Assets.images.onboarding.readinessSignBadge.svg(
                    width: AppSizes.iconLg,
                    height: AppSizes.iconLg,
                    colorFilter: const ColorFilter.mode(
                      AppColors.cream,
                      BlendMode.srcIn,
                    ),
                  ),
                  Icon(
                    glyph,
                    size: AppSizes.iconSm,
                    color: AppColors.greenDeep,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sp12),
            Expanded(
              child: Padding(
                // Nudge label down to visually center against the icon.
                padding: const EdgeInsets.only(top: AppSizes.xs),
                child: Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgDefault,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
