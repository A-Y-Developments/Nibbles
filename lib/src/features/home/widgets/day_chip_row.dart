import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Home — DateRow (NIB-77, Figma 1242:10628).
///
/// Renders three tall CalendarPerday chips per the home-populated audit
/// (today + two previous days). The first chip uses the lime selected
/// variant; the remaining two use the default white variant. Decorative —
/// day selection is owned by the meal-plan screen, not Home.
///
/// Per chip layout (matches CalendarPerday variant tokens):
///   - Width 64, height 86, radius 20.
///   - Top line: weekday + comma, Figtree 13/600.
///   - Bottom line: month + day, Parkinsans 17/700.
class DayChipRow extends StatelessWidget {
  const DayChipRow({super.key});

  static const List<String> _shortMonths = [
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

  static const List<String> _shortWeekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List<DateTime>.generate(
      3,
      (i) => DateTime(today.year, today.month, today.day - i),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List<Widget>.generate(dates.length, (i) {
          final date = dates[i];
          return Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : AppSizes.sm),
            child: _CalendarPerday(
              weekday: '${_shortWeekdays[date.weekday - 1]},',
              monthDay: '${_shortMonths[date.month - 1]} ${date.day}',
              isSelected: i == 0,
            ),
          );
        }),
      ),
    );
  }
}

class _CalendarPerday extends StatelessWidget {
  const _CalendarPerday({
    required this.weekday,
    required this.monthDay,
    required this.isSelected,
  });

  final String weekday;
  final String monthDay;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final background = isSelected ? AppColors.butter : AppColors.surface;

    return Container(
      width: AppSizes.dayChipW,
      constraints: const BoxConstraints(minHeight: AppSizes.dayChipH),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: isSelected ? null : AppSizes.shadowCard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekday,
            style: const TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            monthDay,
            style: const TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.fgStrong,
            ),
          ),
        ],
      ),
    );
  }
}
