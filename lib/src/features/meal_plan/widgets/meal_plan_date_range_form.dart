import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/widgets/inline_calendar.dart';

/// Shared Start Date / End Date form used by both the Meal Plan empty-state
/// (`MealPlanEmptyState`) and the Select Period Date bottom-sheet
/// (`SelectPeriodDateSheet`, Figma 971:8000). Renders two date fields plus
/// a primary CTA. Tapping a field opens an [InlineCalendar] directly below
/// it — the OS picker is intentionally never used (per NIB-76 AC: the
/// typo'd Figma weekday row is not replicated and the picker is themed to
/// sage/butter, not iOS blue).
///
/// Defaults to today + (today + 6 days) so the CTA is enabled on first
/// paint. Dates render as `MMM d, yyyy` (e.g. `Apr 17, 2026`) to avoid
/// day/month ambiguity (NIB-166).
class MealPlanDateRangeForm extends StatefulWidget {
  const MealPlanDateRangeForm({
    required this.ctaLabel,
    required this.onSubmit,
    this.initialStart,
    this.initialEnd,
    super.key,
  });

  /// CTA label. Empty-state uses 'Create meal plan' (Figma 971:8199); the
  /// bottom-sheet variant (971:8000) uses 'Custom meal plan'.
  final String ctaLabel;

  /// Fires when the user taps the CTA with a valid range.
  final ValueChanged<DateTimeRange> onSubmit;

  /// Optional initial start date. Defaults to today (date-only).
  final DateTime? initialStart;

  /// Optional initial end date. Defaults to today + 6 days (date-only).
  final DateTime? initialEnd;

  @override
  State<MealPlanDateRangeForm> createState() => _MealPlanDateRangeFormState();
}

enum _OpenField { none, start, end }

class _MealPlanDateRangeFormState extends State<MealPlanDateRangeForm> {
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _focusedMonth;
  _OpenField _openField = _OpenField.none;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _startDate = widget.initialStart != null
        ? _dateOnly(widget.initialStart!)
        : today;
    _endDate = widget.initialEnd != null
        ? _dateOnly(widget.initialEnd!)
        : today.add(const Duration(days: 6));
    _focusedMonth = DateTime(_startDate.year, _startDate.month);
  }

  bool get _canSubmit => !_endDate.isBefore(_startDate);

  String? get _rangeError => _endDate.isBefore(_startDate)
      ? 'End date must be on or after start date.'
      : null;

  void _toggleField(_OpenField field, DateTime current) {
    setState(() {
      if (_openField == field) {
        _openField = _OpenField.none;
      } else {
        _openField = field;
        _focusedMonth = DateTime(current.year, current.month);
      }
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_openField == _OpenField.start) {
        _startDate = day;
        // Auto-bump end forward so the range stays valid.
        if (_endDate.isBefore(day)) _endDate = day;
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
    widget.onSubmit(DateTimeRange(start: _startDate, end: _endDate));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rangeError = _rangeError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DateField(
          label: 'Start Date',
          value: _startDate,
          isOpen: _openField == _OpenField.start,
          onTap: () => _toggleField(_OpenField.start, _startDate),
        ),
        _CalendarReveal(
          isOpen: _openField == _OpenField.start,
          child: InlineCalendar(
            selectedDate: _startDate,
            focusedMonth: _focusedMonth,
            onDaySelected: _onDaySelected,
            onMonthChanged: _onMonthChanged,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _DateField(
          label: 'End Date',
          value: _endDate,
          isOpen: _openField == _OpenField.end,
          onTap: () => _toggleField(_OpenField.end, _endDate),
        ),
        _CalendarReveal(
          isOpen: _openField == _OpenField.end,
          child: InlineCalendar(
            selectedDate: _endDate,
            focusedMonth: _focusedMonth,
            onDaySelected: _onDaySelected,
            onMonthChanged: _onMonthChanged,
            minDate: _startDate,
          ),
        ),
        if (rangeError != null) ...[
          const SizedBox(height: AppSizes.xs),
          Text(
            rangeError,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: AppSizes.md),
        AppPillButton(
          label: widget.ctaLabel,
          onPressed: _canSubmit ? _onSubmit : null,
        ),
      ],
    );
  }
}

/// Eases the inline calendar in/out instead of a hard blink when the
/// owning field toggles. Combines a [SizeTransition] (height reveal) with
/// a [FadeTransition] via [AnimatedSwitcher] (~200ms, easeOut). Adds the
/// `sm` gap above the calendar only while open so collapsed spacing stays
/// flush.
class _CalendarReveal extends StatelessWidget {
  const _CalendarReveal({required this.isOpen, required this.child});

  final bool isOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: isOpen
          ? Column(
              key: const ValueKey<bool>(true),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.sm),
                child,
              ],
            )
          : const SizedBox(width: double.infinity),
    );
  }
}

/// Single labelled date field. `value` is the currently chosen date —
/// rendered as `MMM d, yyyy` (e.g. `Apr 17, 2026`) so the day and month
/// are unambiguous. Border is forestdarkn (green-deep) at rest per Figma; the
/// open state thickens it to 2px and switches the fill to white.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.isOpen,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = _formatDate(value);
    // Figma date Input = #eaeaea fill + forestdarkn (greenDeep) border at rest
    // (971:8199); the open state only thickens it.
    const borderColor = AppColors.greenDeep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
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
              horizontal: AppSizes.fieldPaddingH,
            ),
            decoration: BoxDecoration(
              color: isOpen ? AppColors.surface : AppColors.bgInput,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: borderColor, width: isOpen ? 2 : 1),
            ),
            // No trailing calendar icon — Figma 971:8199 date inputs show only
            // the date text; the field still opens the inline calendar on tap.
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                displayText,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.fgStrong,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static const _monthAbbr = [
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

  static String _formatDate(DateTime d) {
    return '${_monthAbbr[d.month - 1]} ${d.day}, ${d.year}';
  }
}
