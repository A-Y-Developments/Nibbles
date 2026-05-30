import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/formz/baby_name_input.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// OB name capture (Figma 971:10266 default / 971:10279 error / 1025:7285
/// filled). Per NIB-120 the DATA is a SINGLE `name` column — the UI shows
/// two fields but writes the concatenated `'First Last'.trim()` string to
/// the hoisted [OnboardingController]. State persists across back-nav by
/// reading `state.babyName.value` on init and splitting on the LAST space
/// for a simple round-trip.
class OnboardingNameScreen extends ConsumerStatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  ConsumerState<OnboardingNameScreen> createState() =>
      _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends ConsumerState<OnboardingNameScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  bool _firstDirty = false;

  @override
  void initState() {
    super.initState();
    final stored = ref.read(onboardingControllerProvider).babyName.value;
    final (first, last) = _splitStored(stored);
    _firstNameController = TextEditingController(text: first);
    _lastNameController = TextEditingController(text: last);
    // If we re-entered with a previously-valid name, treat first as already
    // dirty so the Next CTA matches the visible filled state.
    _firstDirty = first.trim().isNotEmpty;
  }

  /// Splits the persisted single name on the LAST space — simple round-trip
  /// that matches how the screen joins on write. A single token populates
  /// First only.
  (String first, String last) _splitStored(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return ('', '');
    final idx = trimmed.lastIndexOf(' ');
    if (idx < 0) return (trimmed, '');
    final first = trimmed.substring(0, idx).trim();
    final last = trimmed.substring(idx + 1).trim();
    return (first, last);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String get _firstTrimmed => _firstNameController.text.trim();
  String get _lastTrimmed => _lastNameController.text.trim();

  bool get _firstNameValid =>
      const BabyNameInput.dirty().validator(_firstTrimmed) == null;

  // Last name optional, but if filled must respect the same <=50 cap.
  bool get _lastNameValid => _lastTrimmed.length <= 50;

  bool get _canSubmit => _firstNameValid && _lastNameValid;

  String? get _firstErrorText {
    if (!_firstDirty) return null;
    if (_firstNameValid) return null;
    return 'You must fill the name';
  }

  void _onFirstChanged(String _) {
    setState(() => _firstDirty = true);
  }

  void _onLastChanged(String _) {
    setState(() {});
  }

  void _onNext() {
    if (!_canSubmit) return;
    final first = _firstTrimmed;
    final last = _lastTrimmed;
    final joined = last.isEmpty ? first : '$first $last';
    ref.read(onboardingControllerProvider.notifier).updateName(joined);
    context.goNamed(AppRoute.onboardingDob.name);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final errorText = _firstErrorText;
    final canPop = Navigator.of(context).canPop();

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
              const SizedBox(height: AppSizes.xxl),
              Text(
                "What is your baby's name?",
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                "We'll use this to build their personalized 3-6 month guide.",
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.fgStrong,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xl),
              AppTextField(
                key: const Key('onboarding_first_name_field'),
                label: 'First Name',
                hintText: "Baby's First Name",
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                onChanged: _onFirstChanged,
                errorText: errorText,
                // Figma state-2 token: Nibble-primary-Burgundy ≈ destructive.
                errorColor: AppColors.destructive,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                key: const Key('onboarding_last_name_field'),
                label: 'Last Name (Optional)',
                hintText: "Baby's Last Name",
                controller: _lastNameController,
                textInputAction: TextInputAction.done,
                onChanged: _onLastChanged,
                onSubmitted: (_) => _onNext(),
              ),
              const Spacer(),
              Row(
                children: [
                  if (canPop) ...[
                    AppRoundButton(
                      key: const Key('onboarding_name_back'),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tone: AppRoundButtonTone.butter,
                      semanticLabel: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppSizes.sm),
                  ],
                  Expanded(
                    child: AppPillButton(
                      key: const Key('onboarding_name_next'),
                      label: 'Next',
                      onPressed: _canSubmit ? _onNext : null,
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
}
