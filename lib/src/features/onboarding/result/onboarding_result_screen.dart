import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/features/onboarding/onboarding_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Short labels for the 5 developmental signs surfaced on the result card.
/// Index aligns with `readinessAnswers` on [OnboardingState] (set by the
/// readiness screen). Kept terse — the question form lives on the readiness
/// step; this screen summarizes.
const List<String> _signLabels = [
  'Holds head steady',
  'Sits upright with minimal support',
  'Tongue-thrust reflex gone',
  'Shows interest in food',
  'Brings objects to mouth',
];

/// NIB-91 — Readiness RESULT screen.
///
/// Reads `readinessAnswers` (length 5) from the hoisted [OnboardingController]
/// and renders one of two variants based on `signsMet >= 3` (NIB-120 majority
/// gate). Soft-warn UX: Next routes to `/onboarding/consent` in BOTH variants.
///
/// * READY (signs_met >= 3): butter card, all 5 signs rendered with a green
///   check, "New Journey Unlock!" headline.
/// * NOT-READY (signs_met < 3): sage card, each sign rendered with the
///   per-answer check or cross, "not ready" headline.
///
/// Back routes to `/onboarding/readiness` — the readiness screen `go`s here so
/// the navigator stack typically can't pop; `goNamed` preserves the hoisted
/// controller's captured answers (keepAlive).
class OnboardingResultScreen extends ConsumerWidget {
  const OnboardingResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Defensive: the screen indexes `_signLabels` by the readiness-answer
    // position. If either drifts from `readinessQuestionCount`, fail loudly in
    // debug instead of silently mis-rendering.
    assert(
      _signLabels.length == readinessQuestionCount,
      'Result sign label count drifted from OnboardingState seed',
    );

    final answers = ref.watch(
      onboardingControllerProvider.select((s) => s.readinessAnswers),
    );
    final babyNameRaw = ref.watch(
      onboardingControllerProvider.select((s) => s.babyName.value),
    );

    final firstName = _firstToken(babyNameRaw);
    final signsMet = answers.where((a) => a ?? false).length;
    final ready = signsMet >= readinessReadyThreshold;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: AppSizes.roundButton + AppSizes.md,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSizes.md),
          child: Center(
            child: AppRoundButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tone: AppRoundButtonTone.butter,
              semanticLabel: 'Back',
              onPressed: () => _onBack(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePaddingH,
            AppSizes.sm,
            AppSizes.pagePaddingH,
            AppSizes.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _ResultCard(
                    firstName: firstName,
                    answers: answers,
                    signsMet: signsMet,
                    ready: ready,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              AppPillButton(
                key: const Key('onboarding_result_next'),
                label: 'Next',
                onPressed: () =>
                    context.goNamed(AppRoute.onboardingConsent.name),
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
    // Readiness `go`s here, so the stack typically can't pop. Fall through to
    // a named nav so back consistently returns to the questionnaire; the
    // hoisted controller (keepAlive) preserves the captured answers.
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(AppRoute.onboardingReadiness.name);
  }
}

/// Majority gate per NIB-120: ready iff at least this many signs are met.
const int readinessReadyThreshold = 3;

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.firstName,
    required this.answers,
    required this.signsMet,
    required this.ready,
  });

  final String firstName;
  final List<bool?> answers;
  final int signsMet;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardColor = ready ? AppColors.butter : AppColors.green;
    final petalColor = ready ? AppColors.butterSoft : AppColors.greenTint;
    final coreColor = ready ? AppColors.greenDeep : AppColors.butter;
    final fgStrong = ready ? AppColors.greenDeep : AppColors.cream;
    final fgSoft = ready
        ? AppColors.greenDeep.withAlpha(204)
        : AppColors.cream.withAlpha(230);
    final eyebrow = ready ? 'New Journey Unlock!' : 'Almost there';
    final headline = ready
        ? '$firstName is ready for solids at this time'
        : '$firstName is not ready for solids at this time';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radius2xl),
        boxShadow: AppSizes.shadowCardLifted,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.xl,
          AppSizes.lg,
          AppSizes.lg,
        ),
        child: Column(
          children: [
            Quatrefoil(
              size: AppSizes.xxxl,
              petalColor: petalColor,
              coreColor: coreColor,
            ),
            const SizedBox(height: AppSizes.md),
            _ScoreBadge(signsMet: signsMet, ready: ready),
            const SizedBox(height: AppSizes.md),
            Text(
              eyebrow,
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                color: fgSoft,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(color: fgStrong),
            ),
            const SizedBox(height: AppSizes.lg),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sp12,
                ),
                child: Column(
                  children: List<Widget>.generate(_signLabels.length, (i) {
                    // Ready variant: all rows render as positive (green check)
                    // per spec Step 3, regardless of per-answer values. The
                    // X/5 badge still reflects `signsMet` so the user sees
                    // their actual score.
                    final isPositive = ready || (answers[i] ?? false);
                    return Padding(
                      padding: EdgeInsets.only(
                        top: i == 0 ? 0 : AppSizes.sp12,
                      ),
                      child: _SignRow(
                        label: _signLabels[i],
                        positive: isPositive,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.signsMet, required this.ready});

  final int signsMet;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final bg = ready ? AppColors.greenDeep : AppColors.butter;
    final fg = ready ? AppColors.cream : AppColors.greenDeep;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
        child: Text(
          '$signsMet / ${_signLabels.length} signs',
          style: AppTypography.bodyBold.copyWith(color: fg),
        ),
      ),
    );
  }
}

class _SignRow extends StatelessWidget {
  const _SignRow({required this.label, required this.positive});

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final markBg = positive ? AppColors.greenTint : AppColors.destructiveSoft;
    final markFg = positive ? AppColors.greenDeep : AppColors.destructive;
    final icon = positive ? Icons.check_rounded : Icons.close_rounded;

    return Row(
      children: [
        Container(
          width: AppSizes.iconMd,
          height: AppSizes.iconMd,
          decoration: BoxDecoration(
            color: markBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: markFg, size: AppSizes.iconSm),
        ),
        const SizedBox(width: AppSizes.sp12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyBold.copyWith(
              color: AppColors.fgDefault,
            ),
          ),
        ),
      ],
    );
  }
}
