import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Reusable inline month-calendar picker that renders below the focused
/// date field (replaces the OS picker). Fully controlled — the consumer
/// owns `selectedDate` + `focusedMonth` and wires the callbacks.
///
/// Mirrors the meal-plan picker overlay (Figma 971:8198 / 971:8222 /
/// 971:8246): month title row with chevrons, Sun..Sat header row, then a
/// 6-row day grid with today highlighted and the selected day filled
/// greenDeep. Days outside `minDate`/`maxDate` are dimmed and untappable.
class InlineCalendar extends StatelessWidget {
  const InlineCalendar({
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

  /// Fires when the user taps a chevron — emits the new focused month
  /// (normalised to day 1).
  final ValueChanged<DateTime> onMonthChanged;

  /// Optional lower bound (inclusive). Earlier days are dimmed + untappable.
  final DateTime? minDate;

  /// Optional upper bound (inclusive). Later days are dimmed + untappable.
  final DateTime? maxDate;

  static const List<String> _weekdayLabels = <String>[
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = _formatMonth(focusedMonth);

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
          _MonthHeader(
            label: monthLabel,
            onPrev: () => onMonthChanged(_addMonths(focusedMonth, -1)),
            onNext: () => onMonthChanged(_addMonths(focusedMonth, 1)),
          ),
          const SizedBox(height: AppSizes.sp12),
          Row(
            children: [
              for (final label in _weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.fgFaint,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          _MonthGrid(
            focusedMonth: focusedMonth,
            selectedDate: selectedDate,
            minDate: minDate,
            maxDate: maxDate,
            onDaySelected: onDaySelected,
          ),
        ],
      ),
    );
  }

  static DateTime _addMonths(DateTime base, int delta) =>
      DateTime(base.year, base.month + delta);

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

  static String _formatMonth(DateTime d) =>
      '${_monthNames[d.month - 1]} ${d.year}';
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _ChevronButton(
          icon: Icons.chevron_left_rounded,
          onPressed: onPrev,
          semanticLabel: 'Previous month',
        ),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.fgStrong,
              ),
            ),
          ),
        ),
        _ChevronButton(
          icon: Icons.chevron_right_rounded,
          onPressed: onNext,
          semanticLabel: 'Next month',
        ),
      ],
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton({
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

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.minDate,
    required this.maxDate,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month);
    // DateTime.weekday returns 1 (Mon) .. 7 (Sun). Sun-start grid → 0..6.
    final leadingBlanks = firstDay.weekday % 7;
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final today = _dateOnly(DateTime.now());
    final selected =
        selectedDate == null ? null : _dateOnly(selectedDate!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.xs),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _buildCell(
                      context: context,
                      cellIndex: row * 7 + col,
                      leadingBlanks: leadingBlanks,
                      daysInMonth: daysInMonth,
                      today: today,
                      selected: selected,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCell({
    required BuildContext context,
    required int cellIndex,
    required int leadingBlanks,
    required int daysInMonth,
    required DateTime today,
    required DateTime? selected,
  }) {
    final dayOffset = cellIndex - leadingBlanks;
    if (dayOffset < 0 || dayOffset >= daysInMonth) {
      return const _DayPlaceholder();
    }
    final day = DateTime(
      focusedMonth.year,
      focusedMonth.month,
      dayOffset + 1,
    );
    final isToday = _sameDate(day, today);
    final isSelected = selected != null && _sameDate(day, selected);
    final isOutOfRange = _outOfRange(day);

    return _DayCell(
      day: day,
      isToday: isToday,
      isSelected: isSelected,
      isOutOfRange: isOutOfRange,
      onTap: isOutOfRange ? null : () => onDaySelected(day),
    );
  }

  bool _outOfRange(DateTime day) {
    final min = minDate;
    final max = maxDate;
    if (min != null && day.isBefore(_dateOnly(min))) return true;
    if (max != null && day.isAfter(_dateOnly(max))) return true;
    return false;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayPlaceholder extends StatelessWidget {
  const _DayPlaceholder();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: AppSizes.sp40);
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isOutOfRange,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool isOutOfRange;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bg;
    Color fg;
    BoxBorder? border;

    if (isSelected) {
      bg = AppColors.greenDeep;
      fg = AppColors.butterSoft;
      border = null;
    } else if (isToday) {
      bg = AppColors.butterSoft;
      fg = AppColors.greenDeep;
      border = Border.all(color: AppColors.green);
    } else {
      bg = Colors.transparent;
      fg = isOutOfRange ? AppColors.fgFaint : AppColors.fgStrong;
      border = null;
    }

    final style = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: fg,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: AppSizes.sp40,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.sp2),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Text('${day.day}', style: style),
      ),
    );
  }
}
