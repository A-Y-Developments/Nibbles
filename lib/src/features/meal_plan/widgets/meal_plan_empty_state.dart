import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/widgets/inline_calendar.dart';

/// Meal Plan empty-state form. Renders a flower (Quatrefoil) illustration,
/// a "Ready to start?" heading, two date fields (Start Date / End Date) and
/// a "Create meal plan" CTA. Tapping a date field opens [InlineCalendar]
/// below the field — the OS picker is never used.
///
/// State is local: which field is focused, the chosen start + end dates,
/// and which inline calendar is currently expanded. When the CTA fires
/// with a valid range (`start <= end`), [onCreateMealPlan] receives a
/// [DateTimeRange].
class MealPlanEmptyState extends StatefulWidget {
  const MealPlanEmptyState({
    required this.babyName,
    required this.onCreateMealPlan,
    super.key,
  });

  final String babyName;
  final ValueChanged<DateTimeRange> onCreateMealPlan;

  @override
  State<MealPlanEmptyState> createState() => _MealPlanEmptyStateState();
}

enum _OpenField { none, start, end }

class _MealPlanEmptyStateState extends State<MealPlanEmptyState> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _focusedMonth;
  _OpenField _openField = _OpenField.none;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  bool get _canSubmit =>
      _startDate != null &&
      _endDate != null &&
      !_endDate!.isBefore(_startDate!);

  String? get _rangeError {
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      return 'End date must be on or after start date.';
    }
    return null;
  }

  void _toggleField(_OpenField field, DateTime? current) {
    setState(() {
      if (_openField == field) {
        _openField = _OpenField.none;
      } else {
        _openField = field;
        final anchor = current ?? _startDate ?? DateTime.now();
        _focusedMonth = DateTime(anchor.year, anchor.month);
      }
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_openField == _OpenField.start) {
        _startDate = day;
        // Clear an end date that would now be invalid.
        if (_endDate != null && _endDate!.isBefore(day)) {
          _endDate = null;
        }
      } else if (_openField == _OpenField.end) {
        _endDate = day;
      }
      _openField = _OpenField.none;
    });
  }

  void _onMonthChanged(DateTime month) {
    setState(() => _focusedMonth = month);
  }

  void _onSubmit() {
    if (!_canSubmit) return;
    widget.onCreateMealPlan(
      DateTimeRange(start: _startDate!, end: _endDate!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rangeError = _rangeError;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.pagePaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.lg),
            // TODO(NIB-69): swap stock Quatrefoil for the dedicated meal-plan
            // flower illustration if/when Figma exports one.
            const Center(child: Quatrefoil()),
            const SizedBox(height: AppSizes.md),
            Text(
              'Ready to start?',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              "Pick a start and end date to plan ${widget.babyName}'s meals.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.fgMuted,
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            _DateField(
              label: 'Start Date',
              value: _startDate,
              hintText: 'Select start date',
              isOpen: _openField == _OpenField.start,
              onTap: () => _toggleField(_OpenField.start, _startDate),
            ),
            if (_openField == _OpenField.start) ...[
              const SizedBox(height: AppSizes.sm),
              InlineCalendar(
                selectedDate: _startDate,
                focusedMonth: _focusedMonth,
                onDaySelected: _onDaySelected,
                onMonthChanged: _onMonthChanged,
              ),
            ],
            const SizedBox(height: AppSizes.md),
            _DateField(
              label: 'End Date',
              value: _endDate,
              hintText: 'Select end date',
              isOpen: _openField == _OpenField.end,
              onTap: () => _toggleField(_OpenField.end, _endDate),
            ),
            if (_openField == _OpenField.end) ...[
              const SizedBox(height: AppSizes.sm),
              InlineCalendar(
                selectedDate: _endDate,
                focusedMonth: _focusedMonth,
                onDaySelected: _onDaySelected,
                onMonthChanged: _onMonthChanged,
                minDate: _startDate,
              ),
            ],
            if (rangeError != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                rangeError,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSizes.xl),
            AppPillButton(
              label: 'Create meal plan',
              onPressed: _canSubmit ? _onSubmit : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.hintText,
    required this.isOpen,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final String hintText;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;
    final displayText = hasValue ? _formatDate(value!) : hintText;
    final borderColor = isOpen ? AppColors.greenDeep : AppColors.borderSoft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.fgStrong,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: AppSizes.fieldHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md - 2,
            ),
            decoration: BoxDecoration(
              color: isOpen ? AppColors.surface : AppColors.bgInput,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: borderColor,
                width: isOpen ? 2 : 1,
              ),
              boxShadow: isOpen
                  ? [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.18),
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: hasValue
                          ? AppColors.fgStrong
                          : AppColors.greenSoft,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: AppSizes.iconSm,
                  color: AppColors.greenDeep,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const List<String> _weekdayShort = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _monthShort = <String>[
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

  String _formatDate(DateTime d) {
    final dow = _weekdayShort[d.weekday - 1];
    final mon = _monthShort[d.month - 1];
    return '$dow, ${d.day} $mon ${d.year}';
  }
}
