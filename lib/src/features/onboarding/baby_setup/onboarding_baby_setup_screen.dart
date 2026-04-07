import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/baby_setup/baby_setup_controller.dart';
import 'package:nibbles/src/features/onboarding/baby_setup/baby_setup_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class OnboardingBabySetupScreen extends ConsumerWidget {
  const OnboardingBabySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(babySetupControllerProvider);
    final controller = ref.read(babySetupControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: state.step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: controller.previousStep,
              )
            : null,
        title: Text(
          'Step ${state.step + 1} of 3',
          style: textTheme.bodySmall?.copyWith(color: AppColors.subtext),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.pagePaddingV,
          ),
          child: switch (state.step) {
            0 => _NameStep(state: state, controller: controller),
            1 => _DobStep(state: state, controller: controller),
            _ => _GenderStep(
              state: state,
              controller: controller,
              onSuccess: () {
                ref.read(localFlagServiceProvider).setOnboardingBabySetupDone();
                context.goNamed(AppRoute.home.name);
              },
            ),
          },
        ),
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.state, required this.controller});

  final BabySetupState state;
  final BabySetupController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.lg),
        Text("What's your baby's name?", style: textTheme.headlineLarge),
        const SizedBox(height: AppSizes.xl),
        TextField(
          key: const Key('baby_name_field'),
          onChanged: controller.updateName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: "Baby's name",
            errorText:
                state.babyName.isNotValid && state.babyName.value.isNotEmpty
                ? 'Please enter a valid name.'
                : null,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('baby_name_next'),
            onPressed: state.babyName.isValid ? controller.nextStep : null,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }
}

class _DobStep extends StatelessWidget {
  const _DobStep({required this.state, required this.controller});

  final BabySetupState state;
  final BabySetupController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = state.dob ?? today.subtract(const Duration(days: 180));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.lg),
        Text('When was your baby born?', style: textTheme.headlineLarge),
        const SizedBox(height: AppSizes.xl),
        SizedBox(
          height: 160,
          child: CupertinoDatePicker(
            key: const Key('baby_dob_picker'),
            mode: CupertinoDatePickerMode.date,
            initialDateTime: initialDate,
            maximumDate: today,
            minimumDate: DateTime(now.year - 3, now.month, now.day),
            onDateTimeChanged: controller.updateDob,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('baby_dob_next'),
            onPressed: state.dob != null ? controller.nextStep : null,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }
}

class _GenderStep extends StatelessWidget {
  const _GenderStep({
    required this.state,
    required this.controller,
    required this.onSuccess,
  });

  final BabySetupState state;
  final BabySetupController controller;
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.lg),
        Text("What's your baby's gender?", style: textTheme.headlineLarge),
        const SizedBox(height: AppSizes.xl),
        ...Gender.values.map(
          (g) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: _GenderCard(
              label: _genderLabel(g),
              selected: state.gender == g,
              onTap: () => controller.updateGender(g),
            ),
          ),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: AppSizes.sm),
          Text(
            state.errorMessage!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('baby_setup_submit'),
            onPressed: (state.gender == null || state.isLoading)
                ? null
                : () async {
                    final ok = await controller.submit();
                    if (ok && context.mounted) onSuccess();
                  },
            child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Text("Let's go!"),
          ),
        ),
      ],
    );
  }

  String _genderLabel(Gender g) => switch (g) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.preferNotToSay => 'Prefer not to say',
  };
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
