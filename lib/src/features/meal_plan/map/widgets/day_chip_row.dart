import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Horizontal day chip row for the Map Meals Plan screen (NIB-95).
///
/// Renders one chip per day in `[startDate, endDate]`. Selected chip uses
/// [AppColors.greenDeep]; unselected chips show the day abbreviation and
/// numeric date in muted text on cream.
class DayChipRow extends StatelessWidget {
  const DayChipRow({
    required this.startDate,
    required this.endDate,
    required this.selectedDay,
    required this.onSelect,
    super.key,
  });

  final DateTime startDate;
  final DateTime endDate;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelect;

  static const _weekdayAbbrev = <int, String>{
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };

  List<DateTime> _days() {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final count = end.difference(start).inDays + 1;
    return List<DateTime>.generate(count, (i) => start.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final days = _days();
    return SizedBox(
      height: AppSizes.dayChipH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDay(day, selectedDay);
          return _DayChip(
            day: day,
            isSelected: isSelected,
            onTap: () => onSelect(day),
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final abbrev = DayChipRow._weekdayAbbrev[day.weekday] ?? '';
    final bg = isSelected ? AppColors.greenDeep : AppColors.surface;
    final fg = isSelected ? AppColors.onGreen : AppColors.fgDefault;
    final borderColor = isSelected ? AppColors.greenDeep : AppColors.borderSoft;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.dayChipW,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.sp12,
          horizontal: AppSizes.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              abbrev,
              style: AppTypography.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              '${day.day}',
              style: AppTypography.sectionTitle.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
