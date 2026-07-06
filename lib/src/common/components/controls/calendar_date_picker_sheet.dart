import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:table_calendar/table_calendar.dart';

/// Branded bottom-sheet date picker — replaces the off-brand native Material
/// date picker. A `table_calendar` month grid styled to the sage / cream
/// design system with a `greenDeep` selected day and a confirm pill. Resolves
/// to the chosen date, or null when dismissed.
Future<DateTime?> showCalendarDatePickerSheet(
  BuildContext context, {
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radius3xl),
      ),
    ),
    builder: (ctx) => _CalendarDateSheet(
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initialDate,
    ),
  );
}

class _CalendarDateSheet extends StatefulWidget {
  const _CalendarDateSheet({
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate;

  @override
  State<_CalendarDateSheet> createState() => _CalendarDateSheetState();
}

class _CalendarDateSheetState extends State<_CalendarDateSheet> {
  late DateTime _selected;
  late DateTime _focused;

  @override
  void initState() {
    super.initState();
    final init = widget.initialDate ?? widget.lastDate;
    _selected = init;
    _focused = init;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = AppTypography.textTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePaddingH,
          AppSizes.lg,
          AppSizes.pagePaddingH,
          AppSizes.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date', style: textTheme.titleLarge),
            const SizedBox(height: AppSizes.md),
            TableCalendar<void>(
              firstDay: widget.firstDate,
              lastDay: widget.lastDate,
              focusedDay: _focused,
              currentDay: _selected,
              selectedDayPredicate: (d) => isSameDay(d, _selected),
              availableGestures: AvailableGestures.horizontalSwipe,
              daysOfWeekHeight: 28,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    textTheme.titleMedium ?? const TextStyle(fontSize: 16),
                leftChevronIcon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.greenDeep,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.greenDeep,
                ),
              ),
              calendarStyle: CalendarStyle(
                isTodayHighlighted: false,
                outsideDaysVisible: false,
                selectedDecoration: const BoxDecoration(
                  color: AppColors.greenDeep,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w700,
                ),
                disabledTextStyle: TextStyle(
                  color: AppColors.fgFaint.withValues(alpha: 0.4),
                ),
              ),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selected = selected;
                  _focused = focused;
                });
              },
              onPageChanged: (focused) => _focused = focused,
            ),
            const SizedBox(height: AppSizes.md),
            AppPillButton(
              label: 'Select',
              onPressed: () => Navigator.of(context).pop(_selected),
            ),
          ],
        ),
      ),
    );
  }
}
