import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';
import 'package:nibbles/src/utils/age_in_months.dart';

/// OB DOB capture — Figma 971:10173 (.figma-audit/onboarding/baby-birthdate).
///
/// Layout matches the Figma composition exactly:
///   - title `When was [firstName] born?` (first name in coral via TextSpan)
///   - body subtitle ("We use this to suggest the right foods…")
///   - quatrefoil illustration cluster + salmonGhost "X Month" age chip
///   - 3-column wheel (Year / Month / Day) with lime selection pill per column
///   - bottom row: lime back round button + forestDarkn "Next" pill
///
/// State written to the hoisted [OnboardingController] via `updateDob`. Then
/// the phase-A flag `onboarding_baby_setup_done` is flipped — the router's
/// phase-A whitelist (routes.dart) only contains `{name, dob}` while this flag
/// is false, so without the flip a `goNamed(readiness)` immediately bounces
/// back to `/onboarding/name`. This flag flip is load-bearing — do not drop.
///
/// Default DOB is 6 months ago (calendar-aware, clamped to today), so the
/// initial age chip reads "6 Months" out of the box per the AC.
class OnboardingDobScreen extends ConsumerStatefulWidget {
  const OnboardingDobScreen({super.key});

  @override
  ConsumerState<OnboardingDobScreen> createState() =>
      _OnboardingDobScreenState();
}

class _OnboardingDobScreenState extends ConsumerState<OnboardingDobScreen> {
  static const int _maxAgeYears = 3;
  static const double _wheelHeight = 156;
  static const double _wheelItemExtent = 44;

  // 3-letter month abbreviations. The Figma render mixes 'Feb'/'Apr' (3-letter)
  // with 'March' (full) — we normalize to 3-letter uniformly. Noted in PR.
  static const List<String> _monthAbbr = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late final DateTime _today;
  late final int _minYear;
  late final int _maxYear;

  late int _year;
  late int _month; // 1..12
  late int _day; // 1..31 (clamped to month length)

  late FixedExtentScrollController _yearCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _dayCtrl;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _maxYear = _today.year;
    _minYear = _today.year - _maxAgeYears;

    final stored = ref.read(onboardingControllerProvider).dob;
    final initial = stored ?? _defaultDob(_today);
    _year = initial.year;
    _month = initial.month;
    _day = initial.day;

    _yearCtrl = FixedExtentScrollController(initialItem: _year - _minYear);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  /// Calendar-aware "6 months ago" — drops calendar months, clamped to today.
  static DateTime _defaultDob(DateTime today) {
    var year = today.year;
    var month = today.month - 6;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }
    final day = _clampDay(year, month, today.day);
    return DateTime(year, month, day);
  }

  static int _daysInMonth(int year, int month) {
    // First of next month, minus 1 day. Handles leap years.
    final firstNext = month == 12
        ? DateTime(year + 1)
        : DateTime(year, month + 1);
    return firstNext.subtract(const Duration(days: 1)).day;
  }

  static int _clampDay(int year, int month, int day) {
    final max = _daysInMonth(year, month);
    return day > max ? max : (day < 1 ? 1 : day);
  }

  /// Selected DOB clamped to today's date (no future selection).
  DateTime get _selected {
    final picked = DateTime(_year, _month, _clampDay(_year, _month, _day));
    return picked.isAfter(_today) ? _today : picked;
  }

  String _firstNameOrFallback(String stored) {
    final trimmed = stored.trim();
    if (trimmed.isEmpty) return 'your baby';
    return trimmed.split(' ').first;
  }

  String _ageLabel(DateTime date) {
    final months = ageInMonths(date, now: _today);
    if (months <= 0) return 'Less than a month';
    if (months == 1) return '1 Month';
    return '$months Months';
  }

  void _onYearChanged(int index) {
    final next = _minYear + index;
    setState(() {
      _year = next;
      // Re-clamp day if month-length changes (Feb 29 → Feb 28 across years).
      _day = _clampDay(_year, _month, _day);
      _clampToToday();
    });
  }

  void _onMonthChanged(int index) {
    final next = index + 1;
    setState(() {
      _month = next;
      _day = _clampDay(_year, _month, _day);
      _clampToToday();
    });
  }

  void _onDayChanged(int index) {
    setState(() {
      _day = index + 1;
      _clampToToday();
    });
  }

  /// If wheels combine to land past today, snap each wheel back to today.
  /// Wheel jumps are deferred to the next frame to avoid re-entering the
  /// `onSelectedItemChanged` callback that triggered this clamp.
  void _clampToToday() {
    final picked = DateTime(_year, _month, _clampDay(_year, _month, _day));
    if (!picked.isAfter(_today)) return;
    _year = _today.year;
    _month = _today.month;
    _day = _today.day;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _yearCtrl.jumpToItem(_year - _minYear);
      _monthCtrl.jumpToItem(_month - 1);
      _dayCtrl.jumpToItem(_day - 1);
    });
  }

  void _onNext() {
    ref.read(onboardingControllerProvider.notifier).updateDob(_selected);
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

    final years = List<int>.generate(
      _maxYear - _minYear + 1,
      (i) => _minYear + i,
    );
    final days = List<int>.generate(_daysInMonth(_year, _month), (i) => i + 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      // Grad-1 background — linear-gradient(~154.4deg, #FFFCD5 19.168%,
      // #F5F5F5 50%). Same pattern as profile/starting-guide screens.
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.460, -0.888),
            end: Alignment(0.460, 0.888),
            stops: [0.19168, 0.5],
            colors: [AppColors.butterSoft, Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.pagePaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: textTheme.titleLarge,
                      children: [
                        const TextSpan(text: 'When was '),
                        TextSpan(
                          text: firstName,
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.coral,
                          ),
                        ),
                        const TextSpan(text: ' born?'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'We use this to suggest the right foods at the right time.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xl),
                const Center(child: Quatrefoil()),
                const SizedBox(height: AppSizes.md),
                Center(
                  child: _AgeChip(
                    key: const Key('onboarding_dob_age_label'),
                    label: _ageLabel(_selected),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                _DateWheelRow(
                  yearCtrl: _yearCtrl,
                  monthCtrl: _monthCtrl,
                  dayCtrl: _dayCtrl,
                  years: years,
                  months: _monthAbbr,
                  days: days,
                  selectedYearIndex: _year - _minYear,
                  selectedMonthIndex: _month - 1,
                  selectedDayIndex: _day - 1,
                  wheelHeight: _wheelHeight,
                  itemExtent: _wheelItemExtent,
                  onYearChanged: _onYearChanged,
                  onMonthChanged: _onMonthChanged,
                  onDayChanged: _onDayChanged,
                ),
                const Spacer(),
                Row(
                  children: [
                    AppRoundButton(
                      key: const Key('onboarding_dob_back'),
                      tone: AppRoundButtonTone.lime,
                      icon: const Icon(Icons.arrow_back_rounded),
                      semanticLabel: 'Back',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.goNamed(AppRoute.onboardingName.name);
                        }
                      },
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: AppPillButton(
                        key: const Key('onboarding_dob_next'),
                        label: 'Next',
                        onPressed: _onNext,
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
}

/// Salmon-ghost age preview chip. Mirrors Figma "6 Month" pill.
class _AgeChip extends StatelessWidget {
  const _AgeChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.bodyBold.copyWith(color: AppColors.coralDeep),
      ),
    );
  }
}

/// The 3-column Year/Month/Day wheel row with column headers and per-column
/// lime selection pills. Composes three [_DateWheelColumn]s.
class _DateWheelRow extends StatelessWidget {
  const _DateWheelRow({
    required this.yearCtrl,
    required this.monthCtrl,
    required this.dayCtrl,
    required this.years,
    required this.months,
    required this.days,
    required this.selectedYearIndex,
    required this.selectedMonthIndex,
    required this.selectedDayIndex,
    required this.wheelHeight,
    required this.itemExtent,
    required this.onYearChanged,
    required this.onMonthChanged,
    required this.onDayChanged,
  });

  final FixedExtentScrollController yearCtrl;
  final FixedExtentScrollController monthCtrl;
  final FixedExtentScrollController dayCtrl;
  final List<int> years;
  final List<String> months;
  final List<int> days;
  final int selectedYearIndex;
  final int selectedMonthIndex;
  final int selectedDayIndex;
  final double wheelHeight;
  final double itemExtent;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onDayChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateWheelColumn(
            key: const Key('onboarding_dob_year_wheel'),
            header: 'Year',
            height: wheelHeight,
            itemExtent: itemExtent,
            controller: yearCtrl,
            itemCount: years.length,
            selectedIndex: selectedYearIndex,
            onSelectedItemChanged: onYearChanged,
            itemBuilder: (i) => '${years[i]}',
          ),
        ),
        Expanded(
          child: _DateWheelColumn(
            key: const Key('onboarding_dob_month_wheel'),
            header: 'Month',
            height: wheelHeight,
            itemExtent: itemExtent,
            controller: monthCtrl,
            itemCount: months.length,
            selectedIndex: selectedMonthIndex,
            onSelectedItemChanged: onMonthChanged,
            itemBuilder: (i) => months[i],
          ),
        ),
        Expanded(
          child: _DateWheelColumn(
            key: const Key('onboarding_dob_day_wheel'),
            header: 'Date',
            height: wheelHeight,
            itemExtent: itemExtent,
            controller: dayCtrl,
            itemCount: days.length,
            selectedIndex: selectedDayIndex,
            onSelectedItemChanged: onDayChanged,
            itemBuilder: (i) => '${days[i]}',
          ),
        ),
      ],
    );
  }
}

/// A single column: header label + CupertinoPicker with a lime rounded pill
/// `selectionOverlay`. Selected row text rendered in forestDarkn; off-rows in
/// muted neutral per the Figma render.
class _DateWheelColumn extends StatelessWidget {
  const _DateWheelColumn({
    required this.header,
    required this.height,
    required this.itemExtent,
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.onSelectedItemChanged,
    required this.itemBuilder,
    super.key,
  });

  final String header;
  final double height;
  final double itemExtent;
  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onSelectedItemChanged;
  final String Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          header,
          style: textTheme.labelMedium?.copyWith(color: AppColors.fgFaint),
        ),
        const SizedBox(height: AppSizes.sm),
        SizedBox(
          height: height,
          child: CupertinoPicker(
            scrollController: controller,
            itemExtent: itemExtent,
            squeeze: 1.1,
            backgroundColor: Colors.transparent,
            selectionOverlay: Center(
              child: Container(
                width: 70,
                height: AppSizes.chipHeight,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
            ),
            onSelectedItemChanged: onSelectedItemChanged,
            children: List<Widget>.generate(itemCount, (i) {
              final isSelected = i == selectedIndex;
              return Center(
                child: Text(
                  itemBuilder(i),
                  style: textTheme.labelMedium?.copyWith(
                    color: isSelected ? AppColors.greenDeep : AppColors.fgFaint,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
