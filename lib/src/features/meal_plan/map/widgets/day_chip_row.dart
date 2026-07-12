import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/feedback/press_scale.dart';

/// Horizontal day chip row for the Map Meals Plan screen (NIB-95).
///
/// Renders one chip per day in `[startDate, endDate]`. Each chip renders
/// in one of three states (Figma frame 971:8441 / CalendarPerday):
///
/// * Selected (current chip)        — forest fill / cream text
/// * Full (slots for the day met)   — cream fill / forest text + ✓, lime outline
/// * Not-selected                   — white fill / forest text
class DayChipRow extends StatefulWidget {
  const DayChipRow({
    required this.startDate,
    required this.endDate,
    required this.selectedDay,
    required this.onSelect,
    this.fullDays = const <DateTime>{},
    super.key,
  });

  final DateTime startDate;
  final DateTime endDate;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelect;

  /// Set of days (date-only) whose per-day slot target is met — used to
  /// render the "full" chip variant (✓ + lime outline).
  final Set<DateTime> fullDays;

  static const _weekdayAbbrev = <int, String>{
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };

  static const _monthAbbrev = <int, String>{
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  State<DayChipRow> createState() => _DayChipRowState();
}

class _DayChipRowState extends State<DayChipRow> {
  final ScrollController _scrollController = ScrollController();

  List<DateTime> _days() {
    final start = DateTime(
      widget.startDate.year,
      widget.startDate.month,
      widget.startDate.day,
    );
    final end = DateTime(
      widget.endDate.year,
      widget.endDate.month,
      widget.endDate.day,
    );
    final count = end.difference(start).inDays + 1;
    return List<DateTime>.generate(count, (i) => start.add(Duration(days: i)));
  }

  @override
  void didUpdateWidget(covariant DayChipRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DayChipRow._isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    final days = _days();
    final index = days.indexWhere(
      (d) => DayChipRow._isSameDay(d, widget.selectedDay),
    );
    if (index < 0) return;

    const step = AppSizes.dayChipW + AppSizes.sm;
    final viewport = _scrollController.position.viewportDimension;
    final target =
        AppSizes.pagePaddingH +
        index * step -
        (viewport - AppSizes.dayChipW) / 2;
    _scrollController.animateTo(
      target.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: AppDurations.slide,
      curve: AppCurves.emphasized,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _days();
    return SizedBox(
      height: AppSizes.dayChipH,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = DayChipRow._isSameDay(day, widget.selectedDay);
          final isFull = widget.fullDays.any(
            (d) => DayChipRow._isSameDay(d, day),
          );
          return _DayChip(
            day: day,
            isSelected: isSelected,
            isFull: isFull,
            onTap: () => widget.onSelect(day),
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
    required this.isFull,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isFull;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final abbrev = DayChipRow._weekdayAbbrev[day.weekday] ?? '';
    final monthAbbrev = DayChipRow._monthAbbrev[day.month] ?? '';

    final Color bg;
    final Color fg;
    final Color borderColor;
    if (isSelected) {
      bg = AppColors.greenDeep;
      fg = AppColors.cardCream;
      borderColor = AppColors.greenDeep;
    } else if (isFull) {
      bg = AppColors.butterSoft;
      fg = AppColors.greenDeep;
      borderColor = AppColors.butterDark;
    } else {
      bg = AppColors.surface;
      fg = AppColors.fgDefault;
      borderColor = AppColors.borderSoft;
    }

    final abbrevStyle =
        (isSelected
                ? (AppTypography.textTheme.labelMedium ?? AppTypography.caption)
                : AppTypography.caption)
            .copyWith(
              color: fg,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            );
    final dateStyle = AppTypography.caption.copyWith(
      color: fg,
      fontWeight: FontWeight.w700,
    );

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$abbrev ${day.day} $monthAbbrev',
      excludeSemantics: true,
      onTap: onTap,
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.base,
          curve: AppCurves.standard,
          width: AppSizes.dayChipW,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.sm,
            horizontal: AppSizes.xs,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: AppDurations.quick,
                switchInCurve: AppCurves.emphasized,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: isFull && !isSelected
                    ? Column(
                        key: const ValueKey<bool>(true),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: fg, size: AppSizes.iconSm),
                          const SizedBox(height: 2),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey<bool>(false)),
              ),
              AnimatedDefaultTextStyle(
                duration: AppDurations.base,
                curve: AppCurves.standard,
                style: abbrevStyle,
                child: Text(abbrev),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: AppDurations.base,
                curve: AppCurves.standard,
                style: dateStyle,
                child: Text('${day.day} $monthAbbrev'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
