import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:table_calendar/table_calendar.dart';

/// Styled month calendar wrapping the `table_calendar` package (Figma
/// 2839:16295 "Image 4"). Fully controlled — the consumer owns
/// [selectedDate] + [focusedMonth] and wires the callbacks; the widget holds
/// no state of its own so it drops cleanly into the date-range form and the
/// select-period sheet in place of any native picker.
///
/// Layout: month title on the left, a grouped `< >` chevron pair top-right,
/// a SUN..SAT weekday header, then the day grid. Today is highlighted with a
/// butter fill + green ring; the selected day is a filled forest circle.
/// Days outside [minDate]/[maxDate] are dimmed and untappable (the package's
/// `firstDay`/`lastDay` bounds drive this, so paging can't overshoot them).
class MealPrepCalendar extends StatelessWidget {
  const MealPrepCalendar({
    required this.selectedDate,
    required this.focusedMonth,
    required this.onDaySelected,
    required this.onMonthChanged,
    this.minDate,
    this.maxDate,
    super.key,
  });

  /// Currently selected day. `null` renders no selection highlight.
  final DateTime? selectedDate;

  /// Month currently shown (only year + month matter).
  final DateTime focusedMonth;

  /// Fires when the user taps a tappable (in-range) day cell.
  final ValueChanged<DateTime> onDaySelected;

  /// Fires when the user pages the calendar — emits the new focused month
  /// (normalised to day 1).
  final ValueChanged<DateTime> onMonthChanged;

  /// Optional lower bound (inclusive). Earlier days are dimmed + untappable.
  final DateTime? minDate;

  /// Optional upper bound (inclusive). Later days are dimmed + untappable.
  final DateTime? maxDate;

  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _firstDay => minDate != null
      ? _dateOnly(minDate!)
      : DateTime(focusedMonth.year - 2, focusedMonth.month);

  DateTime get _lastDay => maxDate != null
      ? _dateOnly(maxDate!)
      : DateTime(focusedMonth.year + 2, focusedMonth.month + 1, 0);

  /// [TableCalendar] asserts `firstDay <= focusedDay <= lastDay`; a day-1
  /// [focusedMonth] can fall before a mid-month [minDate], so clamp it.
  DateTime get _focusedDay {
    final first = _firstDay;
    final last = _lastDay;
    if (focusedMonth.isBefore(first)) return first;
    if (focusedMonth.isAfter(last)) return last;
    return focusedMonth;
  }

  void _stepMonth(int delta) {
    onMonthChanged(DateTime(focusedMonth.year, focusedMonth.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppSizes.shadowCard,
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            label:
                '${_monthNames[focusedMonth.month - 1]} ${focusedMonth.year}',
            onPrev: () => _stepMonth(-1),
            onNext: () => _stepMonth(1),
          ),
          const SizedBox(height: AppSizes.sp12),
          TableCalendar<void>(
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            headerVisible: false,
            daysOfWeekHeight: AppSizes.lg,
            rowHeight: AppSizes.xxl,
            selectedDayPredicate: (day) =>
                selectedDate != null && isSameDay(day, selectedDate),
            onDaySelected: (selected, _) => onDaySelected(_dateOnly(selected)),
            onPageChanged: (focused) =>
                onMonthChanged(DateTime(focused.year, focused.month)),
            availableGestures: AvailableGestures.horizontalSwipe,
            calendarBuilders: CalendarBuilders<void>(
              dowBuilder: (context, day) => _Dow(weekday: day.weekday),
              defaultBuilder: (context, day, _) => _DayCell(day: day),
              outsideBuilder: (context, day, _) =>
                  _DayCell(day: day, muted: true),
              disabledBuilder: (context, day, _) =>
                  _DayCell(day: day, muted: true),
              todayBuilder: (context, day, _) =>
                  _DayCell(day: day, isToday: true),
              selectedBuilder: (context, day, _) =>
                  _DayCell(day: day, isSelected: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
        ),
        _Chevron(
          icon: Icons.chevron_left_rounded,
          onPressed: onPrev,
          semanticLabel: 'Previous month',
        ),
        const SizedBox(width: AppSizes.sm),
        _Chevron(
          icon: Icons.chevron_right_rounded,
          onPressed: onNext,
          semanticLabel: 'Next month',
        ),
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greenTint,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AppSizes.roundButtonSm,
          height: AppSizes.roundButtonSm,
          child: Icon(
            icon,
            size: AppSizes.iconMd,
            color: AppColors.greenDeep,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}

class _Dow extends StatelessWidget {
  const _Dow({required this.weekday});

  final int weekday;

  static const List<String> _labels = <String>[
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _labels[weekday - 1],
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.fgFaint,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    this.isToday = false,
    this.isSelected = false,
    this.muted = false,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BoxBorder? border;

    if (isSelected) {
      bg = AppColors.greenDeep;
      fg = AppColors.butterSoft;
    } else if (isToday) {
      bg = AppColors.butterSoft;
      fg = AppColors.greenDeep;
      border = Border.all(color: AppColors.green);
    } else {
      bg = Colors.transparent;
      fg = muted ? AppColors.fgFaint : AppColors.fgStrong;
    }

    return Center(
      child: Container(
        width: AppSizes.sp40,
        height: AppSizes.sp40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Text(
          '${day.day}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
