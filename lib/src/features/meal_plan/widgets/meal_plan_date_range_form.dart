import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_prep_calendar.dart';

/// Shared START DATE / END DATE range picker used by the Meal Plan empty
/// state and the Select Period Date sheet (Figma 2839:15923). Renders two
/// grey pill fields showing a `dd/MM/yyyy` placeholder until a date is
/// chosen; tapping a field reveals a [MealPrepCalendar] inline directly
/// below it (the OS picker is never used).
///
/// Once BOTH dates are set it surfaces the coral info chip
/// "N weeks · M days of meals" (weeks = ceil(days / 7); days = inclusive
/// end − start + 1) and reports the range through [onRangeChanged].
///
/// The in-form CTA is optional: pass [ctaLabel] (+ [onSubmit]) to render a
/// primary pill under the fields (empty-state usage); omit it when the host
/// owns its own buttons (the select-period sheet's AI / manual pair).
class MealPlanDateRangeForm extends StatefulWidget {
  const MealPlanDateRangeForm({
    this.ctaLabel,
    this.onSubmit,
    this.onRangeChanged,
    this.initialStart,
    this.initialEnd,
    this.showInfoChip = true,
    super.key,
  });

  /// Optional in-form CTA label. When null no CTA pill is rendered.
  final String? ctaLabel;

  /// Fires when the user taps the in-form CTA with a valid range. Ignored
  /// when [ctaLabel] is null.
  final ValueChanged<DateTimeRange>? onSubmit;

  /// Fires whenever the selected range changes. Emits the valid
  /// [DateTimeRange] once both ends are set, or `null` while incomplete.
  final ValueChanged<DateTimeRange?>? onRangeChanged;

  /// Optional initial start date (date-only). No default — null shows the
  /// placeholder.
  final DateTime? initialStart;

  /// Optional initial end date (date-only). No default — null shows the
  /// placeholder.
  final DateTime? initialEnd;

  /// Whether to show the coral "N weeks · M days of meals" summary chip once
  /// both dates are set.
  final bool showInfoChip;

  @override
  State<MealPlanDateRangeForm> createState() => _MealPlanDateRangeFormState();
}

enum _OpenField { none, start, end }

class _MealPlanDateRangeFormState extends State<MealPlanDateRangeForm> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _focusedMonth;
  _OpenField _openField = _OpenField.none;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart == null
        ? null
        : _dateOnly(widget.initialStart!);
    _endDate = widget.initialEnd == null
        ? null
        : _dateOnly(widget.initialEnd!);
    final anchor = _startDate ?? _dateOnly(DateTime.now());
    _focusedMonth = DateTime(anchor.year, anchor.month);
    if (_range != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onRangeChanged?.call(_range);
      });
    }
  }

  DateTimeRange? get _range {
    final start = _startDate;
    final end = _endDate;
    if (start == null || end == null) return null;
    if (end.isBefore(start)) return null;
    return DateTimeRange(start: start, end: end);
  }

  void _toggleField(_OpenField field, DateTime? current) {
    setState(() {
      if (_openField == field) {
        _openField = _OpenField.none;
      } else {
        _openField = field;
        final anchor = current ?? _dateOnly(DateTime.now());
        _focusedMonth = DateTime(anchor.year, anchor.month);
      }
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_openField == _OpenField.start) {
        _startDate = day;
        // Keep the range valid — never let end fall before start.
        if (_endDate != null && _endDate!.isBefore(day)) _endDate = day;
      } else if (_openField == _OpenField.end) {
        _endDate = day;
      }
      _openField = _OpenField.none;
    });
    widget.onRangeChanged?.call(_range);
  }

  void _onMonthChanged(DateTime month) {
    setState(() => _focusedMonth = month);
  }

  void _onSubmit() {
    final range = _range;
    if (range == null) return;
    widget.onSubmit?.call(range);
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DateField(
          label: 'START DATE',
          value: _startDate,
          isOpen: _openField == _OpenField.start,
          onTap: () => _toggleField(_OpenField.start, _startDate),
        ),
        _CalendarReveal(
          isOpen: _openField == _OpenField.start,
          child: MealPrepCalendar(
            selectedDate: _startDate,
            focusedMonth: _focusedMonth,
            onDaySelected: _onDaySelected,
            onMonthChanged: _onMonthChanged,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _DateField(
          label: 'END DATE',
          value: _endDate,
          isOpen: _openField == _OpenField.end,
          onTap: () => _toggleField(_OpenField.end, _endDate ?? _startDate),
        ),
        _CalendarReveal(
          isOpen: _openField == _OpenField.end,
          child: MealPrepCalendar(
            selectedDate: _endDate,
            focusedMonth: _focusedMonth,
            onDaySelected: _onDaySelected,
            onMonthChanged: _onMonthChanged,
            minDate: _startDate,
          ),
        ),
        if (widget.showInfoChip && range != null) ...[
          const SizedBox(height: AppSizes.md),
          Align(
            alignment: Alignment.centerLeft,
            child: AppChip(
              label: _summaryLabel(range),
              icon: const Icon(Icons.event_note_rounded),
            ),
          ),
        ],
        if (widget.ctaLabel != null) ...[
          const SizedBox(height: AppSizes.md),
          AppPillButton(
            label: widget.ctaLabel!,
            onPressed: range == null ? null : _onSubmit,
          ),
        ],
      ],
    );
  }

  static String _summaryLabel(DateTimeRange range) {
    final days = range.end.difference(range.start).inDays + 1;
    final weeks = (days / 7).ceil();
    final weekWord = weeks == 1 ? 'week' : 'weeks';
    final dayWord = days == 1 ? 'day' : 'days';
    return '$weeks $weekWord · $days $dayWord of meals';
  }
}

/// Eases the inline calendar in/out instead of a hard blink when the owning
/// field toggles. Combines a [SizeTransition] (height reveal) with a
/// [FadeTransition] via [AnimatedSwitcher] (~200ms, easeOut).
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

/// Single labelled date field. Shows a `dd/MM/yyyy` placeholder until a date
/// is chosen, then the picked date in the same format. Grey pill fill; the
/// open state thickens the border to a 2px forest ring.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.isOpen,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;
    final displayText = hasValue ? _formatDate(value!) : 'dd/MM/yyyy';

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
              horizontal: AppSizes.fieldPaddingH + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(
                color: isOpen ? AppColors.greenDeep : Colors.transparent,
                width: isOpen ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: hasValue
                          ? AppColors.fgStrong
                          : AppColors.greenSoft,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: AppSizes.iconSm,
                  color: AppColors.greenSoft,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
