import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Home — rolling-7 day-chip row (NIB-77, Figma 1242:10628).
///
/// Decorative-only pill chips for today + the previous 6 days. The 'Today'
/// chip is highlighted (butter background, green-deep text); the rest use a
/// muted surface (surfaceVariant background, fgMuted text). No day selection
/// callback — selection is owned by the meal-plan screen, not Home.
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

  String _label(DateTime date) {
    final weekday = _shortWeekdays[date.weekday - 1];
    final month = _shortMonths[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List<DateTime>.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day - i),
    );

    return SizedBox(
      height: AppSizes.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, i) {
          final isToday = i == 0;
          return _PillChip(
            label: isToday ? 'Today' : _label(dates[i]),
            isActive: isToday,
          );
        },
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final background = isActive ? AppColors.butter : AppColors.surfaceVariant;
    final foreground = isActive ? AppColors.greenDeep : AppColors.fgMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md - 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
