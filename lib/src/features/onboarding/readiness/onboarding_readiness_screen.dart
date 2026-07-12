import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/features/onboarding/onboarding_state.dart';
import 'package:nibbles/src/features/onboarding/readiness/widgets/readiness_choice_card.dart';
import 'package:nibbles/src/features/onboarding/readiness/widgets/readiness_progress_bar.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Total step count for the 6-screen NIB-83 readiness questionnaire (Q1
/// pediatrician gate + Q2-Q6 developmental signs).
const int _readinessTotalSteps = 1 + readinessQuestionCount;

/// Per-step copy / option labels. Step 0 is the Q1 pediatrician gate;
/// steps 1..5 align with `readinessAnswers[0..4]`.
///
/// Verbatim from the Linear ticket and the Figma audit
/// (.figma-audit/onboarding/readiness-check-{1..6}). Double-space typos
/// flagged by audit are normalized to a single space per the PO open
/// question; the literal "Asther Lee" / "[Baby Name]" placeholder is
/// interpolated with the baby's first name.
const List<_ReadinessStep> _steps = [
  // Q1 — pediatrician gate.
  _ReadinessStep(
    title: 'Is {name} ready for solids?',
    body:
        'Most babies are ready around 6 months, but every child is '
        "different. Let's check key signs of readiness",
    yesLabel: 'Yes, our pediatrician approved it.',
    noLabel: "I'm not sure yet",
  ),
  // Q2 — head/neck control.
  _ReadinessStep(
    title: 'Can {name} hold their head steady?',
    body: 'Good head and neck control (can hold head steady)',
    yesLabel: 'Yes!',
    noLabel: 'Still figuring it out',
  ),
  // Q3 — sitting.
  _ReadinessStep(
    title: 'Can {name} sit upright with minimal support?',
    body: 'Sits upright with minimal support',
    yesLabel: 'Yes!',
    noLabel: 'Still figuring it out',
  ),
  // Q4 — tongue-thrust reflex.
  _ReadinessStep(
    title:
        'Does {name} no longer automatically push food out with their tongue?',
    body:
        "Loss of the tongue-thrust reflex (doesn't automatically push food "
        'out).',
    yesLabel: 'Yes!',
    noLabel: 'Still figuring it out',
  ),
  // Q5 — food interest.
  _ReadinessStep(
    title: 'Does {name} show interest in food?',
    body: 'Shows interest in food (watching, reaching, opening mouth).',
    yesLabel: 'Yes!',
    noLabel: 'Still figuring it out',
  ),
  // Q6 — hand-to-mouth.
  _ReadinessStep(
    title: 'Can {name} bring objects to their mouth?',
    body: 'Can bring objects to their mouth.',
    yesLabel: 'Yes!',
    noLabel: 'Still figuring it out',
  ),
];

/// NIB-83 — 6-screen readiness questionnaire with color-progressing bar.
///
/// Q1 captures pediatrician approval on `OnboardingState.pediatricianApproved`
/// (separate gate field). Q2-Q6 capture the 5 developmental signs on
/// `readinessAnswers[0..4]` — this is what the result screen
/// (NIB-91 / NIB-120) counts for the 3/5 majority gate. Splitting Q1 out
/// keeps the downstream score math unchanged.
///
/// Each step renders title + body + two answer cards. Tapping a card stores
/// the answer on the hoisted [OnboardingController] (keepAlive — back-nav
/// preserves state) and arms the bottom `Next` CTA. Next advances; on the
/// last step we set the readiness-done local flag and navigate to
/// `/onboarding/result`. Back inside the stepper rewinds one question;
/// back from Q1 pops the route.
class OnboardingReadinessScreen extends ConsumerStatefulWidget {
  const OnboardingReadinessScreen({super.key});

  @override
  ConsumerState<OnboardingReadinessScreen> createState() =>
      _OnboardingReadinessScreenState();
}

class _OnboardingReadinessScreenState
    extends ConsumerState<OnboardingReadinessScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Defensive: keep the stepper and the seeded answer list in lock-step
    // with the readiness-signs count.
    assert(
      _steps.length == _readinessTotalSteps,
      'Readiness step count drifted from Q1 gate + readinessQuestionCount',
    );

    final pediatricianApproved = ref.watch(
      onboardingControllerProvider.select((s) => s.pediatricianApproved),
    );
    final signAnswers = ref.watch(
      onboardingControllerProvider.select((s) => s.readinessAnswers),
    );
    final babyNameRaw = ref.watch(
      onboardingControllerProvider.select((s) => s.babyName.value),
    );
    final textTheme = Theme.of(context).textTheme;

    final step = _steps[_currentIndex];
    final firstName = _firstToken(babyNameRaw);
    final title = step.title.replaceAll('{name}', firstName);
    final currentAnswer = _answerForIndex(
      _currentIndex,
      pediatricianApproved: pediatricianApproved,
      signAnswers: signAnswers,
    );
    final isNextEnabled = currentAnswer != null;

    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scroll the question content so short devices / large text
              // scales never overflow; the Back/Next footer stays pinned to
              // the bottom (mirrors the result + consent siblings).
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSizes.md),
                      Semantics(
                        liveRegion: true,
                        container: true,
                        label:
                            'Question ${_currentIndex + 1} of '
                            '$_readinessTotalSteps',
                        child: Center(
                          child: AnimatedSwitcher(
                            key: const Key('onboarding_readiness_counter'),
                            duration: AppDurations.base,
                            switchInCurve: AppCurves.standard,
                            switchOutCurve: AppCurves.standard,
                            child: Text(
                              '${_currentIndex + 1} of '
                              '$_readinessTotalSteps Questions',
                              key: ValueKey<int>(_currentIndex),
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.fgStrong,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      ReadinessProgressBar(
                        stepCount: _readinessTotalSteps,
                        currentIndex: _currentIndex,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      AnimatedSwitcher(
                        duration: AppDurations.slide,
                        switchInCurve: AppCurves.emphasized,
                        switchOutCurve: AppCurves.standard,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0.06, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        layoutBuilder: (currentChild, previousChildren) =>
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            ),
                        child: Column(
                          key: ValueKey<int>(_currentIndex),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              step.body,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.fgMuted,
                              ),
                            ),
                            const SizedBox(height: AppSizes.lg),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ReadinessChoiceCard(
                                    key: const Key('readiness_choice_yes'),
                                    identifier: 'readiness_choice_yes',
                                    label: step.yesLabel,
                                    selected: currentAnswer ?? false,
                                    affirmative: true,
                                    onTap: () => _recordAnswer(isYes: true),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.md),
                                Expanded(
                                  child: ReadinessChoiceCard(
                                    key: const Key('readiness_choice_unsure'),
                                    identifier: 'readiness_choice_unsure',
                                    label: step.noLabel,
                                    selected: currentAnswer == false,
                                    affirmative: false,
                                    onTap: () => _recordAnswer(isYes: false),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.pagePaddingV),
                child: Row(
                  children: [
                    AppRoundButton(
                      key: const Key('onboarding_readiness_back'),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tone: AppRoundButtonTone.butter,
                      semanticLabel: 'Back',
                      onPressed: _onBack,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: AppPillButton(
                        key: const Key('onboarding_readiness_next'),
                        label: 'Next',
                        onPressed: isNextEnabled ? _onNext : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// First whitespace-separated token of [raw], or "your baby" fallback when
  /// the name has not been captured yet. Prevents dangling possessives.
  String _firstToken(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'your baby';
    final idx = trimmed.indexOf(' ');
    return idx < 0 ? trimmed : trimmed.substring(0, idx);
  }

  /// Reads the currently-stored answer for [index] from the right slot:
  /// index 0 = pediatricianApproved, index 1..5 = readinessAnswers[0..4].
  bool? _answerForIndex(
    int index, {
    required bool? pediatricianApproved,
    required List<bool?> signAnswers,
  }) {
    if (index == 0) return pediatricianApproved;
    final signIndex = index - 1;
    if (signIndex < 0 || signIndex >= signAnswers.length) return null;
    return signAnswers[signIndex];
  }

  /// Stores the answer on the controller. Step 0 hits the pediatrician gate
  /// field; steps 1..5 write into readinessAnswers[index-1]. Selection alone
  /// does not auto-advance — Next handles navigation.
  void _recordAnswer({required bool isYes}) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    if (_currentIndex == 0) {
      controller.setPediatricianApproved(approved: isYes);
      return;
    }
    controller.answerReadinessQuestion(_currentIndex - 1, isYes: isYes);
  }

  void _onBack() {
    if (_currentIndex == 0) {
      // Flow order is name -> dob -> readiness, so back from Q1 returns to the
      // DOB ("baby born") screen. readiness is reached via `goNamed`, so the
      // stack usually can't pop — fall through to `goNamed(dob)`.
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(AppRoute.onboardingDob.name);
      }
      return;
    }
    setState(() => _currentIndex--);
  }

  void _onNext() {
    if (_currentIndex < _steps.length - 1) {
      setState(() => _currentIndex++);
      return;
    }
    _finish();
  }

  void _finish() {
    // Delegate flag write + state update to controller so the local flag is
    // flipped before GoRouter's redirect reads it — avoids the fire-and-forget
    // race that existed when the flag was written from the Screen layer.
    ref.read(onboardingControllerProvider.notifier).completeReadiness();
    // Push (not go) so the result keeps readiness on the stack — back from the
    // result is a plain pop that returns to the last question with answers
    // intact. Phase C whitelists readiness so the pop isn't redirect-bounced.
    context.pushNamed(AppRoute.onboardingResult.name);
  }
}

class _ReadinessStep {
  const _ReadinessStep({
    required this.title,
    required this.body,
    required this.yesLabel,
    required this.noLabel,
  });

  final String title;
  final String body;
  final String yesLabel;
  final String noLabel;
}
