import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/onboarding/readiness/readiness_controller.dart';
import 'package:nibbles/src/features/onboarding/readiness/widgets/readiness_question_card.dart';
import 'package:nibbles/src/features/onboarding/readiness/widgets/readiness_warning.dart';
import 'package:nibbles/src/routing/route_enums.dart';

const _questions = [
  'Has your paediatrician given the go-ahead?',
  'Can your baby hold their head steady?',
  'Can your baby sit upright with minimal support?',
  'Has the tongue-thrust reflex gone?',
  'Does your baby show interest in food?',
  'Can your baby bring objects to their mouth?',
];

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
    final readinessState = ref.watch(readinessControllerProvider);
    final controller = ref.read(readinessControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    if (readinessState.showWarning) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              controller.goBack();
              setState(() => _currentIndex = _questions.length - 1);
            },
          ),
          title: Text('One more thing', style: textTheme.titleMedium),
        ),
        body: ReadinessWarning(
          onGoBack: () {
            controller.goBack();
            setState(() => _currentIndex = _questions.length - 1);
          },
          onContinue: () => context.goNamed(AppRoute.register.name),
        ),
      );
    }

    final currentAnswer = readinessState.answers[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _currentIndex--),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(_questions.length, (i) {
                final filled = i <= _currentIndex;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: i < _questions.length - 1 ? 4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color:
                          filled ? AppColors.primary : AppColors.divider,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusFull),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              '${_currentIndex + 1} of ${_questions.length}',
              style:
                  textTheme.bodySmall?.copyWith(color: AppColors.subtext),
            ),
            const SizedBox(height: AppSizes.xxl),
            Text(
              _questions[_currentIndex],
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            ReadinessQuestionCard(
              label: 'Yes',
              selected: currentAnswer ?? false,
              onTap: () =>
                  controller.answer(_currentIndex, isYes: true),
            ),
            const SizedBox(height: AppSizes.md),
            ReadinessQuestionCard(
              label: "I'm not sure",
              selected: !(currentAnswer ?? true),
              onTap: () =>
                  controller.answer(_currentIndex, isYes: false),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: currentAnswer == null
                    ? null
                    : () => _onNext(controller),
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Next'
                      : 'See Results',
                ),
              ),
            ),
            const SizedBox(height: AppSizes.pagePaddingV),
          ],
        ),
      ),
    );
  }

  void _onNext(ReadinessController controller) {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      controller.finish();
      final updatedState = ref.read(readinessControllerProvider);
      if (!updatedState.showWarning) {
        context.goNamed(AppRoute.register.name);
      }
    }
  }
}
