import 'package:flutter/cupertino.dart';
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

/// OB DOB capture (Figma 971:10173). Reskin of NIB-51's stub.
///
/// Composition (top → bottom):
///   - butter quatrefoil illustration
///   - title `When was [babyName.first] born?`
///   - coral live age label (recomputed via [ageInMonths] on every wheel tick)
///   - 3-wheel `CupertinoDatePicker` (date mode); bounds: today − 3y → today
///   - primary `AppPillButton` "Next" — disabled until the wheel actually moves
///
/// State written to the hoisted [OnboardingController] via `updateDob`. Then
/// the phase-A flag `onboarding_baby_setup_done` is flipped — the router's
/// phase-A whitelist (routes.dart) only contains `{name, dob}` while this
/// flag is false, so without the flip a `goNamed(readiness)` immediately
/// bounces back to `/onboarding/name`.
class OnboardingDobScreen extends ConsumerStatefulWidget {
  const OnboardingDobScreen({super.key});

  @override
  ConsumerState<OnboardingDobScreen> createState() =>
      _OnboardingDobScreenState();
}

class _OnboardingDobScreenState extends ConsumerState<OnboardingDobScreen> {
  // CupertinoDatePicker always renders SOME date. We track an explicit
  // "user touched the wheel" via [_selected]: null until the first
  // [onDateTimeChanged] callback. Next stays disabled while null and the
  // label reads from [_initialDate] for the first paint.
  static const Duration _defaultOffset = Duration(days: 180);
  static const int _maxAgeYears = 3;
  static const double _pickerHeight = 200;

  late final DateTime _today;
  late final DateTime _initialDate;
  late final DateTime _minimumDate;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _initialDate = ref.read(onboardingControllerProvider).dob ??
        _today.subtract(_defaultOffset);
    _minimumDate = DateTime(now.year - _maxAgeYears, now.month, now.day);
    // If the controller already had a DOB (back-nav), treat as selected so
    // Next is enabled on re-entry — the visible wheel matches the stored value.
    if (ref.read(onboardingControllerProvider).dob != null) {
      _selected = _initialDate;
    }
  }

  String _firstNameOrFallback(String stored) {
    final trimmed = stored.trim();
    if (trimmed.isEmpty) return 'your baby';
    return trimmed.split(' ').first;
  }

  String _ageLabel(DateTime date) {
    final months = ageInMonths(date, now: _today);
    if (months <= 0) return 'Less than a month old';
    if (months == 1) return '1 month old';
    return '$months months old';
  }

  void _onDateChanged(DateTime value) {
    setState(() => _selected = value);
  }

  void _onNext() {
    final picked = _selected;
    if (picked == null) return;
    ref.read(onboardingControllerProvider.notifier).updateDob(picked);
    ref.read(localFlagServiceProvider).setOnboardingBabySetupDone();
    context.goNamed(AppRoute.onboardingReadiness.name);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final storedName = ref.watch(
      onboardingControllerProvider.select((s) => s.babyName.value),
    );
    final firstName = _firstNameOrFallback(storedName);
    final labelDate = _selected ?? _initialDate;
    final canSubmit = _selected != null;

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
                'When was $firstName born?',
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                key: const Key('onboarding_dob_age_label'),
                _ageLabel(labelDate),
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              SizedBox(
                height: _pickerHeight,
                child: CupertinoDatePicker(
                  key: const Key('onboarding_dob_picker'),
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _initialDate,
                  maximumDate: _today,
                  minimumDate: _minimumDate,
                  onDateTimeChanged: _onDateChanged,
                ),
              ),
              const Spacer(),
              AppPillButton(
                key: const Key('onboarding_dob_next'),
                label: 'Next',
                onPressed: canSubmit ? _onNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
