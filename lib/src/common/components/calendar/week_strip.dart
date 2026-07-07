import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/calendar/day_chip.dart';

/// Immutable data for one day in a [WeekStrip].
class WeekDay {
  const WeekDay({
    required this.dayOfWeek,
    required this.date,
    required this.state,
  });

  final String dayOfWeek;
  final String date;
  final DayChipState state;
}

/// Horizontally scrollable strip of [DayChip]s. The horizontal day-chip strip
/// referenced by the spec — NOT table_calendar (month grid is themed
/// separately for meal-plan).
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.days,
    this.onDaySelected,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final List<WeekDay> days;
  final ValueChanged<int>? onDaySelected;

  /// Leading/trailing inset for the scrollable list so the first/last chip can
  /// align with padded content while the strip itself bleeds edge-to-edge.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.dayChipH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm + 2),
        itemBuilder: (context, i) {
          final day = days[i];
          return DayChip(
            dayOfWeek: day.dayOfWeek,
            date: day.date,
            state: day.state,
            onTap: onDaySelected == null ? null : () => onDaySelected!(i),
          );
        },
      ),
    );
  }
}
