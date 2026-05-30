import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/features/onboarding/onboarding_state.dart';
import 'package:nibbles/src/features/onboarding/readiness/widgets/readiness_choice_card.dart';
import 'package:nibbles/src/features/onboarding/readiness/widgets/readiness_progress_bar.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Single-question copy for each of the 5 developmental signs. Index aligns
/// with `readinessAnswers` on [OnboardingState].
///
/// `{name}` is interpolated at build with the first token of
/// `state.babyName.value` (falls back to "your baby" when empty so we never
/// render a dangling possessive apostrophe).
const List<_ReadinessQuestion> _questions = [
  _ReadinessQuestion(
    title: 'Can {name} hold their head steady?',
    icon: Icons.face_retouching_natural,
  ),
  _ReadinessQuestion(
    title: 'Can {name} sit upright with minimal support?',
    icon: Icons.airline_seat_recline_extra_rounded,
  ),
  _ReadinessQuestion(
    title: "Has {name}'s tongue-thrust reflex gone?",
    icon: Icons.emoji_emotions_outlined,
  ),
  _ReadinessQuestion(
    title: 'Does {name} show interest in food?',
    icon: Icons.restaurant_rounded,
  ),
  _ReadinessQuestion(
    title: 'Can {name} bring objects to their mouth?',
    icon: Icons.front_hand_outlined,
  ),
];

/// NIB-83 — Readiness questionnaire rebuilt as a 5-step stepper.
///
/// Each step renders one developmental-sign question + two large square cards
/// ('Yes!' / 'Still figuring it out'). Tapping a card records the answer on
/// the hoisted [OnboardingController] (keepAlive — back-nav preserves state)
/// and auto-advances. After step 4 we set the readiness-done local flag and
/// navigate to `/onboarding/result`.
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
    // Defensive: the screen depends on a fixed-length answer list. The state
    // default seeds 5 nulls (matches `readinessQuestionCount`) — assert in
    // debug so a future spec change in either place fails loudly.
    assert(
      _questions.length == readinessQuestionCount,
      'Readiness question count drifted from OnboardingState seed',
    );

    final answers = ref.watch(
      onboardingControllerProvider.select((s) => s.readinessAnswers),
    );
    final babyNameRaw = ref.watch(
      onboardingControllerProvider.select((s) => s.babyName.value),
    );
    final textTheme = Theme.of(context).textTheme;

    final question = _questions[_currentIndex];
    final currentAnswer = answers[_currentIndex];
    final firstName = _firstToken(babyNameRaw);
    final title = question.title.replaceAll('{name}', firstName);

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
              onPressed: _onBack,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReadinessProgressBar(
                stepCount: _questions.length,
                currentIndex: _currentIndex,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                '${_currentIndex + 1} of ${_questions.length} Questions',
                style: textTheme.bodySmall?.copyWith(color: AppColors.fgMuted),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(title, style: textTheme.displaySmall),
              const SizedBox(height: AppSizes.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ReadinessChoiceCard(
                      key: const Key('readiness_choice_yes'),
                      label: 'Yes!',
                      icon: Icons.check_rounded,
                      selected: currentAnswer ?? false,
                      onTap: () => _onAnswer(isYes: true),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: ReadinessChoiceCard(
                      key: const Key('readiness_choice_unsure'),
                      label: 'Still figuring it out',
                      icon: Icons.help_outline_rounded,
                      selected: !(currentAnswer ?? true),
                      onTap: () => _onAnswer(isYes: false),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(height: AppSizes.pagePaddingV),
            ],
          ),
        ),
      ),
    );
  }

  /// First whitespace-separated token of [raw], or "your baby" fallback when
  /// the name has not been captured yet. Prevents dangling possessives like
  /// "'s tongue-thrust reflex".
  String _firstToken(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'your baby';
    final idx = trimmed.indexOf(' ');
    return idx < 0 ? trimmed : trimmed.substring(0, idx);
  }

  void _onBack() {
    if (_currentIndex == 0) {
      // Pre-MVP: name -> dob -> readiness, so back must always pop to dob.
      if (context.canPop()) {
        context.pop();
      }
      return;
    }
    setState(() => _currentIndex--);
  }

  void _onAnswer({required bool isYes}) {
    ref
        .read(onboardingControllerProvider.notifier)
        .answerReadinessQuestion(_currentIndex, isYes: isYes);

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
      return;
    }
    _finish();
  }

  void _finish() {
    final controller = ref.read(onboardingControllerProvider.notifier);
    // signs_met derivation: ready iff every answer is `true`. Stored on state
    // so downstream screens (result/consent) can branch on it without
    // recounting nullable bools.
    final answers = ref.read(onboardingControllerProvider).readinessAnswers;
    final allMet = answers.every((a) => a ?? false);
    controller.setReadinessReady(ready: allMet);
    // CRITICAL: GoRouter redirect bounces back to /onboarding/readiness while
    // this flag is false. Dropping this call creates a silent redirect loop.
    ref.read(localFlagServiceProvider).setOnboardingReadinessDone();
    context.goNamed(AppRoute.onboardingResult.name);
  }
}

class _ReadinessQuestion {
  const _ReadinessQuestion({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
